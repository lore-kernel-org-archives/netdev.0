From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [3.19.0-rc4+] rhashtable: BUG kmalloc-2048
 (Not tainted): Poison overwritten
Date: Tue, 20 Jan 2015 10:53:01 +0800
Message-ID: <54BDC30D.5000606@windriver.com>
References: <54BCBA35.2080103@windriver.com>
	<20150119125928.GB7672@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net, Netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20150119125928.GB7672@casper.infradead.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 01/19/2015 08:59 PM, Thomas Graf wrote:
> On 01/19/15 at 04:03pm, Ying Xue wrote:
>> On 3.19.0-rc4+, I encountered below error with attached test
>> case(bind_netlink.c). Please execute the following commands to reproduce
>> the error:
>>
>> gcc -Wall -o bind_netlink bind_netlink.c
>> ./bind_netlink 1000
>>
>> By the way, if we run another test case(bind_tipc.c), the similar issue
>> will happen on TIPC socket.
>>
>> Therefore, it seems that the issue is closely associated with rhashtable
>> instead of specific stacks like netlink or tipc.
> 
> Looks like a RCU read side critical section was missed. Does the TIPC
> poision warning look the same? offset 2048?
> 
> 

TIPC panic log is as below, and it's very similar to netlink.

Regards,
Ying

[   16.825649]
=============================================================================
[   16.826471] BUG TIPC (Not tainted): Poison overwritten
[   16.826941]
-----------------------------------------------------------------------------
[   16.826941]
[   16.827877] INFO: 0xffff880010c805a0-0xffff880010c805a7. First byte
0x33 instead of 0x6b
[   16.828682] INFO: Allocated in sk_prot_alloc+0x48/0x1b0 age=458 cpu=2
pid=4511
[   16.829383] 	__slab_alloc+0x453/0x4ba
[   16.829763] 	kmem_cache_alloc+0x225/0x340
[   16.830161] 	sk_prot_alloc+0x48/0x1b0
[   16.830508] 	sk_alloc+0x39/0x120
[   16.830817] 	tipc_sk_create+0x96/0x420 [tipc]
[   16.831239] 	__sock_create+0x299/0x390
[   16.831593] 	sock_create+0x30/0x40
[   16.831911] 	SyS_socket+0x36/0xb0
[   16.832238] 	compat_SyS_socketcall+0x6b/0x200
[   16.832648] 	sysenter_dispatch+0x7/0x1f
[   16.833028] INFO: Freed in __sk_free+0xdf/0x160 age=7 cpu=0 pid=3
[   16.833607] 	__slab_free+0x32/0x1f1
[   16.833929] 	kmem_cache_free+0x274/0x380
[   16.834319] 	__sk_free+0xdf/0x160
[   16.834634] 	sk_free+0x1d/0x30
[   16.834924] 	tipc_sk_callback+0x24/0x30 [tipc]
[   16.835359] 	rcu_process_callbacks+0x3e2/0x1320
[   16.835786] 	__do_softirq+0xdc/0x650
[   16.836134] 	run_ksoftirqd+0x2d/0x60
[   16.836514] 	smpboot_thread_fn+0x12e/0x1f0
[   16.837035] 	kthread+0xef/0x110
[   16.837351] 	ret_from_fork+0x7c/0xb0
[   16.837691] INFO: Slab 0xffffea0000432000 objects=18 used=0
fp=0xffff880010c83f00 flags=0x100000000004080
[   16.838611] INFO: Object 0xffff880010c80000 @offset=0 fp=0x
(null)
[   16.838611]
[   16.839400] Object ffff880010c80000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.840267] Object ffff880010c80010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.841130] Object ffff880010c80020: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.841998] Object ffff880010c80030: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.842872] Object ffff880010c80040: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.843752] Object ffff880010c80050: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.844624] Object ffff880010c80060: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.845487] Object ffff880010c80070: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.846506] Object ffff880010c80080: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.847455] Object ffff880010c80090: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.848360] Object ffff880010c800a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.849242] Object ffff880010c800b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.850148] Object ffff880010c800c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.851046] Object ffff880010c800d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.851962] Object ffff880010c800e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.852911] Object ffff880010c800f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.853791] Object ffff880010c80100: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.854681] Object ffff880010c80110: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.855545] Object ffff880010c80120: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.856414] Object ffff880010c80130: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.857280] Object ffff880010c80140: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.858201] Object ffff880010c80150: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.859068] Object ffff880010c80160: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.859928] Object ffff880010c80170: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.860800] Object ffff880010c80180: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.861672] Object ffff880010c80190: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.862579] Object ffff880010c801a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.863480] Object ffff880010c801b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.864357] Object ffff880010c801c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.865234] Object ffff880010c801d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.866146] Object ffff880010c801e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.867023] Object ffff880010c801f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.867904] Object ffff880010c80200: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.868781] Object ffff880010c80210: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.869648] Object ffff880010c80220: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.870556] Object ffff880010c80230: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.871429] Object ffff880010c80240: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.872302] Object ffff880010c80250: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.873179] Object ffff880010c80260: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.874085] Object ffff880010c80270: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.874966] Object ffff880010c80280: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.875862] Object ffff880010c80290: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.876741] Object ffff880010c802a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.877656] Object ffff880010c802b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.878562] Object ffff880010c802c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.879461] Object ffff880010c802d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.880355] Object ffff880010c802e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.881250] Object ffff880010c802f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.882160] Object ffff880010c80300: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.883041] Object ffff880010c80310: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.883999] Object ffff880010c80320: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.884895] Object ffff880010c80330: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.885770] Object ffff880010c80340: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.886673] Object ffff880010c80350: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.887573] Object ffff880010c80360: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.888487] Object ffff880010c80370: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.889384] Object ffff880010c80380: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.890285] Object ffff880010c80390: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.891182] Object ffff880010c803a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.892058] Object ffff880010c803b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.892925] Object ffff880010c803c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.893817] Object ffff880010c803d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.894698] Object ffff880010c803e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.895625] Object ffff880010c803f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.896528] Object ffff880010c80400: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.897424] Object ffff880010c80410: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.898329] Object ffff880010c80420: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.899226] Object ffff880010c80430: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.900155] Object ffff880010c80440: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.901043] Object ffff880010c80450: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.901912] Object ffff880010c80460: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.902830] Object ffff880010c80470: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.903714] Object ffff880010c80480: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.904630] Object ffff880010c80490: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.905526] Object ffff880010c804a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.906428] Object ffff880010c804b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.907321] Object ffff880010c804c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.908221] Object ffff880010c804d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.909109] Object ffff880010c804e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.909991] Object ffff880010c804f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.910877] Object ffff880010c80500: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.911774] Object ffff880010c80510: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.912689] Object ffff880010c80520: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.913601] Object ffff880010c80530: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.914547] Object ffff880010c80540: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.915441] Object ffff880010c80550: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.916334] Object ffff880010c80560: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.917229] Object ffff880010c80570: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.918126] Object ffff880010c80580: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.919009] Object ffff880010c80590: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   16.919887] Object ffff880010c805a0: 33 02 00 00 00 00 00 00 6b 6b 6b
6b 6b 6b 6b 6b  3.......kkkkkkkk
[   16.920779] Object ffff880010c805b0: 6b 6b 6b 6b 6b 6b 6b a5
                 kkkkkkk.
[   16.921595] Redzone ffff880010c805b8: bb bb bb bb bb bb bb bb
                  ........
[   16.922450] Padding ffff880010c806f8: 5a 5a 5a 5a 5a 5a 5a 5a
                  ZZZZZZZZ
[   16.923380] FIX TIPC: Restoring
0xffff880010c805a0-0xffff880010c805a7=0x6b
[   16.923380]
[   17.033416] BUG: unable to handle kernel paging request at
ffffffffffffff77
[   17.034009] IP: [<ffffffffa0019b8c>] jhash+0xec/0x160 [tipc]
[   17.034009] PGD 2212067 PUD 2214067 PMD 0
[   17.034009] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   17.034009] Modules linked in: tipc
[   17.034009] CPU: 2 PID: 411 Comm: kworker/2:1 Tainted: G    B
  3.19.0-rc4+ #110
[   17.034009] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[   17.034009] Workqueue: events rht_deferred_worker
[   17.034009] task: ffff880015b8cae0 ti: ffff880015440000 task.ti:
ffff880015440000
[   17.034009] RIP: 0010:[<ffffffffa0019b8c>]  [<ffffffffa0019b8c>]
jhash+0xec/0x160 [tipc]
[   17.034009] RSP: 0018:ffff880015443c18  EFLAGS: 00010293
[   17.034009] RAX: 00000000c910c82d RBX: ffff88000d844000 RCX:
00000000c910c82d
[   17.034009] RDX: 00000000ea63093a RSI: 0000000000000004 RDI:
ffffffffffffff74
[   17.034009] RBP: ffff880015443c18 R08: 00000000c910c82d R09:
ffffffffffffff74
[   17.034009] R10: 0000000000000000 R11: 0000000000000001 R12:
ffff880012b7b6a0
[   17.034009] R13: ffff8800100d31e8 R14: 0000000000000245 R15:
ffff88000d844000
[   17.034009] FS:  0000000000000000(0000) GS:ffff880016200000(0000)
knlGS:0000000000000000
[   17.034009] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   17.034009] CR2: ffffffffffffff77 CR3: 0000000002211000 CR4:
00000000000006e0
[   17.034009] Stack:
[   17.034009]  ffff880015443c38 ffffffff813b38e9 0000000000000175
0000000000000000
[   17.034009]  ffff880015443cc8 ffffffff813b475b ffff88000dc628a0
0000000000000001
[   17.034009]  ffffc90000955368 0000000000000175 ffff88000d844000
ffff8800100d31e8
[   17.034009] Call Trace:
[   17.034009]  [<ffffffff813b38e9>] head_hashfn+0x29/0x50
[   17.034009]  [<ffffffff813b475b>] rhashtable_expand+0x37b/0x680
[   17.034009]  [<ffffffff813b4b38>] rht_deferred_worker+0xd8/0xe0
[   17.034009]  [<ffffffff81074d10>] process_one_work+0x200/0x800
[   17.034009]  [<ffffffff81074c71>] ? process_one_work+0x161/0x800
[   17.034009]  [<ffffffff81074c71>] ? process_one_work+0x161/0x800
[   17.034009]  [<ffffffff8107533c>] process_scheduled_works+0x2c/0x40
[   17.034009]  [<ffffffff810758d3>] worker_thread+0x253/0x4b0
[   17.034009]  [<ffffffff81075680>] ? rescuer_thread+0x330/0x330
[   17.034009]  [<ffffffff8107bb6f>] kthread+0xef/0x110
[   17.034009]  [<ffffffff8107ba80>] ? flush_kthread_work+0x170/0x170
[   17.034009]  [<ffffffff81a44a2c>] ret_from_fork+0x7c/0xb0
[   17.034009]  [<ffffffff8107ba80>] ? flush_kthread_work+0x170/0x170
[   17.034009] Code: 01 d0 41 0f b6 51 07 c1 e2 18 41 01 d0 41 0f b6 51
06 c1 e2 10 41 01 d0 41 0f b6 51 05 c1 e2 08 41 01 d0 41 0f b6 51 04 41
01 d0 <41> 0f b6 51 03 c1 e2 18 01 d1 41 0f b6 51 02 c1 e2 10 01 d1 41
[   17.034009] RIP  [<ffffffffa0019b8c>] jhash+0xec/0x160 [tipc]
[   17.034009]  RSP <ffff880015443c18>
[   17.034009] CR2: ffffffffffffff77
[   17.034009] ---[ end trace 5abb1862651dca6a ]---
[   17.034009] Kernel panic - not syncing: Fatal exception in interrupt
[   17.034009] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation
range: 0xffffffff80000000-0xffffffff9fffffff)
[   17.034009] ---[ end Kernel panic - not syncing: Fatal exception in
interrupt



------------------------------------------------------------------------------
New Year. New Location. New Benefits. New Data Center in Ashburn, VA.
GigeNET is offering a free month of service with a new server in Ashburn.
Choose from 2 high performing configs, both with 100TB of bandwidth.
Higher redundancy.Lower latency.Increased capacity.Completely compliant.
http://p.sf.net/sfu/gigenet
