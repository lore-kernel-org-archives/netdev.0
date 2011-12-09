From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [3.2-rc4] pcnet32: DMA-API: device driver tries to sync DMA memory it has not allocated
Date: Fri, 09 Dec 2011 12:40:46 +0900
Message-ID: <201112090340.pB93ek9i086855@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I saw this warning twice. Never seen until 3.1.

[   90.160533] ------------[ cut here ]------------
[   90.166508] WARNING: at lib/dma-debug.c:966 check_sync+0x53b/0x540()
[   90.204591] Hardware name: VMware Virtual Platform
[   90.210719] pcnet32 0000:02:00.0: DMA-API: device driver tries to sync DMA memory it has not allocated [device address=0x0000000030e56810] [size=106 bytes]
[   90.254360] Modules linked in: ipv6 ccsecurity pcnet32
[   90.286588] Pid: 0, comm: swapper/0 Not tainted 3.2.0-rc4-00336-g09d9673-dirty #10
[   90.296227] Call Trace:
[   90.327395]  [<c11dae6b>] ? check_sync+0x53b/0x540
[   90.333565]  [<c104009c>] warn_slowpath_common+0x7c/0xa0
[   90.365453]  [<c11dae6b>] ? check_sync+0x53b/0x540
[   90.371653]  [<c10400f1>] warn_slowpath_fmt+0x31/0x40
[   90.403766]  [<c11dae6b>] check_sync+0x53b/0x540
[   90.435377]  [<c10cddb1>] ? dbg_redzone1+0x11/0x30
[   90.441526]  [<c11db55e>] debug_dma_sync_single_for_cpu+0x4e/0x60
[   90.474657]  [<c10d0745>] ? __kmalloc_track_caller+0xe5/0x160
[   90.481987]  [<c12df111>] ? __alloc_skb+0x61/0x110
[   90.488108]  [<f8041da7>] pcnet32_rx_entry+0x287/0x400 [pcnet32]
[   90.495788]  [<c107161b>] ? trace_hardirqs_off+0xb/0x10
[   90.526820]  [<c1061d6b>] ? local_clock+0x3b/0x60
[   90.532827]  [<f8041f70>] pcnet32_rx+0x50/0xa0 [pcnet32]
[   90.539547]  [<f804226a>] pcnet32_poll+0x2a/0x100 [pcnet32]
[   90.572516]  [<c12ec3f7>] net_rx_action+0x137/0x160
[   90.579053]  [<c1071480>] ? trace_hardirqs_on_caller+0x90/0x100
[   90.586503]  [<c1045fe4>] __do_softirq+0xd4/0x130
[   90.616903]  [<c1045f10>] ? local_bh_enable_ip+0xd0/0xd0
[   90.624046]  <IRQ>  [<c10460d2>] ? irq_exit+0x42/0x70
[   90.630750]  [<c101e7d3>] ? smp_apic_timer_interrupt+0x33/0x40
[   90.662535]  [<c13a2753>] ? apic_timer_interrupt+0x2f/0x34
[   90.696651]  [<c10700d8>] ? check_prevs_add+0x68/0x100
[   90.703668]  [<c100a554>] ? default_idle+0x34/0x60
[   90.709802]  [<c1001858>] ? cpu_idle+0x68/0xb0
[   90.742827]  [<c138bf11>] ? rest_init+0xa1/0xb0
[   90.748840]  [<c138be70>] ? __read_lock_failed+0x20/0x20
[   90.755670]  [<c158c807>] ? start_kernel+0x217/0x2b0
[   90.762022]  [<c158c280>] ? loglevel+0x30/0x30
[   90.767714]  [<c158c084>] ? i386_start_kernel+0x64/0xb0
[   90.804957] ---[ end trace 7455a0a77cd44df9 ]---
