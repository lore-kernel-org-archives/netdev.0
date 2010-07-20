From: divya <dipraksh@linux.vnet.ibm.com>
Subject: Re: Badness with the kernel version 2.6.35-rc1-git1 running on P6
 box
Date: Tue, 20 Jul 2010 14:35:18 +0530
Message-ID: <4C4566CE.7020103@linux.vnet.ibm.com>
References: <4C401D56.3070108@linux.vnet.ibm.com> <1279274185.2549.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, linuxppc-dev@ozlabs.org,
	sachinp@linux.vnet.ibm.com, benh@kernel.crashing.org,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jan-Bernd Themann <ossthema@de.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1279274185.2549.14.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 16 July 2010 03:26 PM, Eric Dumazet wrote:
> Le vendredi 16 juillet 2010 =C3=A0 14:20 +0530, divya a =C3=A9crit :
>   =20
>> Hi ,
>>
>> With the latest kernel version 2.6.35-rc5-git1(2f7989efd4398) runnin=
g on power(p6) box came across the following
>> call trace
>>
>> Call Trace:
>> [c000000006a0e800] [c000000000011c30] .show_stack+0x6c/0x16c (unreli=
able)
>> [c000000006a0e8b0] [c00000000012129c] .__alloc_pages_nodemask+0x6a0/=
0x75c
>> [c000000006a0ea30] [c0000000001527cc] .alloc_pages_current+0xc4/0x10=
4
>> [c000000006a0ead0] [c00000000015b1a0] .new_slab+0xe0/0x314
>> [c000000006a0eb70] [c00000000015b6fc] .__slab_alloc+0x328/0x644
>> [c000000006a0ec50] [c00000000015cc34] .__kmalloc_node_track_caller+0=
x114/0x194
>> [c000000006a0ed00] [c000000000599f6c] .__alloc_skb+0x94/0x180
>> [c000000006a0edb0] [c00000000059af5c] .__netdev_alloc_skb+0x3c/0x74
>> [c000000006a0ee30] [c0000000004f9480] .ehea_refill_rq_def+0xf8/0x2d0
>> [c000000006a0ef30] [c0000000004fab8c] .ehea_up+0x5b8/0x69c
>> [c000000006a0f040] [c0000000004facd4] .ehea_open+0x64/0x118
>> [c000000006a0f0e0] [c0000000005a6e9c] .__dev_open+0x100/0x168
>> [c000000006a0f170] [c0000000005a3ac0] .__dev_change_flags+0x10c/0x1a=
c
>> [c000000006a0f210] [c0000000005a6d44] .dev_change_flags+0x24/0x7c
>> [c000000006a0f2a0] [c0000000005b50b4] .do_setlink+0x31c/0x750
>> [c000000006a0f3b0] [c0000000005b6724] .rtnl_newlink+0x388/0x618
>> [c000000006a0f5f0] [c0000000005b6350] .rtnetlink_rcv_msg+0x268/0x2b4
>> [c000000006a0f6a0] [c0000000005cfdc0] .netlink_rcv_skb+0x74/0x108
>> [c000000006a0f730] [c0000000005b60c4] .rtnetlink_rcv+0x38/0x5c
>> [c000000006a0f7c0] [c0000000005cf8c8] .netlink_unicast+0x318/0x3f4
>> [c000000006a0f890] [c0000000005d05b4] .netlink_sendmsg+0x2d0/0x310
>> [c000000006a0f970] [c00000000058e1e8] .sock_sendmsg+0xd4/0x110
>> [c000000006a0fb50] [c00000000058e514] .SyS_sendmsg+0x1f4/0x288
>> [c000000006a0fd70] [c00000000058c2b8] .SyS_socketcall+0x214/0x280
>> [c000000006a0fe30] [c0000000000085b4] syscall_exit+0x0/0x40
>> Mem-Info:
>> Node 0 DMA per-cpu:
>> CPU    0: hi:    0, btch:   1 usd:   0
>> CPU    1: hi:    0, btch:   1 usd:   0
>> CPU    2: hi:    0, btch:   1 usd:   0
>> CPU    3: hi:    0, btch:   1 usd:   0
>> active_anon:50 inactive_anon:260 isolated_anon:0
>>    active_file:159 inactive_file:139 isolated_file:0
>>    unevictable:0 dirty:2 writeback:1 unstable:0
>>    free:16 slab_reclaimable:66 slab_unreclaimable:502
>>    mapped:120 shmem:2 pagetables:37 bounce:0
>> Node 0 DMA free:1024kB min:1408kB low:1728kB high:2112kB active_anon=
:3200kB inactive_anon:16640kB active_file:10176kB inactive_file:8896kB =
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:130944kB =
mlocked:0kB dirty:128kB writeback:64kB mapped:7680kB shmem:128kB slab_r=
eclaimable:4224kB slab_unreclaimable:32128kB kernel_stack:2528kB pageta=
bles:2368kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 a=
ll_unreclaimable? no
>> lowmem_reserve[]: 0 0 0
>> Node 0 DMA: 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096k=
B 0*8192kB 0*16384kB =3D 0kB
>> 496 total pagecache pages
>> 178 pages in swap cache
>> Swap cache stats: add 780, delete 602, find 467/551
>> Free swap  =3D 1027904kB
>> Total swap =3D 1044160kB
>> 2048 pages RAM
>> 683 pages reserved
>> 582 pages shared
>> 1075 pages non-shared
>> SLUB: Unable to allocate memory on node -1 (gfp=3D0x20)
>>     cache: kmalloc-16384, object size: 16384, buffer size: 16384, de=
fault order: 2, min order: 0
>>     node 0: slabs: 28, objs: 292, free: 0
>> ip: page allocation failure. order:0, mode:0x8020
>> Call Trace:
>> [c000000006a0eb40] [c000000000011c30] .show_stack+0x6c/0x16c (unreli=
able)
>> [c000000006a0ebf0] [c00000000012129c] .__alloc_pages_nodemask+0x6a0/=
0x75c
>> [c000000006a0ed70] [c0000000001527cc] .alloc_pages_current+0xc4/0x10=
4
>> [c000000006a0ee10] [c00000000011fca4] .__get_free_pages+0x18/0x90
>> [c000000006a0ee90] [c0000000004f7058] .ehea_get_stats+0x4c/0x1bc
>> [c000000006a0ef30] [c0000000005a0a04] .dev_get_stats+0x38/0x64
>> [c000000006a0efc0] [c0000000005b456c] .rtnl_fill_ifinfo+0x35c/0x85c
>> [c000000006a0f150] [c0000000005b5920] .rtmsg_ifinfo+0x164/0x204
>> [c000000006a0f210] [c0000000005a6d6c] .dev_change_flags+0x4c/0x7c
>> [c000000006a0f2a0] [c0000000005b50b4] .do_setlink+0x31c/0x750
>> [c000000006a0f3b0] [c0000000005b6724] .rtnl_newlink+0x388/0x618
>> [c000000006a0f5f0] [c0000000005b6350] .rtnetlink_rcv_msg+0x268/0x2b4
>> [c000000006a0f6a0] [c0000000005cfdc0] .netlink_rcv_skb+0x74/0x108
>> [c000000006a0f730] [c0000000005b60c4] .rtnetlink_rcv+0x38/0x5c
>> [c000000006a0f7c0] [c0000000005cf8c8] .netlink_unicast+0x318/0x3f4
>> [c000000006a0f890] [c0000000005d05b4] .netlink_sendmsg+0x2d0/0x310
>> [c000000006a0f970] [c00000000058e1e8] .sock_sendmsg+0xd4/0x110
>> [c000000006a0fb50] [c00000000058e514] .SyS_sendmsg+0x1f4/0x288
>> [c000000006a0fd70] [c00000000058c2b8] .SyS_socketcall+0x214/0x280
>> [c000000006a0fe30] [c0000000000085b4] syscall_exit+0x0/0x40
>> Mem-Info:
>> Node 0 DMA per-cpu:
>> CPU    0: hi:    0, btch:   1 usd:   0
>> CPU    1: hi:    0, btch:   1 usd:   0
>> CPU    2: hi:    0, btch:   1 usd:   0
>> CPU    3: hi:    0, btch:   1 usd:   0
>>
>> The mainline 2.6.35-rc5 worked fine.
>>     =20
> Maybe you were lucky with 2.6.35-rc5
>
> Anyway ehea should not use GFP_ATOMIC in its ehea_get_stats() method,
> called in process context, but GFP_KERNEL.
>
> Another patch is needed for ehea_refill_rq_def() as well.
>
>
>
> [PATCH] ehea: ehea_get_stats() should use GFP_KERNEL
>
> ehea_get_stats() is called in process context and should use GFP_KERN=
EL
> allocation instead of GFP_ATOMIC.
>
> Clearing stats at beginning of ehea_get_stats() is racy in case of
> concurrent stat readers.
>
> get_stats() can also use netdev net_device_stats, instead of a privat=
e
> copy.
>
> Reported-by: divya<dipraksh@linux.vnet.ibm.com>
> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> ---
>   drivers/net/ehea/ehea.h      |    1 -
>   drivers/net/ehea/ehea_main.c |    6 ++----
>   2 files changed, 2 insertions(+), 5 deletions(-)
>   =20
Hi,

The call trace mentioned above still appears on upstream kernel and lin=
ux-next tree too.
The mentioned patch hasn't still been merged into upstream yet - hence =
getting call traces for both ehea_get_stats()
and ehea_refill_rq_def() methods.
However w.r.t to linux-next getting call trace only for ehea_refill_rq_=
def() method.

Thanks
Divya
