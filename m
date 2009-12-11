From: Kevin Constantine <kevin.constantine@gmail.com>
Subject: Kernel Panics in the network stack
Date: Fri, 11 Dec 2009 13:09:06 -0800
Message-ID: <4B22B4F2.8080605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.211.173]:50042 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758877AbZLKVJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 16:09:01 -0500
Received: by ywh3 with SMTP id 3so1302862ywh.22
        for <netdev@vger.kernel.org>; Fri, 11 Dec 2009 13:09:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Everyone-

I've been playing with an ARM based linuxstamp 
http://opencircuits.com/Linuxstamp, and I've been seeing kernel panics 
with both 2.6.28.3, and 2.6.30 within an hour or so of turning the 
linuxstamp on.  The stack traces always seem to point at functions 
related to networking.  I've pasted a couple of the crash outputs below. 
  The linuxstamp isn't typically doing anything when the crashes occur, 
in fact it'll crash even if I haven't logged in.

If I ifconfig the interface down, the linuxstamp stays up indefinitely. 
  Any pointers in one direction or another would be much appreciated.

I'm not sure if this is the right audience to help out or if the arm 
lists might be better.  But in any event, any help would be really 
appreciated.


linuxstamp login: Unable to handle kernel paging request at virtual 
address 183cb7b0
pgd = c0004000
[183cb7b0] *pgd=00000000
Internal error: Oops: 0 [#1] PREEMPT
Modules linked in:
CPU: 0    Not tainted  (2.6.30-00002-g0148992 #13)
PC is at 0x183cb7b0
LR is at __udp4_lib_rcv+0x43c/0x72c
pc : [<183cb7b0>]    lr : [<c024ff4c>]    psr: 40000013
sp : c0381e70  ip : c0381e20  fp : c0386ea0
r10: 00000008  r9 : c03bce68  r8 : 00000000
r7 : c03bd254  r6 : c03bcc0c  r5 : c1e5bd80  r4 : c03a2848
r3 : 00000000  r2 : c0380000  r1 : 00000075  r0 : 00000000
Flags: nZcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
Control: c000717f  Table: 21d5c000  DAC: 00000017
Process swapper (pid: 0, stack limit = 0xc0380268)
Stack: (0xc0381e70 to 0xc0382000)
1e60:                                     c1d21800 c1db6830 c1e5bd80 
c03a28d4
1e80: c1d21800 c022f288 c1d21800 00000001 c1db1000 c026fb08 c03bce48 
c1e5bd80
1ea0: c03a28d4 c1d21800 00000000 c0216500 0000012c c03a0688 00000001 
c03a06a4
1ec0: ffffafc1 00000040 00000000 c03a068c c03a0688 c02165e4 ffffffff 
c03a06a4
1ee0: 00000040 c0380000 0000012c c03a0688 c03bce58 ffffafc3 c03a0698 
c0214d94
1f00: c1e5bd80 00000103 0000000c c0380000 00000001 c03aa7d8 00000000 
0000000a
1f20: 00000000 c0040358 c0380000 2001cf88 00000000 00000018 00000000 
00000018
1f40: 00000002 00000001 c0380000 2001cf88 00000000 c0040428 00000018 
c0022060
1f60: 00000000 ffffffff fefff000 c0022a3c 00000000 00000001 00000080 
60000013
1f80: c00243a4 c0380000 c0383ebc c00243a4 c03a5c28 41129200 2001cf88 
00000000
1fa0: fefff800 c0381fb8 c00243e0 c00243ec 60000013 ffffffff c00243a4 
c0024368
1fc0: c03ad2d4 c03a5bf0 c001ed30 c0383d08 2001cfbc c00088d4 c0008434 
00000000
1fe0: 00000000 c001ed30 c0007175 c03a5c58 c001f134 20008034 00000000 
00000000
Code: bad PC value.
Kernel panic - not syncing: Fatal exception in interrupt
[<c002895c>] (unwind_backtrace+0x0/0xdc) from [<c02b342c>] 
(panic+0x3c/0x120)
[<c02b342c>] (panic+0x3c/0x120) from [<c0026e60>] (die+0x154/0x180)
[<c0026e60>] (die+0x154/0x180) from [<c0029848>] 
(__do_kernel_fault+0x68/0x80)
[<c0029848>] (__do_kernel_fault+0x68/0x80) from [<c0029a74>] 
(do_page_fault+0x214/0x234)
[<c0029a74>] (do_page_fault+0x214/0x234) from [<c0022b40>] 
(__pabt_svc+0x40/0x80)
[<c0022b40>] (__pabt_svc+0x40/0x80) from [<c024ff4c>] 
(__udp4_lib_rcv+0x43c/0x72c)
[<c024ff4c>] (__udp4_lib_rcv+0x43c/0x72c) from [<c03a06a4>] (0xc03a06a4)


linuxstamp:~# Unable to handle kernel paging request at virtual address 
ffffff42
pgd = c0004000
[ffffff42] *pgd=20407031, *pte=00000000, *ppte=00000000
Internal error: Oops: 17 [#1] PREEMPT
Modules linked in:
CPU: 0    Not tainted  (2.6.30-00002-g0148992 #13)
PC is at process_backlog+0x8c/0xd8
LR is at netif_receive_skb+0x2ac/0x2e8
pc : [<c02165e4>]    lr : [<c021651c>]    psr: 40000013
sp : c0381ed8  ip : c0381eb0  fp : c0386ea0
r10: c03a0688  r9 : c03a068c  r8 : 00000000
r7 : 00000040  r6 : 000cbc7e  r5 : c03a06a4  r4 : 00000001
r3 : 00000000  r2 : c0380000  r1 : 00000062  r0 : 00000000
Flags: nZcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
Control: c000717f  Table: 21d5c000  DAC: 00000017
Process swapper (pid: 0, stack limit = 0xc0380268)
Stack: (0xc0381ed8 to 0xc0382000)
1ec0:                                                       00000001 
c03a06a4
1ee0: 00000040 c0380000 0000012c c03a0688 c03bce58 000cbc80 c03a0698 
c0214d94
1f00: c1e76500 00000103 0000000c c0380000 00000001 c03aa7d8 00000000 
0000000a
1f20: 00000000 c0040358 c0380000 2001cf88 00000000 00000018 00000000 
00000018
1f40: 00000002 00000001 c0380000 2001cf88 00000000 c0040428 00000018 
c0022060
1f60: 00000000 ffffffff fefff000 c0022a3c 00000000 00000001 00000080 
60000013
1f80: c00243a4 c0380000 c0383ebc c00243a4 c03a5c28 41129200 2001cf88 
00000000
1fa0: fefff800 c0381fb8 c00243e0 c00243ec 60000013 ffffffff c00243a4 
c0024368
1fc0: c03ad2d4 c03a5bf0 c001ed30 c0383d08 2001cfbc c00088d4 c0008434 
00000000
1fe0: 00000000 c001ed30 c0007175 c03a5c58 c001f134 20008034 00000000 
00000000
[<c02165e4>] (process_backlog+0x8c/0xd8) from [<c0214d94>] 
(net_rx_action+0x68/0x170)
[<c0214d94>] (net_rx_action+0x68/0x170) from [<c0040358>] 
(__do_softirq+0x74/0x104)
[<c0040358>] (__do_softirq+0x74/0x104) from [<c0040428>] 
(irq_exit+0x40/0x58)
[<c0040428>] (irq_exit+0x40/0x58) from [<c0022060>] (_text+0x60/0x78)
[<c0022060>] (_text+0x60/0x78) from [<c0022a3c>] (__irq_svc+0x3c/0x80)
Exception stack(0xc0381f70 to 0xc0381fb8)
1f60:                                     00000000 00000001 00000080 
60000013
1f80: c00243a4 c0380000 c0383ebc c00243a4 c03a5c28 41129200 2001cf88 
00000000
1fa0: fefff800 c0381fb8 c00243e0 c00243ec 60000013 ffffffff
[<c0022a3c>] (__irq_svc+0x3c/0x80) from [<c00243e0>] 
(default_idle+0x3c/0x54)
[<c00243e0>] (default_idle+0x3c/0x54) from [<c0024368>] (cpu_idle+0x48/0x84)
[<c0024368>] (cpu_idle+0x48/0x84) from [<c00088d4>] 
(start_kernel+0x208/0x254)
[<c00088d4>] (start_kernel+0x208/0x254) from [<20008034>] (0x20008034)
Code: e3c33080 e121f003 e2844001 ebffff22 (e1540007)
Kernel panic - not syncing: Fatal exception in interrupt
[<c002895c>] (unwind_backtrace+0x0/0xdc) from [<c02b342c>] 
(panic+0x3c/0x120)
[<c02b342c>] (panic+0x3c/0x120) from [<c0026e60>] (die+0x154/0x180)
[<c0026e60>] (die+0x154/0x180) from [<c0029848>] 
(__do_kernel_fault+0x68/0x80)
[<c0029848>] (__do_kernel_fault+0x68/0x80) from [<c0029a74>] 
(do_page_fault+0x214/0x234)
[<c0029a74>] (do_page_fault+0x214/0x234) from [<c0022244>] 
(do_DataAbort+0x30/0x90)
[<c0022244>] (do_DataAbort+0x30/0x90) from [<c00229e0>] 
(__dabt_svc+0x40/0x60)
Exception stack(0xc0381e90 to 0xc0381ed8)
1e80:                                     00000000 00000062 c0380000 
00000000
1ea0: 00000001 c03a06a4 000cbc7e 00000040 00000000 c03a068c c03a0688 
c0386ea0
1ec0: c0381eb0 c0381ed8 c021651c c02165e4 40000013 ffffffff
[<c00229e0>] (__dabt_svc+0x40/0x60) from [<c021651c>] 
(netif_receive_skb+0x2ac/0x2e8)
[<c021651c>] (netif_receive_skb+0x2ac/0x2e8) from [<c0214d94>] 
(net_rx_action+0x68/0x170)
[<c0214d94>] (net_rx_action+0x68/0x170) from [<c0040358>] 
(__do_softirq+0x74/0x104)
[<c0040358>] (__do_softirq+0x74/0x104) from [<c0040428>] 
(irq_exit+0x40/0x58)
[<c0040428>] (irq_exit+0x40/0x58) from [<c0022060>] (_text+0x60/0x78)
[<c0022060>] (_text+0x60/0x78) from [<c0022a3c>] (__irq_svc+0x3c/0x80)
Exception stack(0xc0381f70 to 0xc0381fb8)
1f60:                                     00000000 00000001 00000080 
60000013
1f80: c00243a4 c0380000 c0383ebc c00243a4 c03a5c28 41129200 2001cf88 
00000000
1fa0: fefff800 c0381fb8 c00243e0 c00243ec 60000013 ffffffff
[<c0022a3c>] (__irq_svc+0x3c/0x80) from [<c00243e0>] 
(default_idle+0x3c/0x54)
[<c00243e0>] (default_idle+0x3c/0x54) from [<c0024368>] (cpu_idle+0x48/0x84)
[<c0024368>] (cpu_idle+0x48/0x84) from [<c00088d4>] 
(start_kernel+0x208/0x254)
[<c00088d4>] (start_kernel+0x208/0x254) from [<20008034>] (0x20008034)

Thanks a lot
-kevin
