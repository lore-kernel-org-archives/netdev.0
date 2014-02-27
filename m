From: Amir Vadai <amirv@mellanox.com>
Subject: Re: mlx4_core: DMA-API: device driver tries to sync DMA memory it
 has not allocated
Date: Thu, 27 Feb 2014 19:01:09 +0200
Message-ID: <20140227170107.GB24226@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <20131210144416.31b7002c@thinkpad>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131210144416.31b7002c@thinkpad>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/12/13 14:44 +0100, Gerald Schaefer wrote:
> Hi,
> 
> During network stress test with CONFIG_DMA_API_DEBUG=y we get the following
> message on the server side:
> 
> [57523.955982] mlx4_core 0000:00:00.0: DMA-API: device driver tries to sync DMA memory it has not allocated [device address=0x0000000143d2c202] [size=1526 bytes]
> [57523.956018] ------------[ cut here ]------------
> [57523.956021] WARNING: at /home/dailybuild/builder/packages/BUILD/linux-3.12.3-20131209/lib/dma-debug.c:986
> [57523.956022] Modules linked in: mlx4_en dm_multipath scsi_dh mlx4_core eadm_sch dm_mod lcs autofs4
> [57523.956034] CPU: 3 PID: 20 Comm: ksoftirqd/3 Not tainted 3.12.3-65.x.20131209-s390xdefault #1
> [57523.956037] task: 000000026f47cb60 ti: 000000026f484000 task.ti: 000000026f484000
> [57523.956044] Krnl PSW : 0404e00180000000 00000000004a0422 (check_sync+0xf2/0x52c)
> [57523.956047]            R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:3 CC:2 PM:0 EA:3
> [57523.956047] Krnl GPRS: 0000000000000111 000000008b767e9c 0000000000000092 0000000000000000
> [57523.956051]            00000000004a041e 0000000000000000 00000000000005f6 0000000143d2c202
> [57523.956053]            000000026f487a98 0000000000000001 0000000000a71144 000000026f10dd60
> [57523.956055]            0000000000000000 000000000075bb18 00000000004a041e 000000026f487980
> [57523.956064] Krnl Code: 00000000004a0412: c020002143d7        larl    %r2,8c8bc0
> [57523.956064]            00000000004a0418: c0e50012717a        brasl   %r14,6ee70c
> [57523.956064]           #00000000004a041e: a7f40001            brc     15,4a0420
> [57523.956064]           >00000000004a0422: e330a0000012        lt      %r3,0(%r10)
> [57523.956064]            00000000004a0428: a7740201            brc     7,4a082a
> [57523.956064]            00000000004a042c: a7f401f3            brc     15,4a0812
> [57523.956064]            00000000004a0430: d5078030c030        clc     48(8,%r8),48(%r12)
> [57523.956064]            00000000004a0436: a7c40070            brc     12,4a0516
> [57523.956081] Call Trace:
> [57523.956084] ([<00000000004a041e>] check_sync+0xee/0x52c)
> [57523.956087]  [<00000000004a0a26>] debug_dma_sync_single_for_cpu+0x66/0x74
> [57523.956094]  [<000003ff801fcae0>] mlx4_en_complete_rx_desc+0x15c/0x240 [mlx4_en]
> [57523.956098]  [<000003ff801fe1fa>] mlx4_en_process_rx_cq+0x56a/0xb58 [mlx4_en]
> [57523.956101]  [<000003ff801fe8ea>] mlx4_en_poll_rx_cq+0x92/0xf8 [mlx4_en]
> [57523.956105]  [<00000000005d558c>] net_rx_action+0xa0/0x2f0
> [57523.956109]  [<000000000013cd10>] __do_softirq+0x1e8/0x480
> [57523.956111]  [<000000000013cfe4>] run_ksoftirqd+0x3c/0x80
> [57523.956114]  [<000000000016f496>] smpboot_thread_fn+0x2c6/0x2e8
> [57523.956118]  [<0000000000163834>] kthread+0xd0/0xe4
> [57523.956123]  [<00000000006ff19e>] kernel_thread_starter+0x6/0xc
> [57523.956125]  [<00000000006ff198>] kernel_thread_starter+0x0/0xc
> [57523.956127] 1 lock held by ksoftirqd/3/20:
> [57523.956129]  #0:  (&(&dma_entry_hash[i].lock)->rlock){-.-...}, at: [<000000000049f1d6>] get_hash_bucket+0x4a/0x64
> [57523.956135] Last Breaking-Event-Address:
> [57523.956137]  [<00000000004a041e>] check_sync+0xee/0x52c
> [57523.956139] ---[ end trace ec82af84e1d16c5f ]---
> 
> --

Hi Gerald,

It seems that I missed this mail.

I didn't see this warning in our lab in x86 platform.
Is it reproduced easily on PPC?
Any hints how to reproduce it in our lab?

Do you have a 'good' version that didn't have the warning?

Thanks,
Amir
