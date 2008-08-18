From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Mon, 18 Aug 2008 12:58:05 +0000
Message-ID: <20080818125805.GA7938@ff.dom.local>
References: <20080818091011.GC5434@ff.dom.local> <20080818112022.GA7158@ff.dom.local> <20080818113531.GB7158@ff.dom.local> <200808181545.30146.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:35658 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752494AbYHRM6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 08:58:12 -0400
Received: by ug-out-1314.google.com with SMTP id c2so187700ugf.37
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 05:58:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808181545.30146.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2008 at 03:45:29PM +0300, Denys Fedoryshchenko wrote:
> Patch applied, got another warning.

I hope I'll figure this out before evening. Probably it's safer
to stop testing for a while.

Thanks,
Jarek P.

> 
> [  413.646102]
> [  413.646102] =========================
> [  413.646102] [ BUG: held lock freed! ]
> [  413.646102] -------------------------
> [  413.646102] pppd/4105 is freeing memory f6fe6e00-f6fe6eff, with a lock 
> still held there!
> [  413.646102]  (&qdisc_rx_lock){-+..}, at: [<c026e3ab>] 
> shutdown_scheduler_queue+0x1c/0x2e
> [  413.646102] 3 locks held by pppd/4105:
> [  413.646102]  #0:  (all_ppp_mutex){--..}, at: [<f8a671ae>] 
> ppp_shutdown_interface+0x17/0xb0 [ppp_generic]
> [  413.646102]  #1:  (rtnl_mutex){--..}, at: [<c026967a>] rtnl_lock+0xf/0x11
> [  413.647102]  #2:  (&qdisc_rx_lock){-+..}, at: [<c026e3ab>] 
> shutdown_scheduler_queue+0x1c/0x2e
> [  413.647102]
> [  413.647102] stack backtrace:
> [  413.647102] Pid: 4105, comm: pppd Not tainted 
> 2.6.27-rc3-build-0031-12578-g96d2031-dirty #32
> [  413.647102]  [<c02ba6f7>] ? printk+0xf/0x18
> [  413.647102]  [<c013db8f>] debug_check_no_locks_freed+0xce/0xff
> [  413.647102]  [<c01643ce>] kfree+0x78/0xc8
> [  413.647102]  [<c026e38b>] ? qdisc_destroy+0x8c/0x90
> [  413.647102]  [<c026e38b>] qdisc_destroy+0x8c/0x90
> [  413.647102]  [<c026e3b2>] shutdown_scheduler_queue+0x23/0x2e
> [  413.647102]  [<c026e3fa>] dev_shutdown+0x3d/0x59
> [  413.647102]  [<c0262240>] rollback_registered+0x128/0x1b1
> [  413.647102]  [<c02622fb>] unregister_netdevice+0x32/0x6e
> [  413.647102]  [<c0262349>] unregister_netdev+0x12/0x1a
> [  413.647102]  [<f8a671f3>] ppp_shutdown_interface+0x5c/0xb0 [ppp_generic]
> [  413.647102]  [<f8a6742c>] ppp_release+0x2c/0x5a [ppp_generic]
> [  413.647102]  [<c0167db8>] __fput+0x99/0x136
> [  413.647102]  [<c0167e6c>] fput+0x17/0x19
> [  413.647102]  [<c016593b>] filp_close+0x47/0x51
> [  413.647102]  [<c01659b8>] sys_close+0x73/0xad
> [  413.647102]  [<c0103861>] sysenter_do_call+0x12/0x35
> [  413.647102]  =======================
> 
> On Monday 18 August 2008, Jarek Poplawski wrote:
