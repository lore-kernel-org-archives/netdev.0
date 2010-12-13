From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH net-next-2.6] net: add dev_close_many
Date: Mon, 13 Dec 2010 19:23:26 +0200
Message-ID: <201012131923.27337.opurdila@ixiacom.com>
References: <1292249903-3865-1-git-send-email-opurdila@ixiacom.com> <1292259145.2759.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:27613 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752298Ab0LMRXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 12:23:30 -0500
In-Reply-To: <1292259145.2759.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Monday 13 December 2010, 18:52:25

> Hmm, I think this solves the "rmmod dummy" case, but not the "dismantle
> devices one by one", which is the general one (on heavy duty tunnels/ppp
> servers)
> 
> I think we could use a kernel thread (a workqueue presumably), handling
> 3 lists of devices to be dismantled, respecting one rcu grace period (or
> rcu_barrier()) before transfert of one item from one list to following
> one.
> 
> This way, each device removal could post a device to this kernel thread
> and return to user immediately. Time of RTNL hold would be reduced
> (calls to synchronize_rcu() would be done with RTNL not held)

We also run into the case where we have to dismantle the interfaces one by one 
but we fix it by gathering the requests in userspace and then doing a 
unregister_netdevice_many operation.

I like the kernel thread / workqueue idea. But we would still need 
netdevice_unregister_many and dev_close_many right? - we put the device in the 
unregister list in unregister_netdevice and call unregister_netdevice_many in 
the kernel thread.


 
