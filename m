From: Ongun Kanat <ongun.kanat@gmail.com>
Subject: Alx driver doesn't work on 3.7.x
Date: Sat, 26 Jan 2013 00:54:35 +0200
Message-ID: <CACFtbyjyoZC+pCLbReAh+DxRWy_d7gczm-cbWvcdPQkDvrN8qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nic-devel@qualcomm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:59399 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783Ab3AYWyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 17:54:35 -0500
Received: by mail-oa0-f51.google.com with SMTP id n12so1089375oag.38
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2013 14:54:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I don't know wheter it is the right place for it but I want to report
a bug(I think it is).
I'm a Asus N56VZ user with ArchLinux on it. It has an Atheros AR8161 ,
so I use alx driver. It was working with 3.6 series kernel but now
with 3.7.3 and
3.7.4 it stopped working. I was upgraded compat driver version
2012-12-19 to use alx with 3.7 series. When It generated errors I
tried also compat 3.7.1
and 2013-01-10-2u. Also tried a solution which says comment some lines
on 3.6.8-snpc (which is given in
http://www.linuxfoundation.org/collaborate/workgroups/networking/alx).
The first two caused same error below when I got ip connection both
with NetworkManager and ifconfig. The last solution wih 3.6.8 worked
but connection
drops always after a while.

The output of dmesg when I connected:
Jan 22 20:21:49 localhost kernel: [   33.468071] Pid: 0, comm:
swapper/0 Tainted: P           O 3.7.3-1-ARCH #1
Jan 22 20:21:49 localhost kernel: [   33.468072] Call Trace:
Jan 22 20:21:49 localhost kernel: [   33.468074]  <IRQ>
[<ffffffff8105750f>] warn_slowpath_common+0x7f/0xc0
Jan 22 20:21:49 localhost kernel: [   33.468081]  [<ffffffff81057606>]
warn_slowpath_fmt+0x46/0x50
Jan 22 20:21:49 localhost kernel: [   33.468086]  [<ffffffff814ac6be>]
? _raw_spin_unlock+0x2e/0x40
Jan 22 20:21:49 localhost kernel: [   33.468090]  [<ffffffff813ca0e3>]
dev_watchdog+0x273/0x280
Jan 22 20:21:49 localhost kernel: [   33.468093]  [<ffffffff813c9e70>]
? pfifo_fast_dequeue+0xe0/0xe0
Jan 22 20:21:49 localhost kernel: [   33.468096]  [<ffffffff810674aa>]
call_timer_fn+0x3a/0x180
Jan 22 20:21:49 localhost kernel: [   33.468098]  [<ffffffff813c9e70>]
? pfifo_fast_dequeue+0xe0/0xe0
Jan 22 20:21:49 localhost kernel: [   33.468101]  [<ffffffff81067fac>]
run_timer_softirq+0x21c/0x2c0
Jan 22 20:21:49 localhost kernel: [   33.468105]  [<ffffffff8101ca99>]
? read_tsc+0x9/0x20
Jan 22 20:21:49 localhost kernel: [   33.468108]  [<ffffffff8105ff18>]
__do_softirq+0xc8/0x240
Jan 22 20:21:49 localhost kernel: [   33.468113]  [<ffffffff810afe44>]
? tick_program_event+0x24/0x30
Jan 22 20:21:49 localhost kernel: [   33.468117]  [<ffffffff814b569c>]
call_softirq+0x1c/0x30
Jan 22 20:21:49 localhost kernel: [   33.468120]  [<ffffffff810177c5>]
do_softirq+0x65/0xa0
Jan 22 20:21:49 localhost kernel: [   33.468123]  [<ffffffff810601f6>]
irq_exit+0x96/0xc0
Jan 22 20:21:49 localhost kernel: [   33.468126]  [<ffffffff814b600e>]
smp_apic_timer_interrupt+0x6e/0x99
Jan 22 20:21:49 localhost kernel: [   33.468129]  [<ffffffff814b4f5d>]
apic_timer_interrupt+0x6d/0x80
Jan 22 20:21:49 localhost kernel: [   33.468130]  <EOI>
[<ffffffff8107ff42>] ? hrtimer_get_next_event+0xd2/0xe0
Jan 22 20:21:49 localhost kernel: [   33.468138]  [<ffffffff812c4ba0>]
? intel_idle+0xf0/0x150
Jan 22 20:21:49 localhost kernel: [   33.468140]  [<ffffffff812c4b7e>]
? intel_idle+0xce/0x150
Jan 22 20:21:49 localhost kernel: [   33.468144]  [<ffffffff81377899>]
cpuidle_enter+0x19/0x20
Jan 22 20:21:49 localhost kernel: [   33.468146]  [<ffffffff81377f86>]
cpuidle_idle_call+0xa6/0x340
Jan 22 20:21:49 localhost kernel: [   33.468149]  [<ffffffff8101ef3f>]
cpu_idle+0xbf/0x130
Jan 22 20:21:49 localhost kernel: [   33.468152]  [<ffffffff814857a0>]
rest_init+0x80/0x90
Jan 22 20:21:49 localhost kernel: [   33.468155]  [<ffffffff818cac45>]
start_kernel+0x3d1/0x3de
Jan 22 20:21:49 localhost kernel: [   33.468157]  [<ffffffff818ca673>]
? repair_env_string+0x5e/0x5e
Jan 22 20:21:49 localhost kernel: [   33.468160]  [<ffffffff818ca356>]
x86_64_start_reservations+0x131/0x135
Jan 22 20:21:49 localhost kernel: [   33.468162]  [<ffffffff818ca45a>]
x86_64_start_kernel+0x100/0x10f
Jan 22 20:21:49 localhost kernel: [   33.468164] ---[ end trace
e2e9c1c2dadb3509 ]---
Jan 22 20:21:49 localhost kernel: [   33.468168] alx 0000:04:00.0
eth0: -----------------TPD-ring(0)------------------
Jan 22 20:21:49 localhost kernel: [   33.468171] alx 0000:04:00.0
eth0: F8: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468172] alx 0000:04:00.0
eth0: F9: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468174] alx 0000:04:00.0
eth0: FA: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468176] alx 0000:04:00.0
eth0: FB: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468177] alx 0000:04:00.0
eth0: FC: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468179] alx 0000:04:00.0
eth0: FD: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468181] alx 0000:04:00.0
eth0: FE: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468182] alx 0000:04:00.0
eth0: FF: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468184] alx 0000:04:00.0
eth0: 0: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468186] alx 0000:04:00.0
eth0: 1: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468188] alx 0000:04:00.0
eth0: 2: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468189] alx 0000:04:00.0
eth0: 3: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468191] alx 0000:04:00.0
eth0: -----------------TPD-ring(1)------------------
Jan 22 20:21:49 localhost kernel: [   33.468193] alx 0000:04:00.0
eth0: F8: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468194] alx 0000:04:00.0
eth0: F9: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468196] alx 0000:04:00.0
eth0: FA: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468198] alx 0000:04:00.0
eth0: FB: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468199] alx 0000:04:00.0
eth0: FC: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468201] alx 0000:04:00.0
eth0: FD: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468203] alx 0000:04:00.0
eth0: FE: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468204] alx 0000:04:00.0
eth0: FF: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468206] alx 0000:04:00.0
eth0: 0: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468208] alx 0000:04:00.0
eth0: 1: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468209] alx 0000:04:00.0
eth0: 2: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468211] alx 0000:04:00.0
eth0: 3: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468212] alx 0000:04:00.0
eth0: -----------------TPD-ring(2)------------------
Jan 22 20:21:49 localhost kernel: [   33.468214] alx 0000:04:00.0
eth0: F8: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468216] alx 0000:04:00.0
eth0: F9: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468218] alx 0000:04:00.0
eth0: FA: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468219] alx 0000:04:00.0
eth0: FB: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468221] alx 0000:04:00.0
eth0: FC: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468222] alx 0000:04:00.0
eth0: FD: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468224] alx 0000:04:00.0
eth0: FE: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468226] alx 0000:04:00.0
eth0: FF: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468227] alx 0000:04:00.0
eth0: 0: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468229] alx 0000:04:00.0
eth0: 1: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468231] alx 0000:04:00.0
eth0: 2: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468232] alx 0000:04:00.0
eth0: 3: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468234] alx 0000:04:00.0
eth0: -----------------TPD-ring(3)------------------
Jan 22 20:21:49 localhost kernel: [   33.468236] alx 0000:04:00.0
eth0: F9: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468237] alx 0000:04:00.0
eth0: FA: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468239] alx 0000:04:00.0
eth0: FB: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468241] alx 0000:04:00.0
eth0: FC: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468243] alx 0000:04:00.0
eth0: FD: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468244] alx 0000:04:00.0
eth0: FE: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468246] alx 0000:04:00.0
eth0: FF: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468248] alx 0000:04:00.0
eth0: 0: W0=0000005A, W1=80000000, W2=224D8802
Jan 22 20:21:49 localhost kernel: [   33.468250] alx 0000:04:00.0
eth0: 1: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468251] alx 0000:04:00.0
eth0: 2: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468253] alx 0000:04:00.0
eth0: 3: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468254] alx 0000:04:00.0
eth0: 4: W0=00000000, W1=00000000, W2=0
Jan 22 20:21:49 localhost kernel: [   33.468256] alx 0000:04:00.0
eth0: ---------------dump registers-----------------
Jan 22 20:21:49 localhost kernel: [   33.468308] alx 0000:04:00.0
eth0: 1400: C0020CE0,00000000,00000064,00001C01
Jan 22 20:21:49 localhost kernel: [   33.468319] alx 0000:04:00.0
eth0: 1410: 00002800,474019AA,03FF000D,00000000
Jan 22 20:21:49 localhost kernel: [   33.468331] alx 0000:04:00.0
eth0: 1420: 00000000,E03EBB60,00000240,CF01C831
Jan 22 20:21:49 localhost kernel: [   33.468342] alx 0000:04:00.0
eth0: 1430: 0000CC01,00000000,00000000,00000010
Jan 22 20:21:49 localhost kernel: [   33.468353] alx 0000:04:00.0
eth0: 1440: 8010020C,00000020,0007801A,00000180
Jan 22 20:21:49 localhost kernel: [   33.468365] alx 0000:04:00.0
eth0: 1450: 00000000,14700040,00000040,00000000
Jan 22 20:21:49 localhost kernel: [   33.468376] alx 0000:04:00.0
eth0: 1460: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468386] alx 0000:04:00.0
eth0: 1470: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468398] alx 0000:04:00.0
eth0: 1480: 64105CEF,60405060,4828A001,000010BF
Jan 22 20:21:49 localhost kernel: [   33.468409] alx 0000:04:00.0
eth0: 1490: 80000000,40000000,07A1F037,000005F2
Jan 22 20:21:49 localhost kernel: [   33.468420] alx 0000:04:00.0
eth0: 14A0: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468431] alx 0000:04:00.0
eth0: 14B0: 3BED200D,14364D17,6A3E67EA,B855AABE
Jan 22 20:21:49 localhost kernel: [   33.468443] alx 0000:04:00.0
eth0: 14C0: E214AD3D,EA49AF7C,A54F2BEC,2A94B30D
Jan 22 20:21:49 localhost kernel: [   33.468454] alx 0000:04:00.0
eth0: 14D0: 1805EC6C,E291D73D,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468465] alx 0000:04:00.0
eth0: 14E0: 22183000,22182000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468476] alx 0000:04:00.0
eth0: 14F0: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468487] alx 0000:04:00.0
eth0: 1500: 05FF05E0,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468498] alx 0000:04:00.0
eth0: 1510: 00000020,00000000,0BDF0BC0,00000020
Jan 22 20:21:49 localhost kernel: [   33.468509] alx 0000:04:00.0
eth0: 1520: 05DF0000,000005E0,0BBF0600,000005C0
Jan 22 20:21:49 localhost kernel: [   33.468520] alx 0000:04:00.0
eth0: 1530: 06000BE0,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468531] alx 0000:04:00.0
eth0: 1540: 00000002,00000002,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468542] alx 0000:04:00.0
eth0: 1550: 22186000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468554] alx 0000:04:00.0
eth0: 1560: 00000200,000005F8,22184000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468565] alx 0000:04:00.0
eth0: 1570: 00000000,00000000,00000200,22181000
Jan 22 20:21:49 localhost kernel: [   33.468576] alx 0000:04:00.0
eth0: 1580: 22180000,00000100,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468587] alx 0000:04:00.0
eth0: 1590: 020000F5,000008BF,01800080,00000000
Jan 22 20:21:49 localhost kernel: [   33.468599] alx 0000:04:00.0
eth0: 15A0: AC8100BF,00001210,00C0044E,00000100
Jan 22 20:21:49 localhost kernel: [   33.468610] alx 0000:04:00.0
eth0: 15B0: 0F22B217,00000001,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468621] alx 0000:04:00.0
eth0: 15C0: 04047C24,00030D40,00000055,000000C8
Jan 22 20:21:49 localhost kernel: [   33.468633] alx 0000:04:00.0
eth0: 15D0: 00214321,00000000,00438765,00000000
Jan 22 20:21:49 localhost kernel: [   33.468644] alx 0000:04:00.0
eth0: 15E0: 000001FF,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468655] alx 0000:04:00.0
eth0: 15F0: 00000000,00000000,00000020,00000000
Jan 22 20:21:49 localhost kernel: [   33.468667] alx 0000:04:00.0
eth0: 1600: 01711081,7C0F96E7,00004E20,00000000
Jan 22 20:21:49 localhost kernel: [   33.468678] alx 0000:04:00.0
eth0: 1610: FFFFFFFB,00000000,00000001,00000001
Jan 22 20:21:49 localhost kernel: [   33.468689] alx 0000:04:00.0
eth0: 1620: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468700] alx 0000:04:00.0
eth0: 1630: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468711] alx 0000:04:00.0
eth0: 1640: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468721] alx 0000:04:00.0
eth0: 1650: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468732] alx 0000:04:00.0
eth0: 1660: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468743] alx 0000:04:00.0
eth0: 1670: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468755] alx 0000:04:00.0
eth0: 1680: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468766] alx 0000:04:00.0
eth0: 1690: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468776] alx 0000:04:00.0
eth0: 16A0: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468788] alx 0000:04:00.0
eth0: 16B0: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468799] alx 0000:04:00.0
eth0: 16C0: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468809] alx 0000:04:00.0
eth0: 16D0: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468820] alx 0000:04:00.0
eth0: 16E0: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468831] alx 0000:04:00.0
eth0: 16F0: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468842] alx 0000:04:00.0
eth0: 1700: 00000005,00000003,00000002,00000000
Jan 22 20:21:49 localhost kernel: [   33.468853] alx 0000:04:00.0
eth0: 1710: 00000000,00000000,00000000,000001AC
Jan 22 20:21:49 localhost kernel: [   33.468864] alx 0000:04:00.0
eth0: 1720: 00000000,00000000,00000001,00000007
Jan 22 20:21:49 localhost kernel: [   33.468875] alx 0000:04:00.0
eth0: 1730: 0000000D,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468886] alx 0000:04:00.0
eth0: 1740: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468897] alx 0000:04:00.0
eth0: 1750: 00000000,0000010A,000000A2,00000010
Jan 22 20:21:49 localhost kernel: [   33.468908] alx 0000:04:00.0
eth0: 1760: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468918] alx 0000:04:00.0
eth0: 1770: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468928] alx 0000:04:00.0
eth0: 1780: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468939] alx 0000:04:00.0
eth0: 1790: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468951] alx 0000:04:00.0
eth0: 17A0: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468962] alx 0000:04:00.0
eth0: 17B0: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468973] alx 0000:04:00.0
eth0: 17C0: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468985] alx 0000:04:00.0
eth0: 17D0: 00000000,00000001,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.468996] alx 0000:04:00.0
eth0: 17E0: 00000000,0000005A,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.469007] alx 0000:04:00.0
eth0: 17F0: 00000000,00000000,00000000,00000000
Jan 22 20:21:49 localhost kernel: [   33.469023] alx 0000:04:00.0
eth0: task:alx_reinit

Thanks.
