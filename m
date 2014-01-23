From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: Freescale FEC packet loss
Date: Thu, 23 Jan 2014 01:49:48 +0000
Message-ID: <1288e1f778f74c669ad15b62d32e8859@BLUPR03MB373.namprd03.prod.outlook.com>
References: <201401222255.29467.marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	Hector Palacios <hector.palacios@digi.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Detlev Zundel <dzu@denx.de>,
	"Eric Nelson" <eric.nelson@boundarydevices.com>
To: Marek Vasut <marex@denx.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [207.46.163.211] ([207.46.163.211]:46091 "EHLO
	na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753330AbaAWBuN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 20:50:13 -0500
In-Reply-To: <201401222255.29467.marex@denx.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Marek,


From: Marek Vasut <marex@denx.de>
Data: Thursday, January 23, 2014 5:55 AM
>To: netdev@vger.kernel.org
>Cc: Li Frank-B20596; Duan Fugang-B38611; Estevam Fabio-R49496; Hector Palacios;
>linux-arm-kernel@lists.infradead.org; Detlev Zundel; Eric Nelson
>Subject: Freescale FEC packet loss
>
>Hi guys,
>
>I am running stock Linux 3.13 on i.MX6Q SabreLite board. The CPU is i.MX6Q TO
>1.0 .
>
>I am hitting a WARNING when I use the FEC ethernet to transfer data, thus I
>started investigating this problem. TL;DR I am not able to figure this problem
>out, so I am not attaching a patch :-(
>
>Steps to reproduce:
>-------------------
>1) Boot stock Linux 3.13 on i.MX6Q SabreLite board
>2) Plug in an SD card into one of the SD slots (I use the full-size one)
>3) Plug in an USB stick into one of the USB ports (I use the upper one)
>4) Plug in an ethernet cable into the board
>   -> Connect the other side into a gigabit-capable PC
>   -> Let us assume the PC has IP address 192.168.1.1/24 and
>      the board 192.168.1.2/24
>5) Install iperf on both boards
>6) Bring up the ethernet link on both ends:
>   $ ifconfig ...
>7) On the PC, run:
>   $ iperf -s -i 1
>8) Start producing load on the in-CPU busses. Run this on the board:
>   $ sha1sum /dev/mmcblk0 &
>   $ sha1sum /dev/sda &
>9) Now let the board generate ethernet traffic:
>   $ iperf -c 192.168.1.1 -t 1000 -i 1
>
>Now wait about 10 minutes and the system will produce a warning and you will
>observe dips in the transmission speed. You can see the output at the end of
>the email.
>
>I observe that this happens more often when there is a severe load on the
>busses, which in this case I simulate by running the sha1sum on /dev/mmcblk0
>and sha1sum /dev/sda in the background in step 8) . I can also well simulate
>this by running 'sha1sum /dev/mmcblk0 & sha1sum /dev/mmcblk1 &' when I have
>both SD cards populated on the MX6Q sabrelite with the same result (WARNING and
>dips in speed).
>
>There was apparently a thread about this problem already [1] where the person
>used SATA to produce high bus load and had exactly the same result.
>
>One more observation is that I managed to replicate this problem all the way
>back to Linux 3.3.8 , which is one of the first kernel versions where sabrelite
>was supported. I also see this one the Freescale's 3.0.35-4.1.0 .
>
>I have trouble figuring out what this problem is all about. Can you please help
>me? Thank you!
>
>[1] http://lists.infradead.org/pipermail/linux-arm-kernel/2013-
>October/202519.html
>
>root@(none):~# iperf -c 192.168.1.1 -t 1000 -i 1
>------------------------------------------------------------
>Client connecting to 192.168.1.1, TCP port 5001 TCP window size: 43.8 KByte
>(default)
>------------------------------------------------------------
>[  3] local 192.168.1.128 port 36760 connected with 192.168.1.1 port 5001
>[ ID] Interval       Transfer     Bandwidth
>[  3]  0.0- 1.0 sec  25.5 MBytes   214 Mbits/sec
>[  3]  1.0- 2.0 sec  28.9 MBytes   242 Mbits/sec
>[  3]  2.0- 3.0 sec  24.1 MBytes   202 Mbits/sec
>[  3]  3.0- 4.0 sec  21.1 MBytes   177 Mbits/sec
>[  3]  4.0- 5.0 sec  20.2 MBytes   170 Mbits/sec
>[  3]  5.0- 6.0 sec  20.0 MBytes   168 Mbits/sec
>[  3]  6.0- 7.0 sec  20.0 MBytes   168 Mbits/sec
>[  3]  7.0- 8.0 sec  20.1 MBytes   169 Mbits/sec
>[  3]  8.0- 9.0 sec  20.5 MBytes   172 Mbits/sec
>[  3]  9.0-10.0 sec  21.5 MBytes   180 Mbits/sec
>[  3] 10.0-11.0 sec  20.0 MBytes   168 Mbits/sec
>[  3] 11.0-12.0 sec  19.4 MBytes   163 Mbits/sec
>[  3] 12.0-13.0 sec  19.6 MBytes   165 Mbits/sec
>[  3] 13.0-14.0 sec  19.8 MBytes   166 Mbits/sec
>[  3] 14.0-15.0 sec  19.4 MBytes   163 Mbits/sec
>[  275.945247] ------------[ cut here ]------------ [  275.949920] WARNING: CPU:
>3 PID: 1155 at net/sched/sch_generic.c:264
>dev_watchdog+0x280/0x2a4()
>[  275.958679] NETDEV WATCHDOG: eth3 (fec): transmit queue 0 timed out
>[  275.964985] Modules linked in:
>[  275.968096] CPU: 3 PID: 1155 Comm: sha1sum Not tainted 3.13.0 #18
>[  275.974217] Backtrace:
>[  275.976787] [<80012410>] (dump_backtrace+0x0/0x10c) from [<800125ac>]
>(show_stack+0x18/0x1c)
>[  275.985271]  r6:00000108 r5:00000009 r4:00000000 r3:00000000
>[  275.991050] [<80012594>] (show_stack+0x0/0x1c) from [<8060f9c8>]
>(dump_stack+0x80/0x9c)
>[  275.999103] [<8060f948>] (dump_stack+0x0/0x9c) from [<8002703c>]
>(warn_slowpath_common+0x6c/0x90)
>[  276.008017]  r4:bef43e10 r3:bef96c00
>[  276.011663] [<80026fd0>] (warn_slowpath_common+0x0/0x90) from [<80027104>]
>(warn_slowpath_fmt+0x3)
>[  276.021170]  r8:bf098240 r7:bef42000 r6:bf098200 r5:bf068000 r4:00000000
>[  276.028083] [<800270cc>] (warn_slowpath_fmt+0x0/0x40) from [<804e2754>]
>(dev_watchdog+0x280/0x2a4)
>[  276.037095]  r3:bf068000 r2:807d2fb4
>[  276.040734] [<804e24d4>] (dev_watchdog+0x0/0x2a4) from [<80030e1c>]
>(call_timer_fn+0x70/0xec)
>[  276.049313] [<80030dac>] (call_timer_fn+0x0/0xec) from [<80031a90>]
>(run_timer_softirq+0x198/0x23)
>[  276.058407]  r8:00200200 r7:00000000 r6:bef43ec8 r5:bf836000 r4:bf068284
>[  276.065257] [<800318f8>] (run_timer_softirq+0x0/0x230) from [<8002b480>]
>(__do_softirq+0x100/0x25)
>[  276.074338] [<8002b380>] (__do_softirq+0x0/0x254) from [<8002b9a8>]
>(irq_exit+0xb0/0x108)
>[  276.082570] [<8002b8f8>] (irq_exit+0x0/0x108) from [<8000f3dc>]
>(handle_IRQ+0x58/0xb8)
>[  276.090528]  r4:8086ccc8 r3:00000184
>[  276.094162] [<8000f384>] (handle_IRQ+0x0/0xb8) from [<80008640>]
>(gic_handle_irq+0x30/0x64)
>[  276.102552]  r8:5590d9fa r7:f4000100 r6:bef43fb0 r5:8086ce14 r4:f400010c
>r3:000000a0
>[  276.110575] [<80008610>] (gic_handle_irq+0x0/0x64) from [<800133a0>]
>(__irq_usr+0x40/0x60)
>[  276.118871] Exception stack(0xbef43fb0 to 0xbef43ff8)
>[  276.123942] 3fa0:                                     fbe9d585 13e98d33
>6ed9eba1 21e67a57
>[  276.132173] 3fc0: 170dd9fc bc58d89e 5d1b7878 c19f2bf4 5590d9fa 2577bcc4
>7b2ac1ea 6cee44dd [  276.140398] 3fe0: cf486f09 7ea92a58 0000ba1f 0000ab72
>a0000030 ffffffff [  276.147041]  r7:c19f2bf4 r6:ffffffff r5:a0000030
>r4:0000ab72 [  276.152846] ---[ end trace 054500acb8edb763 ]---
>[  3] 15.0-16.0 sec  18.8 MBytes   157 Mbits/sec
>[  3] 16.0-17.0 sec  0.00 Bytes  0.00 bits/sec [  3] 17.0-18.0 sec  0.00 Bytes
>0.00 bits/sec [  3] 18.0-19.0 sec  0.00 Bytes  0.00 bits/sec [  3] 19.0-20.0
>sec  4.25 MBytes  35.7 Mbits/sec
>[  3] 20.0-21.0 sec  19.8 MBytes   166 Mbits/sec
>[  3] 21.0-22.0 sec  19.8 MBytes   166 Mbits/sec
>[  3] 22.0-23.0 sec  19.5 MBytes   164 Mbits/sec
>[  3] 23.0-24.0 sec  8.38 MBytes  70.3 Mbits/sec [  3] 24.0-25.0 sec  0.00
>Bytes  0.00 bits/sec [  3] 25.0-26.0 sec  7.88 MBytes  66.1 Mbits/sec
>[  3] 26.0-27.0 sec  20.1 MBytes   169 Mbits/sec
>[...]
>[  3] 71.0-72.0 sec  23.4 MBytes   196 Mbits/sec
>[  3] 72.0-73.0 sec  12.2 MBytes   103 Mbits/sec
>[  3] 73.0-74.0 sec  0.00 Bytes  0.00 bits/sec [  3] 74.0-75.0 sec  0.00 Bytes
>0.00 bits/sec [  3] 75.0-76.0 sec  10.9 MBytes  91.2 Mbits/sec
>[  3] 76.0-77.0 sec  22.4 MBytes   188 Mbits/sec
>[  3] 77.0-78.0 sec  23.0 MBytes   193 Mbits/sec
>

I will debug the issue when I am free, and then report the result to you.
Thanks for your reporting the issue.

Thanks,
Andy
