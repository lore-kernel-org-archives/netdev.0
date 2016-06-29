From: David Miller <davem@davemloft.net>
Subject: Re: [net] e1000e: keep VLAN interfaces functional after rxvlan off
Date: Wed, 29 Jun 2016 07:40:06 -0400 (EDT)
Message-ID: <20160629.074006.1279014794531759883.davem@davemloft.net>
References: <1467171691-54525-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, netdev@vger.kernel.org, nhorman@redhat.com,
	sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40688 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbcF2Lwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 07:52:43 -0400
In-Reply-To: <1467171691-54525-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 28 Jun 2016 20:41:31 -0700

> From: Jarod Wilson <jarod@redhat.com>
> 
> I've got a bug report about an e1000e interface, where a VLAN interface is
> set up on top of it:
> 
> $ ip link add link ens1f0 name ens1f0.99 type vlan id 99
> $ ip link set ens1f0 up
> $ ip link set ens1f0.99 up
> $ ip addr add 192.168.99.92 dev ens1f0.99
> 
> At this point, I can ping another host on vlan 99, ip 192.168.99.91.
> However, if I do the following:
> 
> $ ethtool -K ens1f0 rxvlan off
> 
> Then no traffic passes on ens1f0.99. It comes back if I toggle rxvlan on
> again. I'm not sure if this is actually intended behavior, or if there's a
> lack of software VLAN stripping fallback, or what, but things continue to
> work if I simply don't call e1000e_vlan_strip_disable() if there are
> active VLANs (plagiarizing a function from the e1000 driver here) on the
> interface.
> 
> Also slipped a related-ish fix to the kerneldoc text for
> e1000e_vlan_strip_disable here...
> 
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
