From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] bonding: fix system hang due to fast igmp
 timer rescheduling
Date: Thu, 01 Aug 2013 15:53:11 -0700 (PDT)
Message-ID: <20130801.155311.357862923906678467.davem@davemloft.net>
References: <1375350702-7777-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753533Ab3HAWxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 18:53:12 -0400
In-Reply-To: <1375350702-7777-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Thu,  1 Aug 2013 11:51:42 +0200

> From: "Nikolay Aleksandrov" <nikolay@redhat.com>
> 
> After commit 4aa5dee4d9 ("net: convert resend IGMP to notifier event")
> we try to acquire rtnl in bond_resend_igmp_join_requests but it can be
> scheduled with rtnl already held (e.g. when bond_change_active_slave is
> called with rtnl) causing a loop of immediate reschedules + calls because
> rtnl_trylock fails each time since it's being already held.
> For me this issue leads to system hangs very easy:
> modprobe bonding; ifconfig bond0 up; ifenslave bond0 eth0; rmmod
> bonding;
> 
> The fix is to introduce a small (1 jiffy) delay which is enough for the
> sections holding rtnl to finish without putting any strain on the system.
> Also adjust the timer in bond_change_active_slave to be 1 jiffy, since
> most of the time it's called with rtnl already held.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied, thanks.
