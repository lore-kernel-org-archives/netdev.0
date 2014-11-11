From: Long Li <longli@microsoft.com>
Subject: RE: skbuff_fclone_cache poison overwritten
Date: Tue, 11 Nov 2014 19:27:23 +0000
Message-ID: <8a1a6be73725414cb3360011fa69581c@BL2PR03MB132.namprd03.prod.outlook.com>
References: <20141110113248.GA25131@sucs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sitsofe Wheeler <sitsofe@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141110113248.GA25131@sucs.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's not obvious if this is a problem with hv_netvsc, or other code.

Can you try to use a legacy network device and see if this issue still exists?

-----Original Message-----
From: Sitsofe Wheeler [mailto:sitsofe@gmail.com] 
Sent: Monday, November 10, 2014 3:33 AM
To: David S. Miller
Cc: KY Srinivasan; Haiyang Zhang; Long Li; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: skbuff_fclone_cache poison overwritten

While using 3.18.0-rc3.x86_64-00116-g6ac94d3 on a Hyper-V 2012 R2 the poison in skbuff_fclone_cache was overwritten:

[39099.484435] sd 7:0:0:0: [sdi] Attached SCSI disk [39099.484688] sd 6:0:0:0: [sdh] Attached SCSI disk [45285.786640] =============================================================================
[45285.787543] BUG skbuff_fclone_cache (Not tainted): Poison overwritten [45285.787543] -----------------------------------------------------------------------------

[45285.787543] Disabling lock debugging due to kernel taint [45285.787543] INFO: 0xffff8800d144c056-0xffff8800d144c056. First byte 0x6f instead of 0x6b [45285.787543] INFO: Allocated in __alloc_skb+0x4e/0x240 age=11 cpu=1 pid=17444
[45285.787543] 	__slab_alloc+0x50a/0x563
[45285.787543] 	kmem_cache_alloc_node+0xfe/0x2a0
[45285.787543] 	__alloc_skb+0x4e/0x240
[45285.787543] 	sk_stream_alloc_skb+0x3d/0x110
[45285.787543] 	tcp_sendmsg+0x36d/0xc60
[45285.787543] 	inet_sendmsg+0xd7/0xf0
[45285.787543] 	sock_sendmsg+0x90/0xb0
[45285.787543] 	SYSC_sendto+0x10e/0x150
[45285.787543] 	SyS_sendto+0xe/0x10
[45285.787543] 	system_call_fastpath+0x12/0x17
[45285.787543] INFO: Freed in kfree_skbmem+0x6f/0xa0 age=21 cpu=1 pid=17444
[45285.787543] 	__slab_free+0x39/0x2a0
[45285.787543] 	kmem_cache_free+0x1ce/0x280
[45285.787543] 	kfree_skbmem+0x6f/0xa0
[45285.787543] 	__kfree_skb+0x1e/0x30
[45285.787543] 	tcp_ack+0x66e/0x11f0
[45285.787543] 	tcp_rcv_established+0x514/0x6e0
[45285.787543] 	tcp_v4_do_rcv+0xb4/0x330
[45285.787543] 	release_sock+0xfd/0x1f0
[45285.787543] 	tcp_sendmsg+0xa65/0xc60
[45285.787543] 	inet_sendmsg+0xd7/0xf0
[45285.787543] 	sock_sendmsg+0x90/0xb0
[45285.787543] 	SYSC_sendto+0x10e/0x150
[45285.787543] 	SyS_sendto+0xe/0x10
[45285.787543] 	system_call_fastpath+0x12/0x17
[45285.787543] INFO: Slab 0xffffea0003451200 objects=42 used=42 fp=0x          (null) flags=0x3ffe0000004080
[45285.787543] INFO: Object 0xffff8800d144bf00 @offset=16128 fp=0xffff8800d1448f00

[45285.787543] Bytes b4 ffff8800d144bef0: 88 3d ad 02 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  .=......ZZZZZZZZ [45285.787543] Object ffff8800d144bf00: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144bf10: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144bf20: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144bf30: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144bf40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144bf50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144bf60: 6b 6b 6b 6b 6b 6
 b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144bf70: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144bf80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144bf90: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144bfa0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144bfb0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144bfc0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144bfd0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285
 .787543] Object ffff8800d144bfe0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144bff0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144c000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144c010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144c020: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144c030: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144c040: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144c050: 6b 6b 6b 6b 6b 6b 6f 6
 b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkokkkkkkkkk [45285.787543] Object ffff8800d144c060: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144c070: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144c080: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144c090: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [45285.787543] Object ffff8800d144c0a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[45285.787543] Object ffff8800d144c0b0: 6b 6b 6b 6b 6b 6b 6b a5                          kkkkkkk.
[45285.787543] Redzone ffff8800d144c0b8: bb bb bb bb bb bb bb bb                          ........
[45285.787543] Padding ffff8800d144c1f8: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
[45285.787543] CPU: 7 PID: 16678 Comm: phantomjs Tainted: G    B          3.18.0-rc3.x86_64-00116-g6ac94d3 #160
[45285.787543] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012 [45285.787543]  ffff8800d144bf00 ffff8801eb41b928 ffffffff816db38f 0000000000000000 [45285.787543]  ffff8801fbd34e00 ffff8801eb41b968 ffffffff811a6187 0000000000000008 [45285.787543]  ffff880000000001 ffff8800d144c057 ffff8801fbd34e00 000000000000006b [45285.787543] Call Trace:
[45285.787543]  [<ffffffff816db38f>] dump_stack+0x4e/0x68 [45285.787543]  [<ffffffff811a6187>] print_trailer+0x1c7/0x1e0 [45285.787543]  [<ffffffff811a6b7b>] check_bytes_and_report+0xbb/0x110 [45285.787543]  [<ffffffff811a76ee>] check_object+0x10e/0x240 [45285.787543]  [<ffffffff815fb11e>] ? __alloc_skb+0x4e/0x240 [45285.787543]  [<ffffffff816d8b65>] alloc_debug_processing+0x76/0x118 [45285.787543]  [<ffffffff816d981b>] __slab_alloc+0x50a/0x563 [45285.787543]  [<ffffffff815fb11e>] ? __alloc_skb+0x4e/0x240 [45285.787543]  [<ffffffff810b7ad8>] ? mark_held_locks+0x88/0xa0 [45285.787543]  [<ffffffff811a9dbe>] kmem_cache_alloc_node+0xfe/0x2a0 [45285.787543]  [<ffffffff815fb11e>] __alloc_skb+0x4e/0x240 [45285.787543]  [<ffffffff81655c3d>] sk_stream_alloc_skb+0x3d/0x110 [45285.787543]  [<ffffffff
 8165666d>] tcp_sendmsg+0x36d/0xc60 [45285.787543]  [<ffffffff81683847>] inet_sendmsg+0xd7/0xf0 [45285.787543]  [<ffffffff81683775>] ? inet_sendmsg+0x5/0xf0 [45285.787543]  [<ffffffff815f2980>] sock_sendmsg+0x90/0xb0 [45285.787543]  [<ffffffff811e4541>] ? __fget_light+0x61/0x80 [45285.787543]  [<ffffffff811e4ee3>] ? __fdget+0x13/0x20 [45285.787543]  [<ffffffff815f2aae>] SYSC_sendto+0x10e/0x150 [45285.787543]  [<ffffffff811cab6f>] ? SYSC_newstat+0x2f/0x40 [45285.787543]  [<ffffffff816e5a5c>] ? retint_swapgs+0x13/0x1b [45285.787543]  [<ffffffff813aa1fe>] ? trace_hardirqs_on_thunk+0x3a/0x3f [45285.787543]  [<ffffffff815f3afe>] SyS_sendto+0xe/0x10 [45285.787543]  [<ffffffff816e4e29>] system_call_fastpath+0x12/0x17 [45285.787543] FIX skbuff_fclone_cache: Restoring 0xffff8800d144c056-0xffff8800
 d144c056=0x6b

[45285.787543] FIX skbuff_fclone_cache: Marking all objects used [46810.070997] =============================================================================
[46810.071289] BUG skbuff_fclone_cache (Tainted: G    B         ): Poison overwritten
[46810.071289] -----------------------------------------------------------------------------

[46810.071289] INFO: 0xffff8801c48fe756-0xffff8801c48fe756. First byte 0x6f instead of 0x6b [46810.071289] INFO: Allocated in __alloc_skb+0x4e/0x240 age=9 cpu=6 pid=1220
[46810.071289] 	__slab_alloc+0x50a/0x563
[46810.071289] 	kmem_cache_alloc_node+0xfe/0x2a0
[46810.071289] 	__alloc_skb+0x4e/0x240
[46810.071289] 	sk_stream_alloc_skb+0x3d/0x110
[46810.071289] 	tcp_sendmsg+0x36d/0xc60
[46810.071289] 	inet_sendmsg+0xd7/0xf0
[46810.071289] 	sock_sendmsg+0x90/0xb0
[46810.071289] 	SYSC_sendto+0x10e/0x150
[46810.071289] 	SyS_sendto+0xe/0x10
[46810.071289] 	system_call_fastpath+0x12/0x17
[46810.071289] INFO: Freed in kfree_skbmem+0x6f/0xa0 age=23 cpu=6 pid=1220
[46810.071289] 	__slab_free+0x39/0x2a0
[46810.071289] 	kmem_cache_free+0x1ce/0x280
[46810.071289] 	kfree_skbmem+0x6f/0xa0
[46810.071289] 	__kfree_skb+0x1e/0x30
[46810.071289] 	tcp_ack+0x66e/0x11f0
[46810.071289] 	tcp_rcv_established+0x107/0x6e0
[46810.071289] 	tcp_v4_do_rcv+0xb4/0x330
[46810.071289] 	release_sock+0xfd/0x1f0
[46810.071289] 	tcp_sendmsg+0xa65/0xc60
[46810.071289] 	inet_sendmsg+0xd7/0xf0
[46810.071289] 	sock_sendmsg+0x90/0xb0
[46810.071289] 	SYSC_sendto+0x10e/0x150
[46810.071289] 	SyS_sendto+0xe/0x10
[46810.071289] 	system_call_fastpath+0x12/0x17
[46810.071289] INFO: Slab 0xffffea0007123e00 objects=42 used=42 fp=0x          (null) flags=0x5ffe0000004080
[46810.071289] INFO: Object 0xffff8801c48fe600 @offset=26112 fp=0xffff8801c48fd700

[46810.071289] Bytes b4 ffff8801c48fe5f0: c2 89 c4 02 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ [46810.071289] Object ffff8801c48fe600: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.071289] Object ffff8801c48fe610: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.071289] Object ffff8801c48fe620: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.071289] Object ffff8801c48fe630: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.071289] Object ffff8801c48fe640: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.071289] Object ffff8801c48fe650: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.071289] Object ffff8801c48fe660: 6b 6b 6b 6b 6b 6
 b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.071289] Object ffff8801c48fe670: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.071289] Object ffff8801c48fe680: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.071289] Object ffff8801c48fe690: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.071289] Object ffff8801c48fe6a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.071289] Object ffff8801c48fe6b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.071289] Object ffff8801c48fe6c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.071289] Object ffff8801c48fe6d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810
 .071289] Object ffff8801c48fe6e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.071289] Object ffff8801c48fe6f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.071289] Object ffff8801c48fe700: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.228303] Object ffff8801c48fe710: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.228303] Object ffff8801c48fe720: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.240204] Object ffff8801c48fe730: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.240204] Object ffff8801c48fe740: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.240204] Object ffff8801c48fe750: 6b 6b 6b 6b 6b 6b 6f 6
 b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkokkkkkkkkk [46810.240204] Object ffff8801c48fe760: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.240204] Object ffff8801c48fe770: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.240204] Object ffff8801c48fe780: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.240204] Object ffff8801c48fe790: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46810.240204] Object ffff8801c48fe7a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[46810.291135] Object ffff8801c48fe7b0: 6b 6b 6b 6b 6b 6b 6b a5                          kkkkkkk.
[46810.291135] Redzone ffff8801c48fe7b8: bb bb bb bb bb bb bb bb                          ........
[46810.291135] Padding ffff8801c48fe8f8: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
[46810.291135] CPU: 6 PID: 1233 Comm: phantomjs Tainted: G    B          3.18.0-rc3.x86_64-00116-g6ac94d3 #160
[46810.291135] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012 [46810.291135]  ffff8801c48fe600 ffff8801f2ebbc08 ffffffff816db38f ffff8801b6b59350 [46810.291135]  ffff8801fbd34e00 ffff8801f2ebbc48 ffffffff811a6187 0000000000000008 [46810.291135]  ffff880100000001 ffff8801c48fe757 ffff8801fbd34e00 000000000000006b [46810.291135] Call Trace:
[46810.291135]  [<ffffffff816db38f>] dump_stack+0x4e/0x68 [46810.291135]  [<ffffffff811a6187>] print_trailer+0x1c7/0x1e0 [46810.291135]  [<ffffffff811a6b7b>] check_bytes_and_report+0xbb/0x110 [46810.291135]  [<ffffffff811a76ee>] check_object+0x10e/0x240 [46810.291135]  [<ffffffff815fb11e>] ? __alloc_skb+0x4e/0x240 [46810.291135]  [<ffffffff816d8b65>] alloc_debug_processing+0x76/0x118 [46810.291135]  [<ffffffff816d981b>] __slab_alloc+0x50a/0x563 [46810.291135]  [<ffffffff810b7f4d>] ? trace_hardirqs_on+0xd/0x10 [46810.291135]  [<ffffffff815fb11e>] ? __alloc_skb+0x4e/0x240 [46810.291135]  [<ffffffff811a9dbe>] kmem_cache_alloc_node+0xfe/0x2a0 [46810.291135]  [<ffffffff815fb11e>] __alloc_skb+0x4e/0x240 [46810.291135]  [<ffffffff81666caa>] tcp_send_fin+0x7a/0x1a0 [46810.291135]  [<ffffffff81657f
 e6>] tcp_shutdown+0x46/0x60 [46810.291135]  [<ffffffff81682125>] inet_shutdown+0xb5/0x110 [46810.291135]  [<ffffffff815f3d17>] SyS_shutdown+0x47/0x70 [46810.291135]  [<ffffffff816e4e29>] system_call_fastpath+0x12/0x17 [46810.291135] FIX skbuff_fclone_cache: Restoring 0xffff8801c48fe756-0xffff8801c48fe756=0x6b

[46810.291135] FIX skbuff_fclone_cache: Marking all objects used [46994.744143] =============================================================================
[46994.744548] BUG skbuff_fclone_cache (Tainted: G    B         ): Poison overwritten
[46994.744548] -----------------------------------------------------------------------------

[46994.744548] INFO: 0xffff8801eb7df056-0xffff8801eb7df056. First byte 0x6f instead of 0x6b [46994.744548] INFO: Allocated in __alloc_skb+0x4e/0x240 age=10 cpu=0 pid=17426
[46994.744548] 	__slab_alloc+0x50a/0x563
[46994.744548] 	kmem_cache_alloc_node+0xfe/0x2a0
[46994.744548] 	__alloc_skb+0x4e/0x240
[46994.744548] 	sk_stream_alloc_skb+0x3d/0x110
[46994.744548] 	tcp_sendmsg+0x36d/0xc60
[46994.744548] 	inet_sendmsg+0xd7/0xf0
[46994.744548] 	sock_sendmsg+0x90/0xb0
[46994.744548] 	SYSC_sendto+0x10e/0x150
[46994.744548] 	SyS_sendto+0xe/0x10
[46994.744548] 	system_call_fastpath+0x12/0x17
[46994.744548] INFO: Freed in kfree_skbmem+0x6f/0xa0 age=21 cpu=0 pid=17426
[46994.744548] 	__slab_free+0x39/0x2a0
[46994.744548] 	kmem_cache_free+0x1ce/0x280
[46994.744548] 	kfree_skbmem+0x6f/0xa0
[46994.744548] 	__kfree_skb+0x1e/0x30
[46994.744548] 	tcp_ack+0x66e/0x11f0
[46994.744548] 	tcp_rcv_established+0x514/0x6e0
[46994.744548] 	tcp_v4_do_rcv+0xb4/0x330
[46994.744548] 	release_sock+0xfd/0x1f0
[46994.744548] 	tcp_sendmsg+0xa65/0xc60
[46994.744548] 	inet_sendmsg+0xd7/0xf0
[46994.744548] 	sock_sendmsg+0x90/0xb0
[46994.744548] 	SYSC_sendto+0x10e/0x150
[46994.744548] 	SyS_sendto+0xe/0x10
[46994.744548] 	system_call_fastpath+0x12/0x17
[46994.744548] INFO: Slab 0xffffea0007adf600 objects=42 used=42 fp=0x          (null) flags=0x5ffe0000004080
[46994.744548] INFO: Object 0xffff8801eb7def00 @offset=28416 fp=0xffff8801eb7db900

[46994.744548] Bytes b4 ffff8801eb7deef0: f0 cd b1 02 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ [46994.744548] Object ffff8801eb7def00: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7def10: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7def20: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7def30: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7def40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7def50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7def60: 6b 6b 6b 6b 6b 6
 b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7def70: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7def80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7def90: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7defa0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7defb0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7defc0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7defd0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994
 .744548] Object ffff8801eb7defe0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7deff0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7df000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7df010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7df020: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7df030: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7df040: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7df050: 6b 6b 6b 6b 6b 6b 6f 6
 b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkokkkkkkkkk [46994.744548] Object ffff8801eb7df060: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7df070: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7df080: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7df090: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [46994.744548] Object ffff8801eb7df0a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[46994.744548] Object ffff8801eb7df0b0: 6b 6b 6b 6b 6b 6b 6b a5                          kkkkkkk.
[46994.744548] Redzone ffff8801eb7df0b8: bb bb bb bb bb bb bb bb                          ........
[46994.744548] Padding ffff8801eb7df1f8: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
[46994.744548] CPU: 4 PID: 24686 Comm: phantomjs Tainted: G    B          3.18.0-rc3.x86_64-00116-g6ac94d3 #160
[46994.744548] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012 [46994.744548]  ffff8801eb7def00 ffff8801c4823928 ffffffff816db38f 0000000000000000 [46994.744548]  ffff8801fbd34e00 ffff8801c4823968 ffffffff811a6187 0000000000000008 [46994.744548]  ffff880100000001 ffff8801eb7df057 ffff8801fbd34e00 000000000000006b [46994.744548] Call Trace:
[46994.744548]  [<ffffffff816db38f>] dump_stack+0x4e/0x68 [46994.744548]  [<ffffffff811a6187>] print_trailer+0x1c7/0x1e0 [46994.744548]  [<ffffffff811a6b7b>] check_bytes_and_report+0xbb/0x110 [46994.744548]  [<ffffffff811a76ee>] check_object+0x10e/0x240 [46994.744548]  [<ffffffff815fb11e>] ? __alloc_skb+0x4e/0x240 [46994.744548]  [<ffffffff816d8b65>] alloc_debug_processing+0x76/0x118 [46994.744548]  [<ffffffff816d981b>] __slab_alloc+0x50a/0x563 [46994.744548]  [<ffffffff815fb11e>] ? __alloc_skb+0x4e/0x240 [46994.744548]  [<ffffffff8100611b>] ? print_context_stack+0xdb/0x100 [46994.744548]  [<ffffffff811a9dbe>] kmem_cache_alloc_node+0xfe/0x2a0 [46994.744548]  [<ffffffff815fb11e>] __alloc_skb+0x4e/0x240 [46994.744548]  [<ffffffff81655c3d>] sk_stream_alloc_skb+0x3d/0x110 [46994.744548]  [<fff
 fffff8165666d>] tcp_sendmsg+0x36d/0xc60 [46994.744548]  [<ffffffff81683847>] inet_sendmsg+0xd7/0xf0 [46994.744548]  [<ffffffff81683775>] ? inet_sendmsg+0x5/0xf0 [46994.744548]  [<ffffffff815f2980>] sock_sendmsg+0x90/0xb0 [46994.744548]  [<ffffffff811e4541>] ? __fget_light+0x61/0x80 [46994.744548]  [<ffffffff811e4ee3>] ? __fdget+0x13/0x20 [46994.744548]  [<ffffffff815f2aae>] SYSC_sendto+0x10e/0x150 [46994.744548]  [<ffffffff811cab6f>] ? SYSC_newstat+0x2f/0x40 [46994.744548]  [<ffffffff810db34e>] ? getnstimeofday64+0xe/0x30 [46994.744548]  [<ffffffff813aa1fe>] ? trace_hardirqs_on_thunk+0x3a/0x3f [46994.744548]  [<ffffffff815f3afe>] SyS_sendto+0xe/0x10 [46994.744548]  [<ffffffff816e4e29>] system_call_fastpath+0x12/0x17 [46994.744548] FIX skbuff_fclone_cache: Restoring 0xffff8801eb7df056-0xf
 fff8801eb7df056=0x6b

[46994.744548] FIX skbuff_fclone_cache: Marking all objects used [71820.156136] =============================================================================
[71820.156461] BUG skbuff_fclone_cache (Tainted: G    B         ): Poison overwritten
[71820.156461] -----------------------------------------------------------------------------

[71820.156461] INFO: 0xffff8801eb42e756-0xffff8801eb42e756. First byte 0x6f instead of 0x6b [71820.156461] INFO: Allocated in __alloc_skb+0x4e/0x240 age=11 cpu=3 pid=4181
[71820.156461] 	__slab_alloc+0x50a/0x563
[71820.156461] 	kmem_cache_alloc_node+0xfe/0x2a0
[71820.156461] 	__alloc_skb+0x4e/0x240
[71820.156461] 	sk_stream_alloc_skb+0x3d/0x110
[71820.156461] 	tcp_sendmsg+0x36d/0xc60
[71820.156461] 	inet_sendmsg+0xd7/0xf0
[71820.156461] 	sock_sendmsg+0x90/0xb0
[71820.156461] 	SYSC_sendto+0x10e/0x150
[71820.156461] 	SyS_sendto+0xe/0x10
[71820.156461] 	system_call_fastpath+0x12/0x17
[71820.156461] INFO: Freed in kfree_skbmem+0x6f/0xa0 age=30 cpu=3 pid=4181
[71820.156461] 	__slab_free+0x39/0x2a0
[71820.156461] 	kmem_cache_free+0x1ce/0x280
[71820.156461] 	kfree_skbmem+0x6f/0xa0
[71820.156461] 	__kfree_skb+0x1e/0x30
[71820.156461] 	tcp_ack+0x66e/0x11f0
[71820.156461] 	tcp_rcv_established+0x107/0x6e0
[71820.156461] 	tcp_v4_do_rcv+0xb4/0x330
[71820.156461] 	release_sock+0xfd/0x1f0
[71820.156461] 	tcp_sendmsg+0xa65/0xc60
[71820.156461] 	inet_sendmsg+0xd7/0xf0
[71820.156461] 	sock_sendmsg+0x90/0xb0
[71820.156461] 	SYSC_sendto+0x10e/0x150
[71820.156461] 	SyS_sendto+0xe/0x10
[71820.156461] 	system_call_fastpath+0x12/0x17
[71820.156461] INFO: Slab 0xffffea0007ad0a00 objects=42 used=42 fp=0x          (null) flags=0x5ffe0000004080
[71820.156461] INFO: Object 0xffff8801eb42e600 @offset=26112 fp=0xffff8801eb42b600

[71820.156461] Bytes b4 ffff8801eb42e5f0: 48 1d 41 04 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  H.A.....ZZZZZZZZ [71820.156461] Object ffff8801eb42e600: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.156461] Object ffff8801eb42e610: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.156461] Object ffff8801eb42e620: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.156461] Object ffff8801eb42e630: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.156461] Object ffff8801eb42e640: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.156461] Object ffff8801eb42e650: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.156461] Object ffff8801eb42e660: 6b 6b 6b 6b 6b 6
 b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.156461] Object ffff8801eb42e670: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.156461] Object ffff8801eb42e680: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.290941] Object ffff8801eb42e690: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.290941] Object ffff8801eb42e6a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.290941] Object ffff8801eb42e6b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.290941] Object ffff8801eb42e6c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.290941] Object ffff8801eb42e6d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820
 .290941] Object ffff8801eb42e6e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.290941] Object ffff8801eb42e6f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.290941] Object ffff8801eb42e700: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.290941] Object ffff8801eb42e710: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.290941] Object ffff8801eb42e720: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.290941] Object ffff8801eb42e730: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.290941] Object ffff8801eb42e740: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.290941] Object ffff8801eb42e750: 6b 6b 6b 6b 6b 6b 6f 6
 b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkokkkkkkkkk [71820.290941] Object ffff8801eb42e760: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.290941] Object ffff8801eb42e770: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.290941] Object ffff8801eb42e780: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.290941] Object ffff8801eb42e790: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk [71820.290941] Object ffff8801eb42e7a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[71820.290941] Object ffff8801eb42e7b0: 6b 6b 6b 6b 6b 6b 6b a5                          kkkkkkk.
[71820.290941] Redzone ffff8801eb42e7b8: bb bb bb bb bb bb bb bb                          ........
[71820.290941] Padding ffff8801eb42e8f8: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
[71820.290941] CPU: 3 PID: 4219 Comm: phantomjs Tainted: G    B          3.18.0-rc3.x86_64-00116-g6ac94d3 #160
[71820.290941] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012 [71820.290941]  ffff8801eb42e600 ffff8800d1743c08 ffffffff816db38f 0000000000000000 [71820.290941]  ffff8801fbd34e00 ffff8800d1743c48 ffffffff811a6187 0000000000000008 [71820.290941]  ffff880100000001 ffff8801eb42e757 ffff8801fbd34e00 000000000000006b [71820.290941] Call Trace:
[71820.290941]  [<ffffffff816db38f>] dump_stack+0x4e/0x68 [71820.290941]  [<ffffffff811a6187>] print_trailer+0x1c7/0x1e0 [71820.290941]  [<ffffffff811a6b7b>] check_bytes_and_report+0xbb/0x110 [71820.290941]  [<ffffffff811a76ee>] check_object+0x10e/0x240 [71820.290941]  [<ffffffff815fb11e>] ? __alloc_skb+0x4e/0x240 [71820.290941]  [<ffffffff816d8b65>] alloc_debug_processing+0x76/0x118 [71820.290941]  [<ffffffff816d981b>] __slab_alloc+0x50a/0x563 [71820.290941]  [<ffffffff810b7f4d>] ? trace_hardirqs_on+0xd/0x10 [71820.290941]  [<ffffffff815fb11e>] ? __alloc_skb+0x4e/0x240 [71820.290941]  [<ffffffff811a9dbe>] kmem_cache_alloc_node+0xfe/0x2a0 [71820.290941]  [<ffffffff815fb11e>] __alloc_skb+0x4e/0x240 [71820.290941]  [<ffffffff81666caa>] tcp_send_fin+0x7a/0x1a0 [71820.290941]  [<ffffffff81657f
 e6>] tcp_shutdown+0x46/0x60 [71820.290941]  [<ffffffff81682125>] inet_shutdown+0xb5/0x110 [71820.290941]  [<ffffffff815f3d17>] SyS_shutdown+0x47/0x70 [71820.290941]  [<ffffffff816e4e29>] system_call_fastpath+0x12/0x17 [71820.290941] FIX skbuff_fclone_cache: Restoring 0xffff8801eb42e756-0xffff8801eb42e756=0x6b

[71820.290941] FIX skbuff_fclone_cache: Marking all objects used

As I don't know where to file this I'm sending it to networking and Hyper-V people initially... If anyone can give tips on narrowing down the true cause that would be helpful. The workload is new and older kernels on Hyper-V hit other issues so bisection isn't an easy start...

--
Sitsofe | http://sucs.org/~sits/
