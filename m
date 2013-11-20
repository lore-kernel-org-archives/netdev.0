From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] net: core: Always propagate flag changes to
 interfaces
Date: Wed, 20 Nov 2013 15:30:40 -0500 (EST)
Message-ID: <20131120.153040.1802820913098903513.davem@davemloft.net>
References: <1384912035-17800-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.priebe@profihost.ag, vfalico@redhat.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134Ab3KTUam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 15:30:42 -0500
In-Reply-To: <1384912035-17800-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Tue, 19 Nov 2013 20:47:15 -0500

> The following commit:
>     b6c40d68ff6498b7f63ddf97cf0aa818d748dee7
>     net: only invoke dev->change_rx_flags when device is UP
> 
> tried to fix a problem with VLAN devices and promiscuouse flag setting.
> The issue was that VLAN device was setting a flag on an interface that
> was down, thus resulting in bad promiscuity count.
> This commit blocked flag propagation to any device that is currently
> down.
> 
> A later commit:
>     deede2fabe24e00bd7e246eb81cd5767dc6fcfc7
>     vlan: Don't propagate flag changes on down interfaces
> 
> fixed VLAN code to only propagate flags when the VLAN interface is up,
> thus fixing the same issue as above, only localized to VLAN.
> 
> The problem we have now is that if we have create a complex stack
> involving multiple software devices like bridges, bonds, and vlans,
> then it is possible that the flags would not propagate properly to
> the physical devices.  A simple examle of the scenario is the
> following:
> 
>   eth0----> bond0 ----> bridge0 ---> vlan50
> 
> If bond0 or eth0 happen to be down at the time bond0 is added to
> the bridge, then eth0 will never have promisc mode set which is
> currently required for operation as part of the bridge.  As a
> result, packets with vlan50 will be dropped by the interface.
> 
> The only 2 devices that implement the special flag handling are
> VLAN and DSA and they both have required code to prevent incorrect
> flag propagation.  As a result we can remove the generic solution
> introduced in b6c40d68ff6498b7f63ddf97cf0aa818d748dee7 and leave
> it to the individual devices to decide whether they will block
> flag propagation or not.
> 
> Reported-by: Stefan Priebe <s.priebe@profihost.ag>
> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied and queued up for -stable, thanks Vlad.
