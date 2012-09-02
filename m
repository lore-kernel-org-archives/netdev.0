From: David Madore <david+ml@madore.org>
Subject: Re: kernel 3.2.27 on arm: WARNING: at mm/page_alloc.c:2109
 __alloc_pages_nodemask+0x1d4/0x68c()
Date: Mon, 3 Sep 2012 00:51:58 +0200
Message-ID: <20120902225158.GA25164@aldebaran.gro-tsen.net>
References: <20120829002548.GA7063@aldebaran.gro-tsen.net>
 <alpine.LSU.2.00.1208311900330.1936@eggly.anvils>
 <20120901082018.GA16762@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hugh Dickins <hughd@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120901082018.GA16762@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since I had a rare occasion to physically access the machine, I did
the following experiment: connect another machine to the serial
console, run

while true ; do date ; cat /proc/slabinfo ; echo '***' ; sleep 3 ; done

and generate lots of IPv6 traffic through the box (as I mentioned, for
some reason, a Firefox compilation through ssh seems particularly
effective).  So I now have lots of slabinfo data and, beyond the
initial WARNING, I also got messages along the lines of "swapper: page
allocation failure: order:10, mode:0x4020".

I put the full log in <URL:
http://www.madore.org/~david/.tmp/pollux-dump.0
 > (unfortunately a bit garbled, because sometimes the cat slabinfo
was interspaced with printk output, but there are still plenty of
usable lines of each sort).

For completeness, here's a sample message from a page allocation
failure, and a copy of /proc/slabinfo from just about that time (I
have no idea how to read this, but one thing I can say is that there
is no extraordinarily large number in this):

[  567.757489] swapper: page allocation failure: order:10, mode:0x4020
[  567.763815] [<c000d728>] (unwind_backtrace+0x0/0xf0) from [<c009a87c>] (warn_alloc_failed+0xcc/0x10c)
[  567.773119] [<c009a87c>] (warn_alloc_failed+0xcc/0x10c) from [<c009ce48>] (__alloc_pages_nodemask+0x530/0x68c)
[  567.783184] [<c009ce48>] (__alloc_pages_nodemask+0x530/0x68c) from [<c009cfb4>] (__get_free_pages+0x10/0x3c)
[  567.793084] [<c009cfb4>] (__get_free_pages+0x10/0x3c) from [<c00c9fd0>] (kmalloc_order_trace+0x24/0xdc)
[  567.802547] [<c00c9fd0>] (kmalloc_order_trace+0x24/0xdc) from [<c038d638>] (pskb_expand_head+0x68/0x298)
[  567.812317] [<c038d638>] (pskb_expand_head+0x68/0x298) from [<bf0e93ec>] (ip6_forward+0x4d4/0x7bc [ipv6])
[  567.822056] [<bf0e93ec>] (ip6_forward+0x4d4/0x7bc [ipv6]) from [<bf0ebebc>] (ipv6_rcv+0x2bc/0x3dc [ipv6])
[  567.831751] [<bf0ebebc>] (ipv6_rcv+0x2bc/0x3dc [ipv6]) from [<c0394870>] (__netif_receive_skb+0x544/0x66c)
[  567.841521] [<c0394870>] (__netif_receive_skb+0x544/0x66c) from [<bf1d9054>] (br_nf_pre_routing_finish_ipv6+0x10c/0x160 [bridge])
[  567.853306] [<bf1d9054>] (br_nf_pre_routing_finish_ipv6+0x10c/0x160 [bridge]) from [<bf1d9ae8>] (br_nf_pre_routing+0x59c/0x67c [bridge])
[  567.865673] [<bf1d9ae8>] (br_nf_pre_routing+0x59c/0x67c [bridge]) from [<c03bd2a4>] (nf_iterate+0x8c/0xb4)
[  567.875387] [<c03bd2a4>] (nf_iterate+0x8c/0xb4) from [<c03bd328>] (nf_hook_slow+0x5c/0x118)
[  567.883800] [<c03bd328>] (nf_hook_slow+0x5c/0x118) from [<bf1d3fa4>] (br_handle_frame+0x1b8/0x290 [bridge])
[  567.893624] [<bf1d3fa4>] (br_handle_frame+0x1b8/0x290 [bridge]) from [<c03946f8>] (__netif_receive_skb+0x3cc/0x66c)
[  567.904137] [<c03946f8>] (__netif_receive_skb+0x3cc/0x66c) from [<c031e254>] (mv643xx_eth_poll+0x540/0x734)
[  567.913928] [<c031e254>] (mv643xx_eth_poll+0x540/0x734) from [<c0397390>] (net_rx_action+0x118/0x314)
[  567.923215] [<c0397390>] (net_rx_action+0x118/0x314) from [<c0029924>] (__do_softirq+0xac/0x234)
[  567.932058] [<c0029924>] (__do_softirq+0xac/0x234) from [<c0029f00>] (irq_exit+0x94/0x9c)
[  567.940421] [<c0029f00>] (irq_exit+0x94/0x9c) from [<c00094b0>] (handle_IRQ+0x34/0x84)
[  567.948392] [<c00094b0>] (handle_IRQ+0x34/0x84) from [<c04398d4>] (__irq_svc+0x34/0x98)
[  567.956454] [<c04398d4>] (__irq_svc+0x34/0x98) from [<c0011d6c>] (kirkwood_enter_idle+0x4c/0x94)
[  567.965299] [<c0011d6c>] (kirkwood_enter_idle+0x4c/0x94) from [<c0357a00>] (cpuidle_idle_call+0xc8/0x35c)
[  567.974925] [<c0357a00>] (cpuidle_idle_call+0xc8/0x35c) from [<c0009764>] (cpu_idle+0x88/0xdc)
[  567.983581] [<c0009764>] (cpu_idle+0x88/0xdc) from [<c05d8720>] (start_kernel+0x2a0/0x2f0)
[  567.991893] Mem-info:
[  567.994185] Normal per-cpu:
[  567.996995] CPU    0: hi:  186, btch:  31 usd:  84
[  568.001815] active_anon:5592 inactive_anon:34 isolated_anon:0
[  568.001820]  active_file:2845 inactive_file:6118 isolated_file:0
[  568.001825]  unevictable:418 dirty:13 writeback:0 unstable:0
[  568.001829]  free:12507 slab_reclaimable:632 slab_unreclaimable:1124
[  568.001835]  mapped:2546 shmem:47 pagetables:152 bounce:0
[  568.031126] Normal free:50028kB min:2884kB low:3604kB high:4324kB active_anon:22368kB inactive_anon:136kB active_file:11380kB inactive_file:24472kB unevictable:1672kB isolated(anon):0kB isolated(file):0kB present:520192kB mlocked:1672kB dirty:52kB writeback:0kB mapped:10184kB shmem:188kB slab_reclaimable:2528kB slab_unreclaimable:4496kB kernel_stack:584kB pagetables:608kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  568.071329] lowmem_reserve[]: 0 0
[  568.074696] Normal: 1*4kB 1*8kB 8*16kB 7*32kB 0*64kB 2*128kB 1*256kB 4*512kB 20*1024kB 11*2048kB 1*4096kB = 50028kB
[  568.085282] 9350 total pagecache pages
[  568.089039] 0 pages in swap cache
[  568.092363] Swap cache stats: add 0, delete 0, find 0/0
[  568.097621] Free swap  = 0kB
[  568.100506] Total swap = 0kB
[  568.117927] 131072 pages of RAM
[  568.121087] 12771 free pages
[  568.123972] 2839 reserved pages
[  568.127140] 1361 slab pages
[  568.129945] 8003 pages shared
[  568.132919] 0 pages swap cached

slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
nf_conntrack_expect      0      0    176   23    1 : tunables    0    0    0 : slabdata      0      0      0
nf_conntrack_c06d1258    128    128    248   16    1 : tunables    0    0    0 : slabdata      8      8      0
ip6_dst_cache         72     72    224   18    1 : tunables    0    0    0 : slabdata      4      4      0
RAWv6                 11     11    704   11    2 : tunables    0    0    0 : slabdata      1      1      0
UDPLITEv6              0      0    704   11    2 : tunables    0    0    0 : slabdata      0      0      0
UDPv6                 33     33    704   11    2 : tunables    0    0    0 : slabdata      3      3      0
tw_sock_TCPv6          0      0    160   25    1 : tunables    0    0    0 : slabdata      0      0      0
TCPv6                 12     12   1344   12    4 : tunables    0    0    0 : slabdata      1      1      0
ubifs_inode_slab       0      0    408   10    1 : tunables    0    0    0 : slabdata      0      0      0
mqueue_inode_cache      8      8    512    8    1 : tunables    0    0    0 : slabdata      1      1      0
jffs2_xattr_datum      0      0     56   73    1 : tunables    0    0    0 : slabdata      0      0      0
jffs2_refblock         0      0    248   16    1 : tunables    0    0    0 : slabdata      0      0      0
jffs2_i                0      0    360   11    1 : tunables    0    0    0 : slabdata      0      0      0
fat_inode_cache        0      0    392   10    1 : tunables    0    0    0 : slabdata      0      0      0
fat_cache              0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
jbd2_revoke_record      0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
journal_handle       170    170     24  170    1 : tunables    0    0    0 : slabdata      1      1      0
revoke_record        256    256     16  256    1 : tunables    0    0    0 : slabdata      1      1      0
ext4_inode_cache       0      0    568   14    2 : tunables    0    0    0 : slabdata      0      0      0
ext4_free_data         0      0     40  102    1 : tunables    0    0    0 : slabdata      0      0      0
ext4_allocation_context      0      0    112   36    1 : tunables    0    0    0 : slabdata      0      0      0
ext4_io_end            0      0    576   14    2 : tunables    0    0    0 : slabdata      0      0      0
ext4_io_page           0      0      8  512    1 : tunables    0    0    0 : slabdata      0      0      0
ext2_inode_cache       0      0    448    9    1 : tunables    0    0    0 : slabdata      0      0      0
ext3_inode_cache     952    952    464   17    2 : tunables    0    0    0 : slabdata     56     56      0
ext3_xattr             0      0     56   73    1 : tunables    0    0    0 : slabdata      0      0      0
dquot                  0      0    160   25    1 : tunables    0    0    0 : slabdata      0      0      0
dnotify_mark          56     56     72   56    1 : tunables    0    0    0 : slabdata      1      1      0
dio                    0      0    320   12    1 : tunables    0    0    0 : slabdata      0      0      0
UNIX                  27     27    448    9    1 : tunables    0    0    0 : slabdata      3      3      0
UDP-Lite               0      0    544   15    2 : tunables    0    0    0 : slabdata      0      0      0
arp_cache             28     28    288   14    1 : tunables    0    0    0 : slabdata      2      2      0
RAW                   15     15    544   15    2 : tunables    0    0    0 : slabdata      1      1      0
UDP                   45     45    544   15    2 : tunables    0    0    0 : slabdata      3      3      0
tw_sock_TCP           32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
TCP                   13     13   1216   13    4 : tunables    0    0    0 : slabdata      1      1      0
eventpoll_pwq        102    102     40  102    1 : tunables    0    0    0 : slabdata      1      1      0
blkdev_requests       54     54    216   18    1 : tunables    0    0    0 : slabdata      3      3      0
blkdev_ioc             0      0     48   85    1 : tunables    0    0    0 : slabdata      0      0      0
fsnotify_event_holder    256    256     16  256    1 : tunables    0    0    0 : slabdata      1      1      0
biovec-256            10     10   3072   10    8 : tunables    0    0    0 : slabdata      1      1      0
biovec-128             0      0   1536   10    4 : tunables    0    0    0 : slabdata      0      0      0
biovec-64             10     10    768   10    2 : tunables    0    0    0 : slabdata      1      1      0
sock_inode_cache     143    143    352   11    1 : tunables    0    0    0 : slabdata     13     13      0
file_lock_cache       36     36    112   36    1 : tunables    0    0    0 : slabdata      1      1      0
net_namespace          0      0   1248   13    4 : tunables    0    0    0 : slabdata      0      0      0
shmem_inode_cache    715    715    352   11    1 : tunables    0    0    0 : slabdata     65     65      0
taskstats             12     12    328   12    1 : tunables    0    0    0 : slabdata      1      1      0
proc_inode_cache     350    396    352   11    1 : tunables    0    0    0 : slabdata     36     36      0
sigqueue              56     56    144   28    1 : tunables    0    0    0 : slabdata      2      2      0
bdev_cache             9      9    448    9    1 : tunables    0    0    0 : slabdata      1      1      0
sysfs_dir_cache    11118  11118     80   51    1 : tunables    0    0    0 : slabdata    218    218      0
filp                 925    925    160   25    1 : tunables    0    0    0 : slabdata     37     37      0
inode_cache         2508   2508    320   12    1 : tunables    0    0    0 : slabdata    209    209      0
dentry              4928   4928    128   32    1 : tunables    0    0    0 : slabdata    154    154      0
buffer_head         1984   1984     64   64    1 : tunables    0    0    0 : slabdata     31     31      0
vm_area_struct      1932   1932     88   46    1 : tunables    0    0    0 : slabdata     42     42      0
mm_struct             50     50    384   10    1 : tunables    0    0    0 : slabdata      5      5      0
signal_cache          84     84    640   12    2 : tunables    0    0    0 : slabdata      7      7      0
sighand_cache         84     84   1312   12    4 : tunables    0    0    0 : slabdata      7      7      0
task_struct           90     90   1088   15    4 : tunables    0    0    0 : slabdata      6      6      0
anon_vma_chain      2210   2210     24  170    1 : tunables    0    0    0 : slabdata     13     13      0
anon_vma            1280   1280     32  128    1 : tunables    0    0    0 : slabdata     10     10      0
radix_tree_node      962    962    304   13    1 : tunables    0    0    0 : slabdata     74     74      0
idr_layer_cache      260    260    152   26    1 : tunables    0    0    0 : slabdata     10     10      0
kmalloc-8192          44     44   8192    4    8 : tunables    0    0    0 : slabdata     11     11      0
kmalloc-4096         114    128   4096    8    8 : tunables    0    0    0 : slabdata     16     16      0
kmalloc-2048          88    160   2048    8    4 : tunables    0    0    0 : slabdata     20     20      0
kmalloc-1024         176    176   1024    8    2 : tunables    0    0    0 : slabdata     22     22      0
kmalloc-512          504    504    512    8    1 : tunables    0    0    0 : slabdata     63     63      0
kmalloc-256          240    240    256   16    1 : tunables    0    0    0 : slabdata     15     15      0
kmalloc-128          512    512    128   32    1 : tunables    0    0    0 : slabdata     16     16      0
kmalloc-64          1728   1728     64   64    1 : tunables    0    0    0 : slabdata     27     27      0
kmalloc-32         10240  10240     32  128    1 : tunables    0    0    0 : slabdata     80     80      0
kmalloc-192          546    546    192   21    1 : tunables    0    0    0 : slabdata     26     26      0
kmalloc-96          1092   1092     96   42    1 : tunables    0    0    0 : slabdata     26     26      0
kmem_cache            32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
kmem_cache_node      128    128     32  128    1 : tunables    0    0    0 : slabdata      1      1      0

-- 
     David A. Madore
   ( http://www.madore.org/~david/ )
