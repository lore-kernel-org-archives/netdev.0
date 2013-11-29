From: Meelis Roos <mroos@linux.ee>
Subject: DMA-API warning from sunhme - unchecked dma_map_single error
Date: Fri, 29 Nov 2013 10:40:40 +0200 (EET)
Message-ID: <alpine.SOC.1.00.1311291036050.3807@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, sparclinux@vger.kernel.org
Return-path: <sparclinux-owner@vger.kernel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I turned on DMA API debugging among other debug options to help catch an 
error. So far I have only found probably unrelated things. One of them 
is this splat:

WARNING: CPU: 6 PID: 1948 at lib/dma-debug.c:937 check_unmap+0x784/0x840()
hme 0000:00:01.1: DMA-API: device driver failed to check map error[device address=0x00000000c006e002] [size=342 bytes] [mapped as single]
Modules linked in:
CPU: 6 PID: 1948 Comm: dhclient Tainted: G        W    3.13.0-rc1 #16
Call Trace:
 [00000000004585cc] warn_slowpath_common+0x4c/0x80
 [00000000004586ac] warn_slowpath_fmt+0x2c/0x40
 [00000000006407e4] check_unmap+0x784/0x840
 [0000000000640944] debug_dma_unmap_page+0x44/0x60
 [000000000073f8c8] happy_meal_tx+0x128/0x260
 [000000000073fed8] happy_meal_interrupt+0x78/0xc0
 [00000000004a4b84] handle_irq_event_percpu+0x44/0x1a0
 [00000000004a4d18] handle_irq_event+0x38/0x80
 [00000000004a7dcc] handle_fasteoi_irq+0x10c/0x1c0
 [00000000004a4300] generic_handle_irq+0x40/0x60
 [000000000042bb38] handler_irq+0xb8/0xe0
 [0000000000426b2c] valid_addr_bitmap_patch+0x74/0x248
 [000000000049bf88] lock_acquire+0x68/0x80
 [0000000000494be4] down_read_trylock+0x44/0x60
 [000000000044bf54] do_sparc64_fault+0x1d4/0x700
 [0000000000407964] sparc64_realfault_common+0x10/0x20
---[ end trace 9a1420108ebfd592 ]---
Mapped at:
 [<0000000000740314>] happy_meal_start_xmit+0x1d4/0x4c0
 [<000000000077a8f0>] dev_hard_start_xmit+0x370/0x500
 [<0000000000795f8c>] sch_direct_xmit+0x4c/0x2a0
 [<000000000077ae18>] dev_queue_xmit+0x398/0x7c0
 [<00000000008015a8>] packet_sendmsg_spkt+0x388/0x4c0

It seems to be correct warning - dma_map_single is used unchecked in 
sunhme.c. I can try fixing it - the error handling will be the only 
problem. Is it considered worthwile?

-- 
Meelis Roos (mroos@linux.ee)
