From: Marek Vasut <marek.vasut@gmail.com>
Subject: pandaboard brctl oops
Date: Mon, 1 Aug 2011 23:25:16 +0200
Message-ID: <201108012325.17312.marek.vasut@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	m.kloucek.m@gmail.com
To: netdev@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

recently a friend of mine sent me this backtrace. I put him in CC so please any 
subsequent questions shall be forwarded to him.

He claims this happens on pandaboard.

Cheers

root@box:~# brctl addbr br0
root@box:~# brctl addif br0 eth0
[   77.795776] Unable to handle kernel NULL pointer dereference at virtual 
address 00000000
[   77.804321] pgd = ee8d4000
[   77.807312] [00000000] *pgd=af8e6831, *pte=00000000, *ppte=00000000
[   77.813995] Internal error: Oops: 80000007 [#1] SMP
[   77.819122] last sysfs file: /sys/devices/virtual/net/br0/uevent
[   77.825439] Modules linked in: bridge stp llc wl12xx_sdio wl12xx
[   77.831787] CPU: 0    Not tainted  (2.6.39.2-omap4 #3)
[   77.837188] PC is at 0x0
[   77.839904] LR is at br_change_mtu+0x64/0x7c [bridge]
[   77.845214] pc : [<00000000>]    lr : [<bf068260>]    psr: 20000013
[   77.845214] sp : ef25de58  ip : ef937e08  fp : 00000000
[   77.857299] r10: 00000001  r9 : ef25c000  r8 : 00000000
[   77.862762] r7 : ef937f00  r6 : ef280540  r5 : ef280000  r4 : 000005d4
[   77.869628] r3 : 00000000  r2 : ef280560  r1 : bf0729e9  r0 : ef280994
[   77.876495] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
[   77.883972] Control: 10c5387d  Table: ae8d404a  DAC: 00000015
[   77.890014] Process brctl (pid: 4290, stack limit = 0xef25c2f8)
[   77.896240] Stack: (0xef25de58 to 0xef25e000)
[   77.900817] de40:                                                       
ef280000 ee88a800
[   77.909393] de60: ef280540 c0390f54 ef280000 bf069d98 00000000 ef25ded0 
ef280000 000089a2
[   77.917999] de80: ef25ded0 00000000 00000000 c0392390 000089a2 ef25ded0 
c0c09da0 c03929f4
[   77.926605] dea0: 00000002 00000000 0000006c 00000000 00000000 00000001 
00000000 ef68bd94
[   77.935180] dec0: ef68bd80 00000000 ef68bd80 ef68bd80 00307262 00000000 
00000000 00000000
[   77.943786] dee0: 00000002 bed89d78 4004b450 bed89e79 00000000 c0bf3bc8 
bed89bbc c171c340
[   77.952362] df00: 000089a2 00000003 00000000 ef25c000 00000000 c011f958 
0000c000 c0120058
[   77.960968] df20: 00000000 00000000 eacec460 ef820620 ef25c000 c0668464 
ef82063c c004c248
[   77.969573] df40: ef25c000 00000000 00000000 c012ae44 00000002 00000000 
ef820620 ef25c000
[   77.978149] df60: c17d4a60 c171c340 bed89bbc 000089a2 00000003 00000000 
ef25c000 00000000
[   77.986755] df80: 00000000 c01200ec 00000003 00000000 bed89e7f bed89e83 
00000001 00000036
[   77.995361] dfa0: c004c248 c004c080 bed89e7f bed89e83 00000003 000089a2 
bed89bbc bed89bbc
[   78.003936] dfc0: bed89e7f bed89e83 00000001 00000036 bed89d78 00000000 
4005b000 00000000
[   78.012542] dfe0: 40220c30 bed89b94 0000b0c3 40220c3c 80000010 00000003 
0000b10d 04070000
[   78.021148] [<bf068260>] (br_change_mtu+0x64/0x7c [bridge]) from [<c0390f54>] 
(dev_set_mtu+0x44/0x7c)
[   78.030883] [<c0390f54>] (dev_set_mtu+0x44/0x7c) from [<bf069d98>] 
(br_add_if+0x2fc/0x3cc [bridge])
[   78.040405] [<bf069d98>] (br_add_if+0x2fc/0x3cc [bridge]) from [<c0392390>] 
(dev_ifsioc+0x294/0x2b0)
[   78.049987] [<c0392390>] (dev_ifsioc+0x294/0x2b0) from [<c03929f4>] 
(dev_ioctl+0x648/0x748)
[   78.058776] [<c03929f4>] (dev_ioctl+0x648/0x748) from [<c011f958>] 
(vfs_ioctl+0x20/0x3c)
[   78.067291] [<c011f958>] (vfs_ioctl+0x20/0x3c) from [<c0120058>] 
(do_vfs_ioctl+0x4e8/0x530)
[   78.076080] [<c0120058>] (do_vfs_ioctl+0x4e8/0x530) from [<c01200ec>] 
(sys_ioctl+0x4c/0x6c)
[   78.084869] [<c01200ec>] (sys_ioctl+0x4c/0x6c) from [<c004c080>] 
(ret_fast_syscall+0x0/0x3c)
[   78.093749] Code: bad PC value
[   78.098571] ---[ end trace 735bf785e3a5afd2 ]---
Segmentation fault

