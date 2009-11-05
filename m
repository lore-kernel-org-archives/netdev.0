From: Daniel Mack <daniel@caiaq.de>
Subject: Libertas related kernel crash
Date: Thu, 5 Nov 2009 13:05:49 +0100
Message-ID: <20091105120549.GQ14091@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Michael Hirsch <m.hirsch@raumfeld.com>
To: netdev@vger.kernel.org, libertas-dev@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:52505 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754318AbZKEMFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 07:05:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On an ARM (PXA300) embdedded platform with a libertas chip connected via
SDIO, we happen to see the kernel Ooops below once in a while.

Any pointer on where to dig?

Daniel


[ 2659.715112] Unable to handle kernel NULL pointer dereference at virtual address 00000001
[ 2659.723164] pgd = c5ca8000
[ 2659.725846] [00000001] *pgd=a5cbc031, *pte=00000000, *ppte=00000000
[ 2659.732062] Internal error: Oops: 13 [#4]
[ 2659.736041] last sysfs file: /sys/devices/platform/pxa2xx-mci.0/mmc_host/mmc0/mmc0:0001/mmc0:0001:1/net/wlan0/address
[ 2659.746573] Modules linked in: eeti_ts libertas_sdio pxamci ds2760_battery w1_ds2760 wire
[ 2659.754698] CPU: 0    Tainted: G      D     (2.6.32-rc6 #1)
[ 2659.760255] PC is at kmem_cache_alloc+0x30/0x90
[ 2659.764774] LR is at inet_bind_bucket_create+0x18/0x5c
[ 2659.769876] pc : [<c00a28d8>]    lr : [<c02a4b24>]    psr: 20000093
[ 2659.769887] sp : c5c27d88  ip : c78ae4a0  fp : 00006e49
[ 2659.781279] r10: 00008928  r9 : c04fcfac  r8 : c0532148
[ 2659.786466] r7 : 00000020  r6 : 00000020  r5 : 60000013  r4 : 00000001
[ 2659.792945] r3 : 00000000  r2 : c78ae4a0  r1 : 00000020  r0 : c04d42e4
[ 2659.799427] Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM Segment user
[ 2659.806602] Control: 0000397f  Table: a5ca8018  DAC: 00000015
[ 2659.812304] Process p0-renderer (pid: 1527, stack limit = 0xc5c26278)
[ 2659.818697] Stack: (0xc5c27d88 to 0xc5c28000)
[ 2659.823029] 7d80:                   c5cc5300 c5cb1000 c5c18800 c78ae4a0 00008928 00008928
[ 2659.831155] 7da0: 00000001 c02a4b24 c2388c2e 00000000 c7eb6200 c02a4c8c c02a4200 c2388c2d
[ 2659.839287] 7dc0: c04fcfac 00000000 0000ee48 00008000 fb0ca8c0 c7eb6200 c04fcfac 00000000
[ 2659.847412] 7de0: 000038e5 fb0ca8c0 fb0ca8c0 c7eb6200 00000000 c02a4e28 c02a40e4 00000000
[ 2659.855543] 7e00: 00000000 00000000 00000000 c02b99d4 00000001 00000000 c5c27f08 00000000
[ 2659.863669] 7e20: c5c7b500 000005a8 00000000 00000000 000200da c5c7b500 c0069a74 c5c27e3c
[ 2659.871802] 7e40: c5c27e3c c0049fdc be96a8fc c0275d70 c5c27e88 00000006 00000005 00000001
[ 2659.879933] 7e60: 00000000 00000000 00000000 fb0ca8c0 1d0ca8c0 00000000 00000000 00000000
[ 2659.888057] 7e80: 00000000 00000000 00000000 00000000 00000006 38e50000 00000000 c7ff6e00
[ 2659.896183] 7ea0: 000063f8 c5c27f08 00000010 c7eb6200 c5c27f08 c00440c4 c5c26000 c76cd2c0
[ 2659.904314] 7ec0: 00000802 c02c4f70 0000c1ff 00000001 00000000 00000000 00000000 00045108
[ 2659.912441] 7ee0: 00000010 c76cd2c0 00045108 00000010 c5c27f08 c00440c4 c5c26000 40343800
[ 2659.920573] 7f00: 00044440 c0276888 38e50002 fb0ca8c0 00000000 00000000 000063f8 00000000
[ 2659.928698] 7f20: 00000000 be96a858 c5c27f48 000450c0 000000c5 c00440c4 c5c26000 40343800
[ 2659.936829] 7f40: 00044440 c00a9864 000063f8 00000000 00000005 c047c1ff 00000001 00000000
[ 2659.944952] 7f60: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000003
[ 2659.953078] 7f80: 00000000 c7b5aa00 00000000 00000000 00000000 00046cb8 00045108 40370ef8
[ 2659.961203] 7fa0: 0000011b c0043f40 00046cb8 00045108 0000000a 00045108 00000010 0000001c
[ 2659.969328] 7fc0: 00046cb8 00045108 40370ef8 0000011b 00000000 00043178 40343800 00044440
[ 2659.977451] 7fe0: 40371050 be96a968 4035b3c8 40790638 60000010 0000000a 00000000 00000000
[ 2659.985599] [<c00a28d8>] (kmem_cache_alloc+0x30/0x90) from [<c02a4b24>] (inet_bind_bucket_create+0x18/0x5c)
[ 2659.995296] [<c02a4b24>] (inet_bind_bucket_create+0x18/0x5c) from [<c02a4c8c>] (__inet_hash_connect+0x124/0x280)
[ 2660.005415] [<c02a4c8c>] (__inet_hash_connect+0x124/0x280) from [<c02a4e28>] (inet_hash_connect+0x40/0x50)
[ 2660.015034] [<c02a4e28>] (inet_hash_connect+0x40/0x50) from [<c02b99d4>] (tcp_v4_connect+0x2a8/0x420)
[ 2660.024211] [<c02b99d4>] (tcp_v4_connect+0x2a8/0x420) from [<c02c4f70>] (inet_stream_connect+0xac/0x26c)
[ 2660.033653] [<c02c4f70>] (inet_stream_connect+0xac/0x26c) from [<c0276888>] (sys_connect+0x6c/0x90)
[ 2660.042662] [<c0276888>] (sys_connect+0x6c/0x90) from [<c0043f40>] (ret_fast_syscall+0x0/0x28)
[ 2660.051228] Code: e5904080 e5907090 e3540000 1590308c (17943103) [ 2660.057440] ---[ end trace 416b23b4578ffa42 ]---
[ 2660.062021] Kernel panic - not syncing: Fatal exception in interrupt
[ 2660.068400] [<c00486cc>] (unwind_backtrace+0x0/0xdc) from [<c0351758>] (panic+0x34/0x120)
[ 2660.076555] [<c0351758>] (panic+0x34/0x120) from [<c004758c>] (die+0x14c/0x178)
[ 2660.083823] [<c004758c>] (die+0x14c/0x178) from [<c0049900>] (__do_kernel_fault+0x68/0x80)
[ 2660.092060] [<c0049900>] (__do_kernel_fault+0x68/0x80) from [<c004b678>] (do_alignment+0x59c/0x700)
[ 2660.101067] [<c004b678>] (do_alignment+0x59c/0x700) from [<c00432c8>] (do_DataAbort+0x34/0x94)
[ 2660.109649] [<c00432c8>] (do_DataAbort+0x34/0x94) from [<c0043acc>] (__dabt_svc+0x4c/0x60)
[ 2660.117874] Exception stack(0xc5c27d40 to 0xc5c27d88)
[ 2660.122898] 7d40: c04d42e4 00000020 c78ae4a0 00000000 00000001 60000013 00000020 00000020
[ 2660.131046] 7d60: c0532148 c04fcfac 00008928 00006e49 c78ae4a0 c5c27d88 c02a4b24 c00a28d8
[ 2660.139189] 7d80: 20000093 ffffffff
[ 2660.142673] [<c0043acc>] (__dabt_svc+0x4c/0x60) from [<c00a28d8>] (kmem_cache_alloc+0x30/0x90)
[ 2660.151265] [<c00a28d8>] (kmem_cache_alloc+0x30/0x90) from [<c02a4b24>] (inet_bind_bucket_create+0x18/0x5c)
[ 2660.160998] [<c02a4b24>] (inet_bind_bucket_create+0x18/0x5c) from [<c02a4c8c>] (__inet_hash_connect+0x124/0x280)
[ 2660.171148] [<c02a4c8c>] (__inet_hash_connect+0x124/0x280) from [<c02a4e28>] (inet_hash_connect+0x40/0x50)
[ 2660.180780] [<c02a4e28>] (inet_hash_connect+0x40/0x50) from [<c02b99d4>] (tcp_v4_connect+0x2a8/0x420)
[ 2660.189971] [<c02b99d4>] (tcp_v4_connect+0x2a8/0x420) from [<c02c4f70>] (inet_stream_connect+0xac/0x26c)
[ 2660.199424] [<c02c4f70>] (inet_stream_connect+0xac/0x26c) from [<c0276888>] (sys_connect+0x6c/0x90)
[ 2660.208443] [<c0276888>] (sys_connect+0x6c/0x90) from [<c0043f40>] (ret_fast_syscall+0x0/0x28)

