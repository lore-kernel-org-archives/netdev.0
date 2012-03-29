From: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
Subject: Re: 3.2.8/amd64 full interrupt hangs and deadlocks under big network copies (page allocation failure)
Date: Thu, 29 Mar 2012 09:41:52 -0700
Message-ID: <20120329164152.GI24933@merlins.org>
References: <20120329163800.GH24933@merlins.org> <20120311183244.GA14001@merlins.org> <20120329053111.GD24933@merlins.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120329163800.GH24933-xnduUnryOU1AfugRpC6u6w@public.gmane.org> <20120329053111.GD24933-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

As an update I upgraded the laptop from 4GB to 8GB and I still cannot to a big
copy via NFS without the laptop hanging pretty badly.

To be clear, I've had the problem both over wired ethernet (e1000e) and
intel 5300agn (iwlwifi)

Doing the same copy with rsync over ssh worked.
I also did a big NFS copy inbound instead of outbound and that seems to have
worke too.

Can someone tell me there is something I can do to work around the problem,
and get the underlying problem fixed.
(well, looks like not using NFS is the workaround)

Thanks,
Marc

I tried the copy over wifi this time instead of e1000e, and got:

mc: page allocation failure: order:1, mode:0x20
Pid: 7099, comm: mc Tainted: G        W  O 3.2.8-amd64-volpreempt-noide-20120208 #1
Call Trace:
 <IRQ>  [<ffffffff810b9ec0>] ? warn_alloc_failed+0x11f/0x132
 [<ffffffff810bcdaa>] ? __alloc_pages_nodemask+0x6b1/0x72f
 [<ffffffff810ec911>] ? kmem_getpages+0x4c/0xd9
 [<ffffffff810ec911>] ? kmem_getpages+0x4c/0xd9
 [<ffffffff810edd21>] ? fallback_alloc+0x123/0x1c2
 [<ffffffff812846db>] ? pskb_expand_head+0xe0/0x24a
 [<ffffffff810ee215>] ? __kmalloc+0xb2/0x10a
 [<ffffffff812846db>] ? pskb_expand_head+0xe0/0x24a
 [<ffffffffa096a2c1>] ? ieee80211_skb_resize+0x64/0x9d [mac80211]
 [<ffffffffa096c252>] ? ieee80211_subif_start_xmit+0x705/0x883 [mac80211]
 [<ffffffff81036108>] ? test_tsk_need_resched+0xe/0x17
 [<ffffffff8128e767>] ? dev_hard_start_xmit+0x40b/0x552
 [<ffffffff8104c8ec>] ? raise_softirq_irqoff+0x6/0x27
 [<ffffffff812a4adc>] ? sch_direct_xmit+0x63/0x13a
 [<ffffffff8128eb8e>] ? dev_queue_xmit+0x2e0/0x4b5
 [<ffffffff812b764d>] ? ip_finish_output2+0x1c7/0x218
 [<ffffffff812b86aa>] ? __ip_flush_pending_frames.isra.29+0x69/0x69
 [<ffffffff812b8a6a>] ? ip_queue_xmit+0x2cd/0x30d
 [<ffffffff81066be9>] ? getnstimeofday+0x4a/0x7b
 [<ffffffff812ca1d2>] ? tcp_transmit_skb+0x6d7/0x70a
 [<ffffffff812cac5f>] ? tcp_write_xmit+0x698/0x7a1
 [<ffffffff812c77bf>] ? tcp_ack+0x14e3/0x1658
 [<ffffffff812c89bd>] ? tcp_established_options+0x2b/0x9e
 [<ffffffff812cada9>] ? __tcp_push_pending_frames+0x18/0x44
 [<ffffffff812c4e27>] ? tcp_data_snd_check+0x2c/0xfd
 [<ffffffff812c86c5>] ? tcp_rcv_established+0x4f0/0x549
 [<ffffffff812ce735>] ? tcp_v4_do_rcv+0x166/0x323
 [<ffffffff812cfdce>] ? tcp_v4_rcv+0x404/0x65d
 [<ffffffff81036108>] ? test_tsk_need_resched+0xe/0x17
 [<ffffffff812b4d55>] ? ip_local_deliver_finish+0x148/0x1ba
 [<ffffffff8128cfa4>] ? __netif_receive_skb+0x3f2/0x43f
 [<ffffffff8128d31d>] ? netif_receive_skb+0x7e/0x84
 [<ffffffffa0966bd6>] ? ieee80211_deliver_skb+0xbb/0xf1 [mac80211]
 [<ffffffffa0967f32>] ? ieee80211_rx_handlers+0x1041/0x18a7 [mac80211]
 [<ffffffff810528d2>] ? lock_timer_base.isra.29+0x23/0x47
 [<ffffffff81071629>] ? arch_local_irq_save+0x11/0x17
 [<ffffffff8134b58b>] ? _raw_spin_lock_irqsave+0x1c/0x41
 [<ffffffffa0966730>] ? ieee80211_release_reorder_frame+0x35/0x4a [mac80211]
 [<ffffffffa0968fb2>] ? ieee80211_prepare_and_rx_handle+0x81a/0x872 [mac80211]
 [<ffffffffa09696e6>] ? ieee80211_rx+0x6dc/0x706 [mac80211]
 [<ffffffffa09a20e4>] ? iwlagn_rx_reply_rx+0x3c2/0x3dc [iwlwifi]
 [<ffffffff810398a1>] ? resched_task+0x48/0x6c
 [<ffffffffa09ab9f8>] ? iwl_irq_tasklet+0x446/0x6df [iwlwifi]
 [<ffffffff81039ff4>] ? check_preempt_curr+0x52/0x5f
 [<ffffffff8104c445>] ? tasklet_action+0x79/0xc8
 [<ffffffff8104c581>] ? __do_softirq+0xc0/0x188
 [<ffffffff81351fac>] ? call_softirq+0x1c/0x30
 [<ffffffff8100f98d>] ? do_softirq+0x3c/0x7b
 [<ffffffff8104c87c>] ? irq_exit+0x3d/0xa7
 [<ffffffff8100f6b4>] ? do_IRQ+0x81/0x97
 [<ffffffff8134ba2e>] ? common_interrupt+0x6e/0x6e
 <EOI>  [<ffffffff8134fe84>] ? sysret_audit+0x16/0x20
Mem-Info:
Node 0 DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 173
CPU    1: hi:  186, btch:  31 usd: 134
Node 0 Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 157
CPU    1: hi:  186, btch:  31 usd: 101
active_anon:1031319 inactive_anon:207860 isolated_anon:0
 active_file:234263 inactive_file:341759 isolated_file:0
 unevictable:9 dirty:21221 writeback:96084 unstable:129
 free:40765 slab_reclaimable:89393 slab_unreclaimable:19850
 mapped:29109 shmem:65088 pagetables:21560 bounce:0
Node 0 DMA free:15908kB min:128kB low:160kB high:192kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15684kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 2960 7947 7947
Node 0 DMA32 free:94360kB min:25128kB low:31408kB high:37692kB active_anon:1122272kB inactive_anon:301128kB active_file:479144kB inactive_file:802228kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3031688kB mlocked:0kB dirty:25936kB writeback:193704kB mapped:41696kB shmem:78944kB slab_reclaimable:174676kB slab_unreclaimable:19700kB kernel_stack:3056kB pagetables:11056kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no

Afer a few of these, I just got, a loop of 'failed to reallocate TX buffer'
Mem-Info:
Node 0 DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:  32
CPU    1: hi:  186, btch:  31 usd:  20
Node 0 Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 132
CPU    1: hi:  186, btch:  31 usd: 174
active_anon:1025929 inactive_anon:209027 isolated_anon:17
 active_file:235971 inactive_file:313547 isolated_file:6
 unevictable:9 dirty:86311 writeback:91894 unstable:4359
 free:70274 slab_reclaimable:88825 slab_unreclaimable:21955
 mapped:28146 shmem:66271 pagetables:21542 bounce:0
Node 0 DMA free:15908kB min:128kB low:160kB high:192kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15684kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 2960 7947 7947
Node 0 DMA32 free:212292kB min:25128kB low:31408kB high:37692kB active_anon:1110276kB inactive_anon: 304520kB active_file:479356kB inactive_file:691616kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3031688kB mlocked:0kB dirty:111500kB writeback:193764kB mapped:41348kB shmem:82336kB slab_reclaimable:173504kB slab_unreclaimable:23312kB kernel_stack:3056kB pagetables:11028kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 4986 4986
Node 0 Normal free:52896kB min:42324kB low:52904kB high:63484kB active_anon:2993440kB inactive_anon:531588kB active_file:464528kB inactive_file:562572kB unevictable:36kB isolated(anon):68kB isolated(file):24kB present:5106560kB mlocked:36kB dirty:233744kB writeback:173812kB mapped:71236kB shmem:182748kB slab_reclaimable:181796kB slab_unreclaimable:64508kB kernel_stack:3736kB pagetables:75140kB unstable:17436kB bounce:0kB writeback_tmp:0kB pages_scanned:98 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 1*4kB 0*8kB 0*16kB 1*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15908kB
Node 0 DMA32: 51901*4kB 1*8kB 0*16kB 1*32kB 1*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 212316kB
Node 0 Normal: 12200*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 52896kB
682814 total pagecache pages
67047 pages in swap cache
Swap cache stats: add 802793, delete 735746, find 537857/581722
Free swap  = 2660592kB
Total swap = 4106248kB
2080752 pages RAM
57174 pages reserved
842957 pages shared
1472720 pages non-shared
ieee80211 phy0: failed to reallocate TX buffer
ieee80211 phy0: failed to reallocate TX buffer
ieee80211 phy0: failed to reallocate TX buffer
ieee80211 phy0: failed to reallocate TX buffer
ieee80211 phy0: failed to reallocate TX buffer
ieee80211 phy0: failed to reallocate TX buffer
ieee80211 phy0: failed to reallocate TX buffer
ieee80211 phy0: failed to reallocate TX buffer
ieee80211 phy0: failed to reallocate TX buffer

-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
