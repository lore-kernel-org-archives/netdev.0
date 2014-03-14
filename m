From: Marek Vasut <marex@denx.de>
Subject: Re: i.MX53 FEC transmit queue time out
Date: Sat, 15 Mar 2014 00:30:26 +0100
Message-ID: <201403150030.26633.marex@denx.de>
References: <OFAFB0971F.21693429-ON87257C9B.005FED63-87257C9B.0061C94A@grpleg.it>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: fabio.estevam@freescale.com, netdev@vger.kernel.org,
	b38611@freescale.com, frank.li@freescale.com,
	jim_baxter@mentor.com, dzu@denx.de, fugang.duan@freescale.com,
	Eric Nelson <eric.nelson@boundarydevices.com>
To: robert.daniels@vantagecontrols.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:40655 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754050AbaCNX5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 19:57:07 -0400
In-Reply-To: <OFAFB0971F.21693429-ON87257C9B.005FED63-87257C9B.0061C94A@grpleg.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, March 14, 2014 at 06:48:05 PM, robert.daniels@vantagecontrols.com 
wrote:
> Fabio,
> 
> I'm experiencing an fec transmit issue with the 3.14-rc6 kernel on a i.MX53
> Quick Start Board.  In my test the kernel will report the following when a
> 'pause' in packet transmission occurs:
> 
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 0
> at
> /home/robertd/Development/IC/Dev/BoardSupport/ic-ii/linux-mainline/net/sch
> ed/sch_generic.c:264 dev_watchdog+0x288/0x2ac()
> NETDEV WATCHDOG: eth0 (fec): transmit queue 0 timed out
> Modules linked in:
> CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.14.0-rc6+ #3
> Backtrace:
> [<800121bc>] (dump_backtrace) from [<800124a0>] (show_stack+0x18/0x1c)
>  r6:8051f034 r5:00000000 r4:808edb9c r3:00000000
> [<80012488>] (show_stack) from [<80651e30>] (dump_stack+0x84/0x9c)
> [<80651dac>] (dump_stack) from [<80027d1c>] (warn_slowpath_common
> +0x70/0x94)
>  r5:00000009 r4:808c9d60
> [<80027cac>] (warn_slowpath_common) from [<80027d78>] (warn_slowpath_fmt
> +0x38/0x40)
>  r8:ded37b40 r7:808c8000 r6:ded37b00 r5:dec34000 r4:00000000
> [<80027d44>] (warn_slowpath_fmt) from [<8051f034>] (dev_watchdog
> +0x288/0x2ac)
>  r3:dec34000 r2:80832508
> [<8051edac>] (dev_watchdog) from [<80031e68>] (call_timer_fn+0x74/0xf4)
>  r10:80031df4 r9:dec34000 r8:8051edac r7:808c8000 r6:00000100 r5:808c8000
>  r4:808c9dd0
> [<80031df4>] (call_timer_fn) from [<80032598>] (run_timer_softirq
> +0x19c/0x234)
>  r10:8051edac r9:dec34000 r8:00200200 r7:00000000 r6:808c9e20 r5:80929fc0
>  r4:dec34284
> [<800323fc>] (run_timer_softirq) from [<8002c2f4>] (__do_softirq
> +0x110/0x2b4)
>  r10:00000100 r9:00000001 r8:40000001 r7:808c8000 r6:808ca080 r5:808ca084
>  r4:00000000
> [<8002c1e4>] (__do_softirq) from [<8002c7ac>] (irq_exit+0xb8/0x10c)
>  r10:8065b4cc r9:00000001 r8:00000000 r7:00000037 r6:808c8000 r5:808c4fe8
>  r4:808c8028
> [<8002c6f4>] (irq_exit) from [<8000f2a0>] (handle_IRQ+0x5c/0xbc)
>  r5:808c4fe8 r4:808d0d24
> [<8000f244>] (handle_IRQ) from [<80008590>] (tzic_handle_irq+0x78/0xa8)
>  r8:808c9f10 r7:00000001 r6:00000020 r5:80928fd8 r4:00000000 r3:00000080
> [<80008518>] (tzic_handle_irq) from [<800130a4>] (__irq_svc+0x44/0x5c)
> Exception stack(0x808c9f10 to 0x808c9f58)
> 9f00:                                     00000001 00000001 00000000
> 808d3e70
> 9f20: 808c8000 808d099c 808d0938 8092837d 00000000 808c8000 8065b4cc
> 808c9f64
> 9f40: 808c9f28 808c9f58 800638e0 8000f674 20000013 ffffffff
>  r9:808c8000 r8:00000000 r7:808c9f44 r6:ffffffff r5:20000013 r4:8000f674
> [<8000f64c>] (arch_cpu_idle) from [<8006e874>] (cpu_startup_entry
> +0x108/0x160)
> [<8006e76c>] (cpu_startup_entry) from [<8064cc24>] (rest_init+0xb4/0xdc)
>  r7:808b7358
> [<8064cb70>] (rest_init) from [<80878b58>] (start_kernel+0x328/0x38c)
>  r6:ffffffff r5:808d0880 r4:808d0a30
> [<80878830>] (start_kernel) from [<70008074>] (0x70008074)
> ---[ end trace cdbcbb8ba9a01909 ]---
> 
> Once this initial report occurs, the 'pause' will still periodically occur
> but the report from the kernel will not.
> 
> The test that I'm running is as follows:
> 
> 1. Make available a large file via http on your development machine (mine
> was about 22 MB).
> 2. Run 'iperf3 -s V' on your development machine.
> 3. Run 'iperf3 -c 192.168.1.101 -u -l 64 -b 55M -V -t 1000' from a ssh
> login on the i.MX53 QSB.
> 4. Run 'cd /tmp; while true; do date; wget http://path/to/test.bmp; rm
> -fv /tmp/test.bmp; done' from a ssh login on the i.MX53 QSB.
> 5. Monitor the iperf3 output on your development machine - within about 5
> minutes you will see output indicating that no packets were received.
> 6. Look for a report from the kernel about the transmit timeout.
> 
> Any ideas on what is causing this?

Welcome to the angry crowd, Robert ;-)

We know about this problem and we are fighting this for about half a year now on 
a couple of i.MX6 designs. We tried contacting FSL via multiple routes and we 
were never able to get any help on this. Freescale support was either never able 
to replicate the issue (even with very precise instructions) or told us off 
because we do not use the official 3.0.35-4.1.0 stuff (where the issue is also 
present, but manifests as dips in transmission speed).

You can find other similar cases of this issue, here are a few examples:
https://community.freescale.com/thread/316594
http://www.spinics.net/lists/netdev/msg268190.html
http://lists.infradead.org/pipermail/linux-arm-kernel/2013-October/202519.html
etc...

So apparently, the issue is present, yet is ignored ... for whatever reasons. We 
are still pushing this with FSL and if we ever find a solution for this, we will 
let you all know of course.
