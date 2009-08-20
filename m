From: Jim Gifford <maillist@jg555.com>
Subject: Sparc X1 Tulip Issue - NetDev
Date: Thu, 20 Aug 2009 07:37:16 -0700
Message-ID: <4A8D5F9C.90205@jg555.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-64-183-102-10.west.biz.rr.com ([64.183.102.10]:60199 "EHLO
	mail.jg555.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754465AbZHTPK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 11:10:26 -0400
Received: from [16.1.1.101]
	by mail.jg555.com with esmtpsa (TLSv1:DHE-RSA-AES256-SHA:256)
	(Exim 4.69)
	(envelope-from <maillist@jg555.com>)
	id 1Me8lW-0005dZ-EW
	for netdev@vger.kernel.org; Thu, 20 Aug 2009 07:37:35 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Miller asked me to forward this report here.

I've tried reporting this several times, this issue started with 2.6.24.

It randomly just stops transmitting after receiving after an oops.

This is from a fresh install of a 2.6.30.5 kernel.

[35883.804335] WARNING: at net/sched/sch_generic.c:226 
dev_watchdog+0x24c/0x260()
[35883.804351] NETDEV WATCHDOG: eth0 (tulip): transmit timed out
[35883.804362] Modules linked in: tulip bitrev crc32
[35883.804383] Call Trace:
[35883.804406]  [0000000000452308] warn_slowpath_fmt+0x28/0x40
[35883.804427]  [000000000060420c] dev_watchdog+0x24c/0x260
[35883.804449]  [000000000045c520] run_timer_softirq+0x180/0x200
[35883.804473]  [00000000004577e8] __do_softirq+0xa8/0x180
[35883.804495]  [000000000042a470] do_softirq+0x70/0xa0
[35883.804514]  [0000000000457478] irq_exit+0x78/0xa0
[35883.804537]  [000000000042f578] timer_interrupt+0x58/0xa0
[35883.804558]  [00000000004209d4] tl0_irq14+0x14/0x20
[35883.804582]  [00000000004398c8] touch_nmi_watchdog+0x8/0x40
[35883.804607]  [000000000074e738] start_kernel+0x278/0x2b4
[35883.804633]  [000000000065c344] tlb_fixup_done+0x80/0x9c
[35883.804648]  [0000000000000000] (null)
[35883.804659] ---[ end trace 7e1dab9c687ff5bf ]---
[35883.806006] 0000:00:0c.0: tulip_stop_rxtx() failed (CSR5 0xfc508100 
CSR6 0x20e0000)
[35891.801619] 0000:00:0c.0: tulip_stop_rxtx() failed (CSR5 0xfc508100 
CSR6 0x20e0000)
[35899.797635] 0000:00:0c.0: tulip_stop_rxtx() failed (CSR5 0xfc508100 
CSR6 0x20e0000)
[35907.793597] 0000:00:0c.0: tulip_stop_rxtx() failed (CSR5 0xfc508100 
CSR6 0x20e0000)
[35915.789526] 0000:00:0c.0: tulip_stop_rxtx() failed (CSR5 0xfc508100 
CSR6 0x20e0000)
[35923.785595] 0000:00:0c.0: tulip_stop_rxtx() failed (CSR5 0xfc508100 
CSR6 0x20e0000)

Here's the error I got a long time ago with a 2.6.26 kernel

[ 6423.138199] ------------[ cut here ]------------
[ 6423.138230] WARNING: at net/sched/sch_generic.c:219 
dev_watchdog+0x250/0x280()
[ 6423.138243] NETDEV WATCHDOG: eth0 (tulip): transmit timed out
[ 6423.138252] Modules linked in: openpromfs tulip
[ 6423.138268] Call Trace:
[ 6423.138285]  [00000000005ecf10] dev_watchdog+0x250/0x280
[ 6423.138307]  [000000000045f64c] run_timer_softirq+0x16c/0x1e0
[ 6423.138325]  [000000000045ab7c] __do_softirq+0x5c/0xe0
[ 6423.138351]  [000000000042e3f0] do_softirq+0x70/0xa0
[ 6423.138366]  [000000000045a764] irq_exit+0x84/0xc0
[ 6423.138381]  [000000000043327c] timer_interrupt+0x5c/0xc0
[ 6423.138400]  [00000000004209d4] tl0_irq14+0x14/0x20
[ 6423.138414]  [0000000000428040] cpu_idle+0x20/0xc0
[ 6423.138437]  [000000000070c8bc] start_kernel+0x27c/0x2c0
[ 6423.138453]  [0000000000643744] tlb_fixup_done+0x80/0x9c
[ 6423.138465]  [0000000000000000] 0x0

[ 6423.138475] ---[ end trace f5f651c5dad2e555 ]---


Here's one from 2.6.28

[131219.643283] ------------[ cut here ]------------
[131219.643314] WARNING: at net/sched/sch_generic.c:219 
dev_watchdog+0x250/0x280()
[131219.643327] NETDEV WATCHDOG: eth0 (tulip): transmit timed out
[131219.643337] Modules linked in: openpromfs tulip
[131219.643353] Call Trace:
[131219.643369]  [00000000005ecf10] dev_watchdog+0x250/0x280
[131219.643392]  [000000000045f64c] run_timer_softirq+0x16c/0x1e0
[131219.643409]  [000000000045ab7c] __do_softirq+0x5c/0xe0
[131219.643435]  [000000000042e3f0] do_softirq+0x70/0xa0
[131219.643450]  [000000000045a764] irq_exit+0x84/0xc0
[131219.643466]  [000000000043327c] timer_interrupt+0x5c/0xc0
[131219.643484]  [00000000004209d4] tl0_irq14+0x14/0x20
[131219.643499]  [0000000000428050] cpu_idle+0x30/0xc0
[131219.643522]  [000000000070c8bc] start_kernel+0x27c/0x2c0
[131219.643538]  [0000000000643744] tlb_fixup_done+0x80/0x9c
[131219.643550]  [0000000000000000] 0x0
[131219.643560] ---[ end trace b95673019322adce ]---
[131219.644916] 0000:00:0c.0: tulip_stop_rxtx() failed (CSR5 0xfc508100 
CSR6 0x20ec000)
[131227.640686] 0000:00:0c.0: tulip_stop_rxtx() failed (CSR5 0xfc508100 
CSR6 0x20ec000)


Here are the other times I reported the issue.
http://kerneltrap.org/mailarchive/linux-net/2008/10/27/3818464
http://marc.info/?l=linux-sparc&m=123195048607500&w=2
