From: Vikram Narayanan <vikram186@gmail.com>
Subject: Re: i.Mx6Quad - eth0: tx queue full!
Date: Wed, 30 Jan 2013 20:43:06 +0530
Message-ID: <51093882.2060700@gmail.com>
References: <5106B7EE.3040603@gmail.com> <5106D5D4.2090200@boundarydevices.com> <5107FA00.2010809@gmail.com> <51081910.4030707@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LAK <linux-arm-kernel@lists.infradead.org>,
	Fabio Estevam <festevam@gmail.com>
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f44.google.com ([209.85.210.44]:51782 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753557Ab3A3PNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 10:13:25 -0500
Received: by mail-da0-f44.google.com with SMTP id z20so812304dae.3
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 07:13:22 -0800 (PST)
In-Reply-To: <51081910.4030707@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/30/2013 12:16 AM, Troy Kisky wrote:
> I have fixed this bug (and more) on Freescale's kernel 
> (imx-3.0.35_1.1.0). I created a branch you can try.
> Feel free to port to mainline.

Thanks a lot for the branch. I saw a lot of differences between
your driver and the mainline. I should spend some time If I had
to port this to mainline.
 
> This is the patch that should fix your problem
> fec: clear TX_FULL in fec_restart
> 
> 
> Please let me know results.

When NAPI is disabled I saw a severe packet loss 
(around 40% in a flood ping) which spitted out this,

[  470.390928] net eth0: missed rxf 2000000 1c000000 0
[  470.419098] net eth0: missed rxf 2000000 1c000000 0
[  470.443800] net eth0: missed rxf 2000000 1c000000 0
[  470.450315] net eth0: missed rxf 2000000 1c000000 0

When NAPI is enabled, it was working good. Though it
resulted in the same error, it recovered by itself,
which is perfectly fine for me. :)

[  507.359857] ------------[ cut here ]------------
[  507.365841] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x298/0x2c0()
[  507.375655] NETDEV WATCHDOG: eth0 (fec): transmit queue 0 timed out
[  507.384521] Modules linked in:
[  507.388907] [<80033e6c>] (unwind_backtrace+0x0/0xf8) from [<800558d0>] (warn_slowpath_common+0x4c/0x64)
[  507.401045] [<800558d0>] (warn_slowpath_common+0x4c/0x64) from [<8005597c>] (warn_slowpath_fmt+0x30/0x40)
[  507.413387] [<8005597c>] (warn_slowpath_fmt+0x30/0x40) from [<802db42c>] (dev_watchdog+0x298/0x2c0)
[  507.425223] [<802db42c>] (dev_watchdog+0x298/0x2c0) from [<80060ea4>] (run_timer_softirq+0xf4/0x23c)
[  507.437170] [<80060ea4>] (run_timer_softirq+0xf4/0x23c) from [<8005aea0>] (__do_softirq+0x98/0x130)
[  507.449063] [<8005aea0>] (__do_softirq+0x98/0x130) from [<8005b354>] (irq_exit+0x8c/0x94)
[  507.460155] [<8005b354>] (irq_exit+0x8c/0x94) from [<8002f3f0>] (handle_IRQ+0x34/0x84)
[  507.471019] [<8002f3f0>] (handle_IRQ+0x34/0x84) from [<8002e70c>] (__irq_svc+0x4c/0xa4)
[  507.482010] [<8002e70c>] (__irq_svc+0x4c/0xa4) from [<8002f500>] (default_idle+0x24/0x28)
[  507.493222] [<8002f500>] (default_idle+0x24/0x28) from [<8002f6a8>] (cpu_idle+0x84/0xb8)
[  507.504384] [<8002f6a8>] (cpu_idle+0x84/0xb8) from [<80008824>] (start_kernel+0x22c/0x26c)
[  507.515724] [<80008824>] (start_kernel+0x22c/0x26c) from [<1000803c>] (0x1000803c)
[  507.526419] ---[ end trace 1b75b31a2719ed1e ]---
[  507.532613] net eth0: fec_timeout tx_full=1 tx_insert=5a tx_remove=5a 9c00
[  507.542567] net eth0: 12000000 8c00000, 12000000
[  507.548754] net eth0: calling restart
[  509.250736] PHY: 1:00 - Link is Up - 100/Full

Thank you so much for your time and help.

Regards,
Vikram
