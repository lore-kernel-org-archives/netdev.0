From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: Divide error in bictcp_cong_avoid ?
Date: Wed, 4 May 2011 10:49:40 -0700
Message-ID: <20110504104940.cd0d9e9a.rdunlap@xenotime.net>
References: <4DC178D3.6030308@techboom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: TB <lkml@techboom.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy5-pub.bluehost.com ([67.222.39.38]:57164 "HELO
	oproxy5-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754633Ab1EDRtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 13:49:43 -0400
In-Reply-To: <4DC178D3.6030308@techboom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[add cc to netdev]


On Wed, 04 May 2011 12:03:31 -0400 TB wrote:

> We're having this issue sporadically on a few servers and this is the 
> backtrace we get from netconsole.
> 
> 
> [28522.642419] divide error: 0000 [#1] SMP
> [28522.642457] last sysfs file: 
> /sys/devices/pci0000:00/0000:00:1f.2/host2/target2:0:0/2:0:0:0/vendor
> [28522.642504] CPU 0
> [28522.642511] Modules linked in:
>   i2c_i801
>   i2c_core
>   evdev
>   button
> [28522.642570]
> [28522.642590] Pid: 0, comm: swapper Not tainted 2.6.38.5 #6
> 
>   Supermicro X8DTH-i/6/iF/6F
> /
>   X8DTH
> 
> [28522.642651] RIP: 0010:[<ffffffff8150b27b>] [<ffffffff8150b27b>] 
> bictcp_cong_avoid+0x21a/0x247
> [28522.642708] RSP: 0018:ffff8800bf403a90  EFLAGS: 00010202
> [28522.642735] RAX: 0000000000000010 RBX: ffff880352aa6400 RCX: 
> 0000000000000000
> [28522.642765] RDX: 0000000000000000 RSI: ffff880352aa67c0 RDI: 
> 0000000000001607
> [28522.642795] RBP: 000000007caa5a1b R08: 00000000000035c2 R09: 
> 00000000000000e6
> [28522.642825] R10: ffff88003d499c00 R11: ffff880109831b00 R12: 
> ffffffff817cecd0
> [28522.642855] R13: 0000000000000004 R14: 000000000001001b R15: 
> 0000000000000123
> [28522.642886] FS:  0000000000000000(0000) GS:ffff8800bf400000(0000) 
> knlGS:0000000000000000
> [28522.642932] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [28522.642959] CR2: 00007fb4c6ffd000 CR3: 000000042e4a1000 CR4: 
> 00000000000006f0
> [28522.642990] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
> 0000000000000000
> [28522.643020] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
> 0000000000000400
> [28522.643050] Process swapper (pid: 0, threadinfo ffffffff8176c000, 
> task ffffffff81777020)
> [28522.643095] Stack:
> [28522.643116]  ffff880352aa6400
>   ffffffff817cecd0
>   0000000000000004
>   0000000000000406
> 
> [28522.643171]  ffff880352aa6400
>   ffffffff814e3dc5
>   000000000000111c
>   ffff88022a9b3200
> 
> [28522.643226]  0000000000000000
>   7caa5a1b7caa4ec3
>   0000000000000000
>   0000000000000000
> 
> [28522.643281] Call Trace:
> [28522.643303]  <IRQ>
> 
> [28522.643330]  [<ffffffff814e3dc5>] ? tcp_ack+0x18b5/0x1a89
> [28522.643359]  [<ffffffff814e45c2>] ? tcp_rcv_established+0xd1/0xa13
> [28522.643389]  [<ffffffff814ec60b>] ? tcp_v4_do_rcv+0x1b2/0x382
> [28522.643418]  [<ffffffff814c95d4>] ? nf_iterate+0x40/0x78
> [28522.643446]  [<ffffffff814ecc5f>] ? tcp_v4_rcv+0x484/0x797
> [28522.643475]  [<ffffffff814d11c7>] ? ip_local_deliver_finish+0xab/0x139
> [28522.643505]  [<ffffffff814ae2b3>] ? __netif_receive_skb+0x31c/0x349
> [28522.643535]  [<ffffffff814aec82>] ? netif_receive_skb+0x67/0x6d
> [28522.643564]  [<ffffffff814af1fb>] ? napi_gro_receive+0x9d/0xab
> [28522.643592]  [<ffffffff814aed57>] ? napi_skb_finish+0x1c/0x31
> [28522.643623]  [<ffffffff813e4248>] ? igb_poll+0x7d5/0xb2e
> [28522.643653]  [<ffffffff812b6b22>] ? blk_run_queue+0x23/0x37
> [28522.643683]  [<ffffffff813520d4>] ? scsi_run_queue+0x2ee/0x381
> [28522.643712]  [<ffffffff81353810>] ? scsi_io_completion+0x3e0/0x409
> [28522.643741]  [<ffffffff814af337>] ? net_rx_action+0xa7/0x212
> [28522.643771]  [<ffffffff8103b6c2>] ? __do_softirq+0xbe/0x184
> [28522.643800]  [<ffffffff8100364c>] ? call_softirq+0x1c/0x28
> [28522.643828]  [<ffffffff81005085>] ? do_softirq+0x31/0x63
> [28522.643856]  [<ffffffff8103b56c>] ? irq_exit+0x36/0x78
> [28522.643883]  [<ffffffff81004784>] ? do_IRQ+0x98/0xae
> [28522.643912]  [<ffffffff81562c13>] ? ret_from_intr+0x0/0xe
> [28522.643938]  <EOI>
> 
> [28522.643963]  [<ffffffff81009a41>] ? mwait_idle+0xb9/0xf3
> [28522.643991]  [<ffffffff81001c6e>] ? cpu_idle+0x57/0x8d
> [28522.644019]  [<ffffffff81801c49>] ? start_kernel+0x34e/0x35a
> [28522.644048]  [<ffffffff81801398>] ? x86_64_start_kernel+0xf3/0xf9
> [28522.644075] Code:
>   39  c9  76  18  44  29  c9  31  d2  44  89  c8  f7  f1  39  83  c0  03 
>   00  00
>   76  06  89  83  c0  03  00  00  8b  83  c0  03  00  00  31  d2  c1  e0 
>   04  0f
>   b7  4e  2c
>   f7>  f1  ba  01  00  00  00  85  c0  0f  45  d0  89  93  c0  03  00 
> 00  8b  b3
>   c0
> 
> [28522.644338] RIP
>   [<ffffffff8150b27b>] bictcp_cong_avoid+0x21a/0x247
> [28522.644371]  RSP <ffff8800bf403a90>
> [28522.644733] ---[ end trace 9db294ef7ff3a7b5 ]---
> [28522.644800] Kernel panic - not syncing: Fatal exception in interrupt
> [28522.644871] Pid: 0, comm: swapper Tainted: G      D     2.6.38.5 #6
> [28522.644942] Call Trace:
> [28522.645012]  <IRQ>
>   [<ffffffff81560690>] ? panic+0x9d/0x1a0
> [28522.645131]  [<ffffffff81562c13>] ? ret_from_intr+0x0/0xe
> [28522.645200]  [<ffffffff810365bb>] ? kmsg_dump+0x46/0xec
> [28522.645268]  [<ffffffff81006176>] ? oops_end+0x9f/0xac
> [28522.645335]  [<ffffffff810040d8>] ? do_divide_error+0x7f/0x89
> [28522.645404]  [<ffffffff8150b27b>] ? bictcp_cong_avoid+0x21a/0x247
> [28522.645473]  [<ffffffff814b057c>] ? dev_queue_xmit+0x4a4/0x4b2
> [28522.645545]  [<ffffffff814d5390>] ? ip_queue_xmit+0x2e9/0x32f
> [28522.645614]  [<ffffffff81003375>] ? divide_error+0x15/0x20
> [28522.645685]  [<ffffffff8150b27b>] ? bictcp_cong_avoid+0x21a/0x247
> [28522.645754]  [<ffffffff814e3dc5>] ? tcp_ack+0x18b5/0x1a89
> [28522.645823]  [<ffffffff814e45c2>] ? tcp_rcv_established+0xd1/0xa13
> [28522.645892]  [<ffffffff814ec60b>] ? tcp_v4_do_rcv+0x1b2/0x382
> [28522.645961]  [<ffffffff814c95d4>] ? nf_iterate+0x40/0x78
> [28522.646029]  [<ffffffff814ecc5f>] ? tcp_v4_rcv+0x484/0x797
> [28522.646097]  [<ffffffff814d11c7>] ? ip_local_deliver_finish+0xab/0x139
> [28522.646167]  [<ffffffff814ae2b3>] ? __netif_receive_skb+0x31c/0x349
> [28522.646240]  [<ffffffff814aec82>] ? netif_receive_skb+0x67/0x6d
> [28522.646308]  [<ffffffff814af1fb>] ? napi_gro_receive+0x9d/0xab
> [28522.646377]  [<ffffffff814aed57>] ? napi_skb_finish+0x1c/0x31
> [28522.646445]  [<ffffffff813e4248>] ? igb_poll+0x7d5/0xb2e
> [28522.646513]  [<ffffffff812b6b22>] ? blk_run_queue+0x23/0x37
> [28522.646582]  [<ffffffff813520d4>] ? scsi_run_queue+0x2ee/0x381
> [28522.646651]  [<ffffffff81353810>] ? scsi_io_completion+0x3e0/0x409
> [28522.646721]  [<ffffffff814af337>] ? net_rx_action+0xa7/0x212
> [28522.646791]  [<ffffffff8103b6c2>] ? __do_softirq+0xbe/0x184
> [28522.646884]  [<ffffffff8100364c>] ? call_softirq+0x1c/0x28
> [28522.646953]  [<ffffffff81005085>] ? do_softirq+0x31/0x63
> [28522.647021]  [<ffffffff8103b56c>] ? irq_exit+0x36/0x78
> [28522.647089]  [<ffffffff81004784>] ? do_IRQ+0x98/0xae
> [28522.647164]  [<ffffffff81562c13>] ? ret_from_intr+0x0/0xe
> [28522.647239]  <EOI>
>   [<ffffffff81009a41>] ? mwait_idle+0xb9/0xf3
> [28522.647354]  [<ffffffff81001c6e>] ? cpu_idle+0x57/0x8d
> [28522.647422]  [<ffffffff81801c49>] ? start_kernel+0x34e/0x35a
> [28522.647491]  [<ffffffff81801398>] ? x86_64_start_kernel+0xf3/0xf9
> --


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
