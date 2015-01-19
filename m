From: Ying Xue <ying.xue@windriver.com>
Subject: [3.19.0-rc4+] rhashtable: BUG kmalloc-2048 (Not
 tainted): Poison overwritten
Date: Mon, 19 Jan 2015 16:03:01 +0800
Message-ID: <54BCBA35.2080103@windriver.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070203020005010608090708"
Cc: tipc-discussion@lists.sourceforge.net, Netdev <netdev@vger.kernel.org>
To: <tgraf@suug.ch>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--------------070203020005010608090708
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit

On 3.19.0-rc4+, I encountered below error with attached test
case(bind_netlink.c). Please execute the following commands to reproduce
the error:

gcc -Wall -o bind_netlink bind_netlink.c
./bind_netlink 1000

By the way, if we run another test case(bind_tipc.c), the similar issue
will happen on TIPC socket.

Therefore, it seems that the issue is closely associated with rhashtable
instead of specific stacks like netlink or tipc.

Regards,
Ying

root@localhost:/mnt# [  135.472382]
=============================================================================
[  135.473303] BUG kmalloc-2048 (Not tainted): Poison overwritten
[  135.473905]
-----------------------------------------------------------------------------
[  135.473905]
[  135.474894] INFO: 0xffff8800115d86d0-0xffff8800115d86d7. First byte
0x11 instead of 0x6b
[  135.475715] INFO: Allocated in sk_prot_alloc+0xcb/0x1b0 age=87 cpu=5
pid=4536
[  135.476381] 	__slab_alloc+0x453/0x4ba
[  135.476745] 	__kmalloc+0x23f/0x370
[  135.477115] 	sk_prot_alloc+0xcb/0x1b0
[  135.477477] 	sk_alloc+0x39/0x120
[  135.477777] 	__netlink_create+0x44/0xe0
[  135.478144] 	netlink_create+0xfc/0x260
[  135.478539] 	__sock_create+0x299/0x390
[  135.478881] 	sock_create+0x30/0x40
[  135.479207] 	SyS_socket+0x36/0xb0
[  135.479561] 	compat_SyS_socketcall+0x6b/0x200
[  135.479959] 	sysenter_dispatch+0x7/0x1f
[  135.480345] INFO: Freed in __sk_free+0x118/0x160 age=9 cpu=0 pid=3
[  135.480929] 	__slab_free+0x32/0x1f1
[  135.481284] 	kfree+0x304/0x350
[  135.481593] 	__sk_free+0x118/0x160
[  135.481900] 	sk_free+0x1d/0x30
[  135.482214] 	deferred_put_nlk_sk+0x24/0x30
[  135.482638] 	rcu_process_callbacks+0x3e2/0x1320
[  135.483154] 	__do_softirq+0xdc/0x650
[  135.483537] 	run_ksoftirqd+0x2d/0x60
[  135.483881] 	smpboot_thread_fn+0x12e/0x1f0
[  135.484283] 	kthread+0xef/0x110
[  135.484603] 	ret_from_fork+0x7c/0xb0
[  135.484936] INFO: Slab 0xffffea0000457600 objects=13 used=0
fp=0xffff8800115db7b0 flags=0x100000000004080
[  135.485816] INFO: Object 0xffff8800115d8000 @offset=0 fp=0x
(null)
[  135.485816]
[  135.486629] Object ffff8800115d8000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.487495] Object ffff8800115d8010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.488358] Object ffff8800115d8020: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.489207] Object ffff8800115d8030: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.490090] Object ffff8800115d8040: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.490932] Object ffff8800115d8050: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.491774] Object ffff8800115d8060: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.492663] Object ffff8800115d8070: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.493524] Object ffff8800115d8080: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.494428] Object ffff8800115d8090: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.495307] Object ffff8800115d80a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.496195] Object ffff8800115d80b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.497058] Object ffff8800115d80c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.497915] Object ffff8800115d80d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.498814] Object ffff8800115d80e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.499700] Object ffff8800115d80f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.500561] Object ffff8800115d8100: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.501447] Object ffff8800115d8110: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.502310] Object ffff8800115d8120: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.503216] Object ffff8800115d8130: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.504079] Object ffff8800115d8140: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.504938] Object ffff8800115d8150: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.505807] Object ffff8800115d8160: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.506714] Object ffff8800115d8170: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.507599] Object ffff8800115d8180: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.508486] Object ffff8800115d8190: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.509348] Object ffff8800115d81a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.510264] Object ffff8800115d81b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.511198] Object ffff8800115d81c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.512106] Object ffff8800115d81d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.512959] Object ffff8800115d81e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.513819] Object ffff8800115d81f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.514708] Object ffff8800115d8200: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.515569] Object ffff8800115d8210: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.516436] Object ffff8800115d8220: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.517276] Object ffff8800115d8230: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.518135] Object ffff8800115d8240: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.519042] Object ffff8800115d8250: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.519909] Object ffff8800115d8260: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.520750] Object ffff8800115d8270: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.521617] Object ffff8800115d8280: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.522477] Object ffff8800115d8290: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.523376] Object ffff8800115d82a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.524222] Object ffff8800115d82b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.525116] Object ffff8800115d82c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.525948] Object ffff8800115d82d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.526821] Object ffff8800115d82e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.527744] Object ffff8800115d82f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.528615] Object ffff8800115d8300: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.529506] Object ffff8800115d8310: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.530376] Object ffff8800115d8320: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.531287] Object ffff8800115d8330: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.532158] Object ffff8800115d8340: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.533044] Object ffff8800115d8350: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.533876] Object ffff8800115d8360: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.534774] Object ffff8800115d8370: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.535676] Object ffff8800115d8380: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.536524] Object ffff8800115d8390: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.537392] Object ffff8800115d83a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.538246] Object ffff8800115d83b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.539174] Object ffff8800115d83c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.540069] Object ffff8800115d83d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.540929] Object ffff8800115d83e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.541796] Object ffff8800115d83f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.542689] Object ffff8800115d8400: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.543555] Object ffff8800115d8410: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.544435] Object ffff8800115d8420: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.545325] Object ffff8800115d8430: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.546211] Object ffff8800115d8440: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.547127] Object ffff8800115d8450: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.547981] Object ffff8800115d8460: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.548848] Object ffff8800115d8470: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.549741] Object ffff8800115d8480: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.550632] Object ffff8800115d8490: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.551522] Object ffff8800115d84a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.552398] Object ffff8800115d84b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.553299] Object ffff8800115d84c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.554181] Object ffff8800115d84d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.555073] Object ffff8800115d84e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.555907] Object ffff8800115d84f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.556776] Object ffff8800115d8500: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.557668] Object ffff8800115d8510: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.558564] Object ffff8800115d8520: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.559462] Object ffff8800115d8530: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.560359] Object ffff8800115d8540: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.561247] Object ffff8800115d8550: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.562116] Object ffff8800115d8560: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.563020] Object ffff8800115d8570: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.563866] Object ffff8800115d8580: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.564714] Object ffff8800115d8590: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.565605] Object ffff8800115d85a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.566453] Object ffff8800115d85b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.567333] Object ffff8800115d85c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.568200] Object ffff8800115d85d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.569090] Object ffff8800115d85e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.569900] Object ffff8800115d85f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.570779] Object ffff8800115d8600: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.571651] Object ffff8800115d8610: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.572497] Object ffff8800115d8620: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.573425] Object ffff8800115d8630: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.574263] Object ffff8800115d8640: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.575243] Object ffff8800115d8650: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.576104] Object ffff8800115d8660: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.576987] Object ffff8800115d8670: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.577856] Object ffff8800115d8680: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.578746] Object ffff8800115d8690: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.579616] Object ffff8800115d86a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.580503] Object ffff8800115d86b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.581371] Object ffff8800115d86c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.582256] Object ffff8800115d86d0: 11 00 00 00 00 00 00 00 6b 6b 6b
6b 6b 6b 6b 6b  ........kkkkkkkk
[  135.583150] Object ffff8800115d86e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.584027] Object ffff8800115d86f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.584869] Object ffff8800115d8700: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.585734] Object ffff8800115d8710: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.586648] Object ffff8800115d8720: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.587519] Object ffff8800115d8730: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.588404] Object ffff8800115d8740: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.589273] Object ffff8800115d8750: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.590158] Object ffff8800115d8760: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.590993] Object ffff8800115d8770: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.591858] Object ffff8800115d8780: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.592742] Object ffff8800115d8790: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.593630] Object ffff8800115d87a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.594547] Object ffff8800115d87b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.595417] Object ffff8800115d87c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.596434] Object ffff8800115d87d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.597308] Object ffff8800115d87e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.598226] Object ffff8800115d87f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  135.599105] Redzone ffff8800115d8800: bb bb bb bb bb bb bb bb
                  ........
[  135.599933] Padding ffff8800115d8940: 5a 5a 5a 5a 5a 5a 5a 5a
                  ZZZZZZZZ
[  135.600877] FIX kmalloc-2048: Restoring
0xffff8800115d86d0-0xffff8800115d86d7=0x6b
[  135.600877]
[  135.604042]
=============================================================================
[  135.604764] BUG kmalloc-2048 (Tainted: G    B         ): Poison
overwritten
[  135.605456]
-----------------------------------------------------------------------------
[  135.605456]
[  135.606398] INFO: 0xffff880012a21018-0xffff880012a2101f. First byte
0x1 instead of 0x6b
[  135.607184] INFO: Allocated in sk_prot_alloc+0xcb/0x1b0 age=217 cpu=5
pid=4536
[  135.607862] 	__slab_alloc+0x453/0x4ba
[  135.608236] 	__kmalloc+0x23f/0x370
[  135.608575] 	sk_prot_alloc+0xcb/0x1b0
[  135.608910] 	sk_alloc+0x39/0x120
[  135.609250] 	__netlink_create+0x44/0xe0
[  135.609628] 	netlink_create+0xfc/0x260
[  135.609968] 	__sock_create+0x299/0x390
[  135.610346] 	sock_create+0x30/0x40
[  135.610711] 	SyS_socket+0x36/0xb0
[  135.611073] 	compat_SyS_socketcall+0x6b/0x200
[  135.611516] 	sysenter_dispatch+0x7/0x1f
[  135.611878] INFO: Freed in __sk_free+0x118/0x160 age=8 cpu=0 pid=51
[  135.612474] 	__slab_free+0x32/0x1f1
[  135.612821] 	kfree+0x304/0x350
[  135.613143] 	__sk_free+0x118/0x160
[  135.613485] 	sk_free+0x1d/0x30
[  135.613767] 	deferred_put_nlk_sk+0x24/0x30
[  135.614157] 	rcu_process_callbacks+0x3e2/0x1320
[  135.614603] 	__do_softirq+0xdc/0x650
[  135.614931] 	irq_exit+0x8e/0xb0
[  135.615259] 	smp_apic_timer_interrupt+0x4a/0x60
[  135.615729] 	apic_timer_interrupt+0x6f/0x80
[  135.616150] 	__slab_free+0x50/0x1f1
[  135.616522] 	kmem_cache_free+0x274/0x380
[  135.616879] 	free_obj_work+0x6c/0xa0
[  135.617247] 	process_one_work+0x200/0x800
[  135.617668] 	worker_thread+0x11a/0x4b0
[  135.618030] 	kthread+0xef/0x110
[  135.618347] INFO: Slab 0xffffea00004a8800 objects=13 used=0
fp=0xffff880012a237b0 flags=0x100000000004080
[  135.619246] INFO: Object 0xffff880012a20948 @offset=2376
fp=0xffff880012a26f60
[  135.619246]
[  135.620069] Bytes b4 ffff880012a20938: d3 7d fd ff 00 00 00 00 5a 5a
5a 5a 5a 5a 5a 5a  .}......ZZZZZZZZ
[  135.620916] Object ffff880012a20948: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.621785] Object ffff880012a20958: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.622718] Object ffff880012a20968: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.623574] Object ffff880012a20978: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.624472] Object ffff880012a20988: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.625324] Object ffff880012a20998: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.626190] Object ffff880012a209a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.627069] Object ffff880012a209b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.627973] Object ffff880012a209c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.628887] Object ffff880012a209d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.629818] Object ffff880012a209e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.630753] Object ffff880012a209f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.631649] Object ffff880012a20a08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.632524] Object ffff880012a20a18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.633417] Object ffff880012a20a28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.634283] Object ffff880012a20a38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.635176] Object ffff880012a20a48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.636047] Object ffff880012a20a58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.636946] Object ffff880012a20a68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.637819] Object ffff880012a20a78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.638735] Object ffff880012a20a88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.639606] Object ffff880012a20a98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.640515] Object ffff880012a20aa8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.641388] Object ffff880012a20ab8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.642281] Object ffff880012a20ac8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.643171] Object ffff880012a20ad8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.644100] Object ffff880012a20ae8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.644932] Object ffff880012a20af8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.645800] Object ffff880012a20b08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.646724] Object ffff880012a20b18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.647592] Object ffff880012a20b28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.648481] Object ffff880012a20b38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.649352] Object ffff880012a20b48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.650242] Object ffff880012a20b58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.651137] Object ffff880012a20b68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.652017] Object ffff880012a20b78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.652860] Object ffff880012a20b88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.653729] Object ffff880012a20b98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.654648] Object ffff880012a20ba8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.655518] Object ffff880012a20bb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.656410] Object ffff880012a20bc8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.657285] Object ffff880012a20bd8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.658176] Object ffff880012a20be8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.659068] Object ffff880012a20bf8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.659942] Object ffff880012a20c08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.660830] Object ffff880012a20c18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.661718] Object ffff880012a20c28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.662614] Object ffff880012a20c38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.663504] Object ffff880012a20c48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.664374] Object ffff880012a20c58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.665276] Object ffff880012a20c68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.666161] Object ffff880012a20c78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.667070] Object ffff880012a20c88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.667928] Object ffff880012a20c98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.668795] Object ffff880012a20ca8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.669689] Object ffff880012a20cb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.670585] Object ffff880012a20cc8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.671478] Object ffff880012a20cd8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.672350] Object ffff880012a20ce8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.673239] Object ffff880012a20cf8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.674131] Object ffff880012a20d08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.675014] Object ffff880012a20d18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.675857] Object ffff880012a20d28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.676743] Object ffff880012a20d38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.677636] Object ffff880012a20d48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.678511] Object ffff880012a20d58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.679402] Object ffff880012a20d68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.680274] Object ffff880012a20d78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.681164] Object ffff880012a20d88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.682056] Object ffff880012a20d98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.682920] Object ffff880012a20da8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.683788] Object ffff880012a20db8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.684680] Object ffff880012a20dc8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.685562] Object ffff880012a20dd8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.686496] Object ffff880012a20de8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.687346] Object ffff880012a20df8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.688218] Object ffff880012a20e08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.689076] Object ffff880012a20e18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.689940] Object ffff880012a20e28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.690821] Object ffff880012a20e38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.691691] Object ffff880012a20e48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.692540] Object ffff880012a20e58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.693427] Object ffff880012a20e68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.694348] Object ffff880012a20e78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.695277] Object ffff880012a20e88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.696255] Object ffff880012a20e98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.697147] Object ffff880012a20ea8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.698020] Object ffff880012a20eb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.698907] Object ffff880012a20ec8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.699778] Object ffff880012a20ed8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.700697] Object ffff880012a20ee8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.701549] Object ffff880012a20ef8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.702418] Object ffff880012a20f08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.703270] Object ffff880012a20f18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.704187] Object ffff880012a20f28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.705032] Object ffff880012a20f38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.705900] Object ffff880012a20f48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.706792] Object ffff880012a20f58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.707660] Object ffff880012a20f68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.708530] Object ffff880012a20f78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.709397] Object ffff880012a20f88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.710268] Object ffff880012a20f98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.711162] Object ffff880012a20fa8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.712020] Object ffff880012a20fb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.712901] Object ffff880012a20fc8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.713749] Object ffff880012a20fd8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.714668] Object ffff880012a20fe8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.715536] Object ffff880012a20ff8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.716427] Object ffff880012a21008: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.717300] Object ffff880012a21018: 01 00 00 00 00 00 00 00 6b 6b 6b
6b 6b 6b 6b 6b  ........kkkkkkkk
[  135.718187] Object ffff880012a21028: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.719107] Object ffff880012a21038: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.719969] Object ffff880012a21048: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.720838] Object ffff880012a21058: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.721735] Object ffff880012a21068: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.722629] Object ffff880012a21078: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.723520] Object ffff880012a21088: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.724387] Object ffff880012a21098: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.725297] Object ffff880012a210a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.726262] Object ffff880012a210b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.727163] Object ffff880012a210c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.728027] Object ffff880012a210d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.728908] Object ffff880012a210e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.729784] Object ffff880012a210f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.730700] Object ffff880012a21108: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.731572] Object ffff880012a21118: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.732462] Object ffff880012a21128: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.733333] Object ffff880012a21138: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  135.734221] Redzone ffff880012a21148: bb bb bb bb bb bb bb bb
                  ........
[  135.735028] Padding ffff880012a21288: 5a 5a 5a 5a 5a 5a 5a 5a
                  ZZZZZZZZ
[  135.735961] FIX kmalloc-2048: Restoring
0xffff880012a21018-0xffff880012a2101f=0x6b
[  135.735961]
[  135.736819]
=============================================================================
[  135.737663] BUG kmalloc-2048 (Tainted: G    B         ): Poison
overwritten
[  135.738326]
-----------------------------------------------------------------------------
[  135.738326]
[  135.739267] INFO: 0xffff880012a22bf0-0xffff880012a22bf7. First byte
0x19 instead of 0x6b
[  135.739993] INFO: Allocated in sk_prot_alloc+0xcb/0x1b0 age=349 cpu=5
pid=4536
[  135.740676] 	__slab_alloc+0x453/0x4ba
[  135.741069] 	__kmalloc+0x23f/0x370
[  135.741381] 	sk_prot_alloc+0xcb/0x1b0
[  135.741715] 	sk_alloc+0x39/0x120
[  135.742046] 	__netlink_create+0x44/0xe0
[  135.742424] 	netlink_create+0xfc/0x260
[  135.742790] 	__sock_create+0x299/0x390
[  135.743170] 	sock_create+0x30/0x40
[  135.743510] 	SyS_socket+0x36/0xb0
[  135.743821] 	compat_SyS_socketcall+0x6b/0x200
[  135.744278] 	sysenter_dispatch+0x7/0x1f
[  135.744660] INFO: Freed in __sk_free+0x118/0x160 age=141 cpu=0 pid=51
[  135.745278] 	__slab_free+0x32/0x1f1
[  135.745624] 	kfree+0x304/0x350
[  135.745905] 	__sk_free+0x118/0x160
[  135.746255] 	sk_free+0x1d/0x30
[  135.746587] 	deferred_put_nlk_sk+0x24/0x30
[  135.746957] 	rcu_process_callbacks+0x3e2/0x1320
[  135.747405] 	__do_softirq+0xdc/0x650
[  135.747761] 	irq_exit+0x8e/0xb0
[  135.748089] 	smp_apic_timer_interrupt+0x4a/0x60
[  135.748529] 	apic_timer_interrupt+0x6f/0x80
[  135.748910] 	__slab_free+0x50/0x1f1
[  135.749267] 	kmem_cache_free+0x274/0x380
[  135.749655] 	free_obj_work+0x6c/0xa0
[  135.749980] 	process_one_work+0x200/0x800
[  135.750403] 	worker_thread+0x11a/0x4b0
[  135.750824] 	kthread+0xef/0x110
[  135.751151] INFO: Slab 0xffffea00004a8800 objects=13 used=0
fp=0xffff880012a237b0 flags=0x100000000004080
[  135.752083] INFO: Object 0xffff880012a22520 @offset=9504
fp=0xffff880012a25388
[  135.752083]
[  135.752864] Bytes b4 ffff880012a22510: d3 7d fd ff 00 00 00 00 5a 5a
5a 5a 5a 5a 5a 5a  .}......ZZZZZZZZ
[  135.753747] Object ffff880012a22520: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.754676] Object ffff880012a22530: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.755541] Object ffff880012a22540: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.756441] Object ffff880012a22550: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.757327] Object ffff880012a22560: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.758222] Object ffff880012a22570: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.759118] Object ffff880012a22580: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.760067] Object ffff880012a22590: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.760946] Object ffff880012a225a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.761818] Object ffff880012a225b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.762717] Object ffff880012a225c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.763589] Object ffff880012a225d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.764498] Object ffff880012a225e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.765372] Object ffff880012a225f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.766264] Object ffff880012a22600: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.767161] Object ffff880012a22610: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.768038] Object ffff880012a22620: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.768871] Object ffff880012a22630: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.769767] Object ffff880012a22640: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.770676] Object ffff880012a22650: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.771547] Object ffff880012a22660: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.772457] Object ffff880012a22670: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.773327] Object ffff880012a22680: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.774222] Object ffff880012a22690: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.775119] Object ffff880012a226a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.775981] Object ffff880012a226b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.776868] Object ffff880012a226c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.777754] Object ffff880012a226d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.778649] Object ffff880012a226e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.779563] Object ffff880012a226f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.780454] Object ffff880012a22700: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.781384] Object ffff880012a22710: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.782259] Object ffff880012a22720: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.783173] Object ffff880012a22730: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.784061] Object ffff880012a22740: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.784914] Object ffff880012a22750: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.785807] Object ffff880012a22760: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.786726] Object ffff880012a22770: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.787611] Object ffff880012a22780: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.788509] Object ffff880012a22790: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.789381] Object ffff880012a227a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.790300] Object ffff880012a227b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.791199] Object ffff880012a227c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.792087] Object ffff880012a227d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.792919] Object ffff880012a227e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.793789] Object ffff880012a227f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.794700] Object ffff880012a22800: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.795571] Object ffff880012a22810: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.796458] Object ffff880012a22820: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.797350] Object ffff880012a22830: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.798237] Object ffff880012a22840: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.799131] Object ffff880012a22850: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.800001] Object ffff880012a22860: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.800879] Object ffff880012a22870: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.801779] Object ffff880012a22880: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.802687] Object ffff880012a22890: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.803578] Object ffff880012a228a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.804453] Object ffff880012a228b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.805361] Object ffff880012a228c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.806230] Object ffff880012a228d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.807141] Object ffff880012a228e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.807972] Object ffff880012a228f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.808837] Object ffff880012a22900: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.809728] Object ffff880012a22910: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.810626] Object ffff880012a22920: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.811513] Object ffff880012a22930: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.812384] Object ffff880012a22940: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.813268] Object ffff880012a22950: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.814152] Object ffff880012a22960: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.815056] Object ffff880012a22970: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.815913] Object ffff880012a22980: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.816769] Object ffff880012a22990: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.817665] Object ffff880012a229a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.818558] Object ffff880012a229b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.819447] Object ffff880012a229c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.820360] Object ffff880012a229d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.821250] Object ffff880012a229e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.822123] Object ffff880012a229f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.823036] Object ffff880012a22a00: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.823878] Object ffff880012a22a10: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.824749] Object ffff880012a22a20: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.825640] Object ffff880012a22a30: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.826532] Object ffff880012a22a40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.827438] Object ffff880012a22a50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.828305] Object ffff880012a22a60: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.829194] Object ffff880012a22a70: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.830064] Object ffff880012a22a80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.830959] Object ffff880012a22a90: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.831829] Object ffff880012a22aa0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.832717] Object ffff880012a22ab0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.833587] Object ffff880012a22ac0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.834502] Object ffff880012a22ad0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.835390] Object ffff880012a22ae0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.836276] Object ffff880012a22af0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.837146] Object ffff880012a22b00: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.838060] Object ffff880012a22b10: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.838939] Object ffff880012a22b20: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.839808] Object ffff880012a22b30: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.840714] Object ffff880012a22b40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.841600] Object ffff880012a22b50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.842513] Object ffff880012a22b60: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.843387] Object ffff880012a22b70: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.844296] Object ffff880012a22b80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.845167] Object ffff880012a22b90: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.846052] Object ffff880012a22ba0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.846909] Object ffff880012a22bb0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.847778] Object ffff880012a22bc0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.848669] Object ffff880012a22bd0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.849541] Object ffff880012a22be0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.850451] Object ffff880012a22bf0: 19 00 00 00 00 00 00 00 6b 6b 6b
6b 6b 6b 6b 6b  ........kkkkkkkk
[  135.851346] Object ffff880012a22c00: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.852239] Object ffff880012a22c10: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.853110] Object ffff880012a22c20: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.853982] Object ffff880012a22c30: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.854871] Object ffff880012a22c40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.855763] Object ffff880012a22c50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.856637] Object ffff880012a22c60: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.857545] Object ffff880012a22c70: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.858412] Object ffff880012a22c80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.859330] Object ffff880012a22c90: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.860198] Object ffff880012a22ca0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.861113] Object ffff880012a22cb0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.861947] Object ffff880012a22cc0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.862840] Object ffff880012a22cd0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.863730] Object ffff880012a22ce0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.864600] Object ffff880012a22cf0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.865507] Object ffff880012a22d00: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.866392] Object ffff880012a22d10: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  135.867303] Redzone ffff880012a22d20: bb bb bb bb bb bb bb bb
                  ........
[  135.868142] Padding ffff880012a22e60: 5a 5a 5a 5a 5a 5a 5a 5a
                  ZZZZZZZZ
[  135.869131] FIX kmalloc-2048: Restoring
0xffff880012a22bf0-0xffff880012a22bf7=0x6b
[  135.869131]
[  135.870023]
=============================================================================
[  135.870812] BUG kmalloc-2048 (Tainted: G    B         ): Poison
overwritten
[  135.871496]
-----------------------------------------------------------------------------
[  135.871496]
[  135.872425] INFO: 0xffff880012a23538-0xffff880012a2353f. First byte
0xb instead of 0x6b
[  135.873184] INFO: Allocated in sk_prot_alloc+0xcb/0x1b0 age=483 cpu=5
pid=4536
[  135.873869] 	__slab_alloc+0x453/0x4ba
[  135.874249] 	__kmalloc+0x23f/0x370
[  135.874612] 	sk_prot_alloc+0xcb/0x1b0
[  135.874943] 	sk_alloc+0x39/0x120
[  135.875291] 	__netlink_create+0x44/0xe0
[  135.875678] 	netlink_create+0xfc/0x260
[  135.876040] 	__sock_create+0x299/0x390
[  135.876423] 	sock_create+0x30/0x40
[  135.876745] 	SyS_socket+0x36/0xb0
[  135.877077] 	compat_SyS_socketcall+0x6b/0x200
[  135.877515] 	sysenter_dispatch+0x7/0x1f
[  135.877877] INFO: Freed in __sk_free+0x118/0x160 age=274 cpu=0 pid=51
[  135.878527] 	__slab_free+0x32/0x1f1
[  135.878878] 	kfree+0x304/0x350
[  135.879198] 	__sk_free+0x118/0x160
[  135.879537] 	sk_free+0x1d/0x30
[  135.879819] 	deferred_put_nlk_sk+0x24/0x30
[  135.880234] 	rcu_process_callbacks+0x3e2/0x1320
[  135.880693] 	__do_softirq+0xdc/0x650
[  135.881058] 	irq_exit+0x8e/0xb0
[  135.881375] 	smp_apic_timer_interrupt+0x4a/0x60
[  135.881807] 	apic_timer_interrupt+0x6f/0x80
[  135.882225] 	__slab_free+0x50/0x1f1
[  135.882598] 	kmem_cache_free+0x274/0x380
[  135.882954] 	free_obj_work+0x6c/0xa0
[  135.883319] 	process_one_work+0x200/0x800
[  135.883716] 	worker_thread+0x11a/0x4b0
[  135.884101] 	kthread+0xef/0x110
[  135.884419] INFO: Slab 0xffffea00004a8800 objects=13 used=0
fp=0xffff880012a237b0 flags=0x100000000004080
[  135.885313] INFO: Object 0xffff880012a22e68 @offset=11880
fp=0xffff880012a24a40
[  135.885313]
[  135.886157] Bytes b4 ffff880012a22e58: d3 7d fd ff 00 00 00 00 5a 5a
5a 5a 5a 5a 5a 5a  .}......ZZZZZZZZ
[  135.887067] Object ffff880012a22e68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.887946] Object ffff880012a22e78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.888812] Object ffff880012a22e88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.889701] Object ffff880012a22e98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.890596] Object ffff880012a22ea8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.891489] Object ffff880012a22eb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.892383] Object ffff880012a22ec8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.893272] Object ffff880012a22ed8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.894143] Object ffff880012a22ee8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.895058] Object ffff880012a22ef8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.895891] Object ffff880012a22f08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.896756] Object ffff880012a22f18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.897645] Object ffff880012a22f28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.898557] Object ffff880012a22f38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.899449] Object ffff880012a22f48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.900319] Object ffff880012a22f58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.901227] Object ffff880012a22f68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.902123] Object ffff880012a22f78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.903029] Object ffff880012a22f88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.903884] Object ffff880012a22f98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.904754] Object ffff880012a22fa8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.905686] Object ffff880012a22fb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.906595] Object ffff880012a22fc8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.907492] Object ffff880012a22fd8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.908368] Object ffff880012a22fe8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.909258] Object ffff880012a22ff8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.910129] Object ffff880012a23008: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.911031] Object ffff880012a23018: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.911873] Object ffff880012a23028: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.912748] Object ffff880012a23038: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.913656] Object ffff880012a23048: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.914566] Object ffff880012a23058: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.915458] Object ffff880012a23068: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.916415] Object ffff880012a23078: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.917303] Object ffff880012a23088: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.918175] Object ffff880012a23098: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.919111] Object ffff880012a230a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.919937] Object ffff880012a230b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.920818] Object ffff880012a230c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.921702] Object ffff880012a230d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.922609] Object ffff880012a230e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.923493] Object ffff880012a230f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.924363] Object ffff880012a23108: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.925250] Object ffff880012a23118: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.926151] Object ffff880012a23128: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.927093] Object ffff880012a23138: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.927920] Object ffff880012a23148: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.928780] Object ffff880012a23158: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.929679] Object ffff880012a23168: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.930581] Object ffff880012a23178: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.931466] Object ffff880012a23188: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.932352] Object ffff880012a23198: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.933258] Object ffff880012a231a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.934138] Object ffff880012a231b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.935032] Object ffff880012a231c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.935890] Object ffff880012a231d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.936745] Object ffff880012a231e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.937632] Object ffff880012a231f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.938512] Object ffff880012a23208: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.939400] Object ffff880012a23218: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.940275] Object ffff880012a23228: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.941179] Object ffff880012a23238: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.942033] Object ffff880012a23248: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.942929] Object ffff880012a23258: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.943793] Object ffff880012a23268: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.944681] Object ffff880012a23278: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.945544] Object ffff880012a23288: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.946426] Object ffff880012a23298: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.947314] Object ffff880012a232a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.948221] Object ffff880012a232b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.949086] Object ffff880012a232c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.949939] Object ffff880012a232d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.950826] Object ffff880012a232e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.951713] Object ffff880012a232f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.952571] Object ffff880012a23308: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.953468] Object ffff880012a23318: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.954336] Object ffff880012a23328: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.955249] Object ffff880012a23338: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.956111] Object ffff880012a23348: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.956968] Object ffff880012a23358: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.957831] Object ffff880012a23368: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.958758] Object ffff880012a23378: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.959621] Object ffff880012a23388: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.960510] Object ffff880012a23398: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.961395] Object ffff880012a233a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.962283] Object ffff880012a233b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.963191] Object ffff880012a233c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.964093] Object ffff880012a233d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.964914] Object ffff880012a233e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.965795] Object ffff880012a233f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.966701] Object ffff880012a23408: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.967568] Object ffff880012a23418: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.968477] Object ffff880012a23428: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.969339] Object ffff880012a23438: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.970239] Object ffff880012a23448: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.971136] Object ffff880012a23458: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.972013] Object ffff880012a23468: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.972852] Object ffff880012a23478: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.973736] Object ffff880012a23488: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.974649] Object ffff880012a23498: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.975514] Object ffff880012a234a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.976404] Object ffff880012a234b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.977272] Object ffff880012a234c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.978160] Object ffff880012a234d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.979074] Object ffff880012a234e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.979936] Object ffff880012a234f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.980821] Object ffff880012a23508: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.981709] Object ffff880012a23518: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.982601] Object ffff880012a23528: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.983511] Object ffff880012a23538: 0b 00 00 00 00 00 00 00 6b 6b 6b
6b 6b 6b 6b 6b  ........kkkkkkkk
[  135.984378] Object ffff880012a23548: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.985266] Object ffff880012a23558: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.986153] Object ffff880012a23568: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.987063] Object ffff880012a23578: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.987889] Object ffff880012a23588: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.988771] Object ffff880012a23598: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.989657] Object ffff880012a235a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.990549] Object ffff880012a235b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.991435] Object ffff880012a235c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.992302] Object ffff880012a235d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.993205] Object ffff880012a235e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.994113] Object ffff880012a235f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.995015] Object ffff880012a23608: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.995862] Object ffff880012a23618: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.996727] Object ffff880012a23628: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.997619] Object ffff880012a23638: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.998504] Object ffff880012a23648: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  135.999403] Object ffff880012a23658: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  136.000272] Redzone ffff880012a23668: bb bb bb bb bb bb bb bb
                  ........
[  136.001147] Padding ffff880012a237a8: 5a 5a 5a 5a 5a 5a 5a 5a
                  ZZZZZZZZ
[  136.002113] FIX kmalloc-2048: Restoring
0xffff880012a23538-0xffff880012a2353f=0x6b
[  136.002113]
[  136.003026]
=============================================================================
[  136.003764] BUG kmalloc-2048 (Tainted: G    B         ): Poison
overwritten
[  136.004423]
-----------------------------------------------------------------------------
[  136.004423]
[  136.005338] INFO: 0xffff880012a25a58-0xffff880012a25a5f. First byte
0x13 instead of 0x6b
[  136.006101] INFO: Allocated in sk_prot_alloc+0xcb/0x1b0 age=616 cpu=5
pid=4536
[  136.006801] 	__slab_alloc+0x453/0x4ba
[  136.007175] 	__kmalloc+0x23f/0x370
[  136.007515] 	sk_prot_alloc+0xcb/0x1b0
[  136.007851] 	sk_alloc+0x39/0x120
[  136.008185] 	__netlink_create+0x44/0xe0
[  136.008575] 	netlink_create+0xfc/0x260
[  136.008927] 	__sock_create+0x299/0x390
[  136.009307] 	sock_create+0x30/0x40
[  136.009649] 	SyS_socket+0x36/0xb0
[  136.009953] 	compat_SyS_socketcall+0x6b/0x200
[  136.010386] 	sysenter_dispatch+0x7/0x1f
[  136.010790] INFO: Freed in __sk_free+0x118/0x160 age=407 cpu=0 pid=51
[  136.011404] 	__slab_free+0x32/0x1f1
[  136.011752] 	kfree+0x304/0x350
[  136.012072] 	__sk_free+0x118/0x160
[  136.012411] 	sk_free+0x1d/0x30
[  136.012692] 	deferred_put_nlk_sk+0x24/0x30
[  136.013101] 	rcu_process_callbacks+0x3e2/0x1320
[  136.013540] 	__do_softirq+0xdc/0x650
[  136.013864] 	irq_exit+0x8e/0xb0
[  136.014194] 	smp_apic_timer_interrupt+0x4a/0x60
[  136.014658] 	apic_timer_interrupt+0x6f/0x80
[  136.015077] 	__slab_free+0x50/0x1f1
[  136.015445] 	kmem_cache_free+0x274/0x380
[  136.015802] 	free_obj_work+0x6c/0xa0
[  136.016166] 	process_one_work+0x200/0x800
[  136.016560] 	worker_thread+0x11a/0x4b0
[  136.016899] 	kthread+0xef/0x110
[  136.017225] INFO: Slab 0xffffea00004a8800 objects=13 used=0
fp=0xffff880012a237b0 flags=0x100000000004080
[  136.018139] INFO: Object 0xffff880012a25388 @offset=21384
fp=0xffff880012a21bd8
[  136.018139]
[  136.018951] Bytes b4 ffff880012a25378: d3 7d fd ff 00 00 00 00 5a 5a
5a 5a 5a 5a 5a 5a  .}......ZZZZZZZZ
[  136.019831] Object ffff880012a25388: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.020720] Object ffff880012a25398: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.021592] Object ffff880012a253a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.022504] Object ffff880012a253b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.023377] Object ffff880012a253c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.024286] Object ffff880012a253d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.025159] Object ffff880012a253e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.026070] Object ffff880012a253f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.026926] Object ffff880012a25408: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.027788] Object ffff880012a25418: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.028675] Object ffff880012a25428: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.029561] Object ffff880012a25438: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.030465] Object ffff880012a25448: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.031342] Object ffff880012a25458: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.032236] Object ffff880012a25468: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.033105] Object ffff880012a25478: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.033975] Object ffff880012a25488: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.034867] Object ffff880012a25498: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.035756] Object ffff880012a254a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.036620] Object ffff880012a254b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.037505] Object ffff880012a254c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.038371] Object ffff880012a254d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.039287] Object ffff880012a254e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.040152] Object ffff880012a254f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.041039] Object ffff880012a25508: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.041879] Object ffff880012a25518: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.042766] Object ffff880012a25528: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.043655] Object ffff880012a25538: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.044523] Object ffff880012a25548: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.045436] Object ffff880012a25558: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.046327] Object ffff880012a25568: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.047237] Object ffff880012a25578: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.048106] Object ffff880012a25588: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.048977] Object ffff880012a25598: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.049832] Object ffff880012a255a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.050745] Object ffff880012a255b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.051612] Object ffff880012a255c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.052503] Object ffff880012a255d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.053371] Object ffff880012a255e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.054275] Object ffff880012a255f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.055171] Object ffff880012a25608: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.056072] Object ffff880012a25618: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.056901] Object ffff880012a25628: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.057767] Object ffff880012a25638: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.058676] Object ffff880012a25648: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.059548] Object ffff880012a25658: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.060440] Object ffff880012a25668: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.061335] Object ffff880012a25678: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.062227] Object ffff880012a25688: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.063127] Object ffff880012a25698: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.063999] Object ffff880012a256a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.064852] Object ffff880012a256b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.065743] Object ffff880012a256c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.066634] Object ffff880012a256d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.067526] Object ffff880012a256e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.068392] Object ffff880012a256f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.069284] Object ffff880012a25708: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.070151] Object ffff880012a25718: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.071072] Object ffff880012a25728: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.071901] Object ffff880012a25738: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.072787] Object ffff880012a25748: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.073679] Object ffff880012a25758: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.074573] Object ffff880012a25768: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.075486] Object ffff880012a25778: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.076381] Object ffff880012a25788: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.077272] Object ffff880012a25798: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.078139] Object ffff880012a257a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.079041] Object ffff880012a257b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.079903] Object ffff880012a257c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.080769] Object ffff880012a257d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.081664] Object ffff880012a257e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.082555] Object ffff880012a257f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.083449] Object ffff880012a25808: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.084335] Object ffff880012a25818: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.085232] Object ffff880012a25828: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.086106] Object ffff880012a25838: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.087004] Object ffff880012a25848: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.087888] Object ffff880012a25858: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.088770] Object ffff880012a25868: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.089681] Object ffff880012a25878: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.090593] Object ffff880012a25888: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.091501] Object ffff880012a25898: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.092364] Object ffff880012a258a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.093275] Object ffff880012a258b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.094162] Object ffff880012a258c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.095071] Object ffff880012a258d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.095922] Object ffff880012a258e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.096786] Object ffff880012a258f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.097677] Object ffff880012a25908: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.098571] Object ffff880012a25918: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.099476] Object ffff880012a25928: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.100343] Object ffff880012a25938: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.101233] Object ffff880012a25948: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.102100] Object ffff880012a25958: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.102982] Object ffff880012a25968: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.103873] Object ffff880012a25978: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.104762] Object ffff880012a25988: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.105650] Object ffff880012a25998: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.106569] Object ffff880012a259a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.107435] Object ffff880012a259b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.108324] Object ffff880012a259c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.109190] Object ffff880012a259d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.110096] Object ffff880012a259e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.110955] Object ffff880012a259f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.111820] Object ffff880012a25a08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.112709] Object ffff880012a25a18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.113596] Object ffff880012a25a28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.114507] Object ffff880012a25a38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.115384] Object ffff880012a25a48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.116272] Object ffff880012a25a58: 13 00 00 00 00 00 00 00 6b 6b 6b
6b 6b 6b 6b 6b  ........kkkkkkkk
[  136.117138] Object ffff880012a25a68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.118030] Object ffff880012a25a78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.118927] Object ffff880012a25a88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.119810] Object ffff880012a25a98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.120729] Object ffff880012a25aa8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.121610] Object ffff880012a25ab8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.122521] Object ffff880012a25ac8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.123385] Object ffff880012a25ad8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.124283] Object ffff880012a25ae8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.125162] Object ffff880012a25af8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.126046] Object ffff880012a25b08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.126906] Object ffff880012a25b18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.127767] Object ffff880012a25b28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.128655] Object ffff880012a25b38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.129532] Object ffff880012a25b48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.130431] Object ffff880012a25b58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.131318] Object ffff880012a25b68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  136.132208] Object ffff880012a25b78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  136.133075] Redzone ffff880012a25b88: bb bb bb bb bb bb bb bb
                  ........
[  136.133877] Padding ffff880012a25cc8: 5a 5a 5a 5a 5a 5a 5a 5a
                  ZZZZZZZZ
[  136.134900] FIX kmalloc-2048: Restoring
0xffff880012a25a58-0xffff880012a25a5f=0x6b
[  136.134900]



--------------070203020005010608090708
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
New Year. New Location. New Benefits. New Data Center in Ashburn, VA.
GigeNET is offering a free month of service with a new server in Ashburn.
Choose from 2 high performing configs, both with 100TB of bandwidth.
Higher redundancy.Lower latency.Increased capacity.Completely compliant.
http://p.sf.net/sfu/gigenet
--------------070203020005010608090708
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
tipc-discussion mailing list
tipc-discussion@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/tipc-discussion

--------------070203020005010608090708--
