From: =?UTF-8?B?TmlraGlsIFNldGhpICjgpKjgpL/gpJbgpL/gpLIg4KS44KWH4KSg4KWAKQ==?=
	<nikhil@sethi.ws>
Subject: Re: [2.6.35-rc1] page alloc failure order:1, mode:0x4020
Date: Mon, 8 Nov 2010 08:25:40 -0800
Message-ID: <AANLkTi=F+KLSgyy=OG_504HUXnyburGAad25qy1BwLvE@mail.gmail.com>
References: <20100604092025.GA96690@trillian.comsick.at> <1275656014.2482.169.camel@edumazet-laptop>
 <20100604161644.GA98048@trillian.local> <20100606095640.GA4436@trillian.comsick.at>
 <1275820945.5238.987.camel@edumazet-laptop> <AANLkTimf5iZV2ytoymCXJ=B2Vgowr6qb6u2nBg+RtBUg@mail.gmail.com>
 <1282769089.2681.159.camel@edumazet-laptop> <AANLkTi=TU8d8tsp28qN-Rz9z0hTcH7hRE=d8W4GKhrkk@mail.gmail.com>
 <AANLkTi=jLwvU=EWR51Y=TQ5JYVp_DqeTx0Ocbt=NEC1-@mail.gmail.com> <1283718304.3402.370.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Guntsche <mike@it-loops.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37859 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753942Ab0KHQ0Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 11:26:24 -0500
In-Reply-To: <1283718304.3402.370.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Eric, for all the help.
I get very=C2=A0occasional=C2=A0errors with vanilla 2.6.36 kernel with =
your
patch. Error messages are slightly different, and very rare compared
to without your patch. 2.6.35.7 seems fine, and does not show this
error.

rsync: page allocation failure. order:1, mode:0x4020
Pid: 31479, comm: rsync Not tainted 2.6.36-rc1 #1
Call Trace:
=C2=A0[<c0246b2c>] ? __alloc_pages_nodemask+0x3f1/0x52e
=C2=A0[<c0261330>] ? __slab_alloc+0x40f/0x45a
=C2=A0[<c02617ca>] ? __kmalloc_track_caller+0x91/0x97
=C2=A0[<d09db01a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
=C2=A0[<d09db01a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
=C2=A0[<c033a8d0>] ? __alloc_skb+0x57/0x100
=C2=A0[<d09db01a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
=C2=A0[<d0b01f2e>] ? ath_rx_tasklet+0x680/0xcfe [ath9k]
=C2=A0[<c02234ae>] ? __queue_work+0xe4/0x1a2
=C2=A0[<d0b00244>] ? ath9k_tasklet+0xd0/0x134 [ath9k]
=C2=A0[<c0219a43>] ? tasklet_action+0x5f/0x65
=C2=A0[<c0219cf4>] ? __do_softirq+0x60/0xc6
=C2=A0[<c0219d88>] ? do_softirq+0x2e/0x30
=C2=A0[<c0219e7b>] ? irq_exit+0x54/0x56
=C2=A0[<c02038e0>] ? do_IRQ+0x3a/0x72
=C2=A0[<c0202bc9>] ? common_interrupt+0x29/0x30
=C2=A0[<c02d89a0>] ? cfq_may_queue+0x0/0x92
=C2=A0[<c02d1567>] ? get_request+0x121/0x23e
=C2=A0[<c02d16a4>] ? get_request_wait+0x20/0xfd
=C2=A0[<c02d8f16>] ? cfq_merge+0x0/0x69
=C2=A0[<c02cfd40>] ? elv_merge+0x14b/0x170
=C2=A0[<c02d2375>] ? __make_request+0x71/0x364
=C2=A0[<c02d1fe2>] ? generic_make_request+0x14f/0x318
=C2=A0[<c0243fb1>] ? mempool_alloc+0x35/0xb9
=C2=A0[<c02d21e9>] ? submit_bio+0x3e/0x90
=C2=A0[<c0281c14>] ? bio_alloc_bioset+0x33/0x9e
=C2=A0[<c027e780>] ? submit_bh+0xbc/0xec
=C2=A0[<c027f4e2>] ? ll_rw_block+0x72/0x74
=C2=A0[<c027f504>] ? __breadahead+0x20/0x30
=C2=A0[<c02a3a8f>] ? __ext4_get_inode_loc+0x308/0x416
=C2=A0[<c02a8154>] ? ext4_iget+0x52/0x652
=C2=A0[<c02aa327>] ? ext4_lookup+0x65/0xbf
=C2=A0[<c026a6bb>] ? d_alloc_and_lookup+0x30/0x58
=C2=A0[<c026b84a>] ? do_lookup+0xc5/0xfe
=C2=A0[<c026c239>] ? link_path_walk+0x4d1/0x8d6
=C2=A0[<c026c722>] ? path_walk+0x48/0xa9
=C2=A0[<c026c7be>] ? do_path_lookup+0x3b/0x3f
=C2=A0[<c026d06d>] ? user_path_at+0x30/0x64
=C2=A0[<c0266446>] ? cp_new_stat64+0xee/0x100
=C2=A0[<c026664a>] ? vfs_fstatat+0x25/0x63
=C2=A0[<c02666c9>] ? vfs_lstat+0x13/0x15
=C2=A0[<c02666da>] ? sys_lstat64+0xf/0x23
=C2=A0[<c02141ed>] ? switched_to_idle+0x1a/0x43
=C2=A0[<c0393395>] ? syscall_call+0x7/0xb
=C2=A0[<c0390000>] ? quirk_ich7_lpc+0x46/0x4d
Mem-Info:
DMA per-cpu:
CPU =C2=A0 =C2=A00: hi: =C2=A0 =C2=A00, btch: =C2=A0 1 usd: =C2=A0 0
Normal per-cpu:
CPU =C2=A0 =C2=A00: hi: =C2=A0 90, btch: =C2=A015 usd: =C2=A084
active_anon:14957 inactive_anon:15137 isolated_anon:0
=C2=A0active_file:11820 inactive_file:11640 isolated_file:0
=C2=A0unevictable:470 dirty:1378 writeback:0 unstable:0
=C2=A0free:975 slab_reclaimable:5606 slab_unreclaimable:2343
=C2=A0mapped:2786 shmem:72 pagetables:394 bounce:0
DMA free:1000kB min:124kB low:152kB high:184kB active_anon:2896kB
inactive_anon:3552kB active_file:2116kB inactive_file:1768kB
unevictable:348kB isolated(anon):0kB isolated(file):0kB
present:15864kB mlocked:348kB dirty:16kB writeback:0kB mapped:228kB
shmem:32kB slab_reclaimable:1136kB slab_unreclaimable:608kB
kernel_stack:144kB pagetables:52kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:32 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:2900kB min:1908kB low:2384kB high:2860kB
active_anon:56932kB inactive_anon:56996kB active_file:45164kB
inactive_file:44792kB unevictable:1532kB isolated(anon):0kB
isolated(file):0kB present:243840kB mlocked:1532kB dirty:5496kB
writeback:0kB mapped:10916kB shmem:256kB slab_reclaimable:21288kB
slab_unreclaimable:8764kB kernel_stack:1056kB pagetables:1524kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 6*4kB 14*8kB 16*16kB 1*32kB 1*64kB 0*128kB 0*256kB 1*512kB
0*1024kB 0*2048kB 0*4096kB =3D 1000kB
Normal: 691*4kB 17*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB
0*1024kB 0*2048kB 0*4096kB =3D 2900kB
28310 total pagecache pages
4385 pages in swap cache
Swap cache stats: add 144387, delete 140002, find 98398/115667
=46ree swap =C2=A0=3D 889116kB
Total swap =3D 1023996kB
65535 pages RAM
1245 pages reserved
27369 pages shared
42219 pages non-shared
SLUB: Unable to allocate memory on node -1 (gfp=3D0x20)
=C2=A0=C2=A0cache: kmalloc-8192, object size: 8192, buffer size: 8192, =
default
order: 3, min order: 1
=C2=A0=C2=A0node 0: slabs: 133, objs: 529, free: 0
skbuff alloc of size 3872 failed
rsync: page allocation failure. order:1, mode:0x4020
Pid: 31479, comm: rsync Not tainted 2.6.36-rc1 #1
Call Trace:
=C2=A0[<c0246b2c>] ? __alloc_pages_nodemask+0x3f1/0x52e
=C2=A0[<c0261330>] ? __slab_alloc+0x40f/0x45a
=C2=A0[<c02617ca>] ? __kmalloc_track_caller+0x91/0x97
=C2=A0[<d09db01a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
=C2=A0[<d09db01a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
=C2=A0[<c033a8d0>] ? __alloc_skb+0x57/0x100
=C2=A0[<d09db01a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
=C2=A0[<d0b01f2e>] ? ath_rx_tasklet+0x680/0xcfe [ath9k]
=C2=A0[<c02234ae>] ? __queue_work+0xe4/0x1a2
=C2=A0[<d0b00244>] ? ath9k_tasklet+0xd0/0x134 [ath9k]
=C2=A0[<c0219a43>] ? tasklet_action+0x5f/0x65
=C2=A0[<c0219cf4>] ? __do_softirq+0x60/0xc6
=C2=A0[<c0219d88>] ? do_softirq+0x2e/0x30
=C2=A0[<c0219e7b>] ? irq_exit+0x54/0x56
=C2=A0[<c02038e0>] ? do_IRQ+0x3a/0x72
=C2=A0[<c0202bc9>] ? common_interrupt+0x29/0x30
=C2=A0[<c02d89a0>] ? cfq_may_queue+0x0/0x92
=C2=A0[<c02d1567>] ? get_request+0x121/0x23e
=C2=A0[<c02d16a4>] ? get_request_wait+0x20/0xfd
=C2=A0[<c02d8f16>] ? cfq_merge+0x0/0x69
=C2=A0[<c02cfd40>] ? elv_merge+0x14b/0x170
=C2=A0[<c02d2375>] ? __make_request+0x71/0x364
=C2=A0[<c02d1fe2>] ? generic_make_request+0x14f/0x318
=C2=A0[<c0243fb1>] ? mempool_alloc+0x35/0xb9
=C2=A0[<c02d21e9>] ? submit_bio+0x3e/0x90
=C2=A0[<c0281c14>] ? bio_alloc_bioset+0x33/0x9e
=C2=A0[<c027e780>] ? submit_bh+0xbc/0xec
=C2=A0[<c027f4e2>] ? ll_rw_block+0x72/0x74
=C2=A0[<c027f504>] ? __breadahead+0x20/0x30
=C2=A0[<c02a3a8f>] ? __ext4_get_inode_loc+0x308/0x416
=C2=A0[<c02a8154>] ? ext4_iget+0x52/0x652
=C2=A0[<c02aa327>] ? ext4_lookup+0x65/0xbf
=C2=A0[<c026a6bb>] ? d_alloc_and_lookup+0x30/0x58
=C2=A0[<c026b84a>] ? do_lookup+0xc5/0xfe
=C2=A0[<c026c239>] ? link_path_walk+0x4d1/0x8d6
=C2=A0[<c026c722>] ? path_walk+0x48/0xa9
=C2=A0[<c026c7be>] ? do_path_lookup+0x3b/0x3f
=C2=A0[<c026d06d>] ? user_path_at+0x30/0x64
=C2=A0[<c0266446>] ? cp_new_stat64+0xee/0x100
=C2=A0[<c026664a>] ? vfs_fstatat+0x25/0x63
=C2=A0[<c02666c9>] ? vfs_lstat+0x13/0x15
=C2=A0[<c02666da>] ? sys_lstat64+0xf/0x23
=C2=A0[<c02141ed>] ? switched_to_idle+0x1a/0x43
=C2=A0[<c0393395>] ? syscall_call+0x7/0xb
=C2=A0[<c0390000>] ? quirk_ich7_lpc+0x46/0x4d
Mem-Info:
DMA per-cpu:
CPU =C2=A0 =C2=A00: hi: =C2=A0 =C2=A00, btch: =C2=A0 1 usd: =C2=A0 0
Normal per-cpu:
CPU =C2=A0 =C2=A00: hi: =C2=A0 90, btch: =C2=A015 usd: =C2=A084
active_anon:14957 inactive_anon:15137 isolated_anon:0
=C2=A0active_file:11820 inactive_file:11640 isolated_file:0
=C2=A0unevictable:470 dirty:1378 writeback:0 unstable:0
=C2=A0free:975 slab_reclaimable:5606 slab_unreclaimable:2343
=C2=A0mapped:2786 shmem:72 pagetables:394 bounce:0
DMA free:1000kB min:124kB low:152kB high:184kB active_anon:2896kB
inactive_anon:3552kB active_file:2116kB inactive_file:1768kB
unevictable:348kB isolated(anon):0kB isolated(file):0kB
present:15864kB mlocked:348kB dirty:16kB writeback:0kB mapped:228kB
shmem:32kB slab_reclaimable:1136kB slab_unreclaimable:608kB
kernel_stack:144kB pagetables:52kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:32 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:2900kB min:1908kB low:2384kB high:2860kB
active_anon:56932kB inactive_anon:56996kB active_file:45164kB
inactive_file:44792kB unevictable:1532kB isolated(anon):0kB
isolated(file):0kB present:243840kB mlocked:1532kB dirty:5496kB
writeback:0kB mapped:10916kB shmem:256kB slab_reclaimable:21288kB
slab_unreclaimable:8764kB kernel_stack:1056kB pagetables:1524kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 6*4kB 14*8kB 16*16kB 1*32kB 1*64kB 0*128kB 0*256kB 1*512kB
0*1024kB 0*2048kB 0*4096kB =3D 1000kB
Normal: 691*4kB 17*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB
0*1024kB 0*2048kB 0*4096kB =3D 2900kB
28310 total pagecache pages
4385 pages in swap cache
Swap cache stats: add 144387, delete 140002, find 98398/115667
=46ree swap =C2=A0=3D 889116kB
Total swap =3D 1023996kB
65535 pages RAM
1245 pages reserved
27369 pages shared
42219 pages non-shared
SLUB: Unable to allocate memory on node -1 (gfp=3D0x20)
=C2=A0=C2=A0cache: kmalloc-8192, object size: 8192, buffer size: 8192, =
default
order: 3, min order: 1
=C2=A0=C2=A0node 0: slabs: 133, objs: 529, free: 0
skbuff alloc of size 3872 failed

2010/9/5 Eric Dumazet <eric.dumazet@gmail.com>
>
> Le dimanche 05 septembre 2010 =C3=A0 08:51 -0700, Nikhil Sethi (=E0=A4=
=A8=E0=A4=BF=E0=A4=96=E0=A4=BF=E0=A4=B2 =E0=A4=B8=E0=A5=87=E0=A4=A0=E0=A5=
=80) a
> =C3=A9crit :
> > This came back. Here is the dmesg output. It might be the problem o=
nly
> > happens if I have wmm_enabled=3D1 in my hostapd.conf. That is the o=
nly
> > thing that I changed yesterday, and today I saw these messages in m=
y
> > logs. I will try to conform this.
> >
> >
> > I am running 2.6.35.4 with this patch:
> >
> >
> > *** 225,234 ****
> > =C2=A0 =C2=A0int error =3D 0, i;
> > =C2=A0 =C2=A0u32 size;
> >
> > !
> > ! common->rx_bufsize =3D roundup(IEEE80211_MAX_MPDU_LEN +
> > ! =C2=A0 =C2=A0 ah->caps.rx_status_len,
> > ! =C2=A0 =C2=A0 min(common->cachelsz, (u16)64));
> >
> > =C2=A0 =C2=A0ath9k_hw_set_rx_bufsize(ah, common->rx_bufsize -
> > =C2=A0 =C2=A0 =C2=A0 ah->caps.rx_status_len);
> > --- 225,234 ----
> > =C2=A0 =C2=A0int error =3D 0, i;
> > =C2=A0 =C2=A0u32 size;
> >
> > ! size =3D roundup(IEEE80211_MAX_MPDU_LEN + ah->caps.rx_status_len,
> > ! =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0min(common->cachelsz, (u16)64));
> > ! =C2=A0 =C2=A0 =C2=A0 =C2=A0 common->rx_bufsize =3D min_t(u32, siz=
e,
> > ! =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0SKB_MAX_ORDE=
R(NET_SKB_PAD +
> > common->cachelsz, 0));
> >
> > =C2=A0 =C2=A0ath9k_hw_set_rx_bufsize(ah, common->rx_bufsize -
> > =C2=A0 =C2=A0 =C2=A0 ah->caps.rx_status_len);
> >
> >
> > dmesg output:
> >
> >
> > skbuff alloc of size 3872 failed
> > ps: page allocation failure. order:1, mode:0x4020
> > Pid: 16022, comm: ps Tainted: G =C2=A0 =C2=A0 =C2=A0 =C2=A0W =C2=A0=
 2.6.35.4 #1
> > Call Trace:
> > =C2=A0[<c0243bfe>] ? __alloc_pages_nodemask+0x3e6/0x513
> > =C2=A0[<c025be97>] ? slob_new_pages+0xc/0x23
>
> Unfortunately you use SLOB, and it seems to ask order-1 pages, while
> we want less than a page.
>
> Please try SLAB or SLUB
>
> > =C2=A0[<c025c0a1>] ? __kmalloc_node+0x39/0x72
> > =C2=A0[<c03338d8>] ? __alloc_skb+0x5c/0x105
> > =C2=A0[<d09fa01a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
> > =C2=A0[<d0ab7109>] ? ath_rx_tasklet+0x2fb/0x808 [ath9k]
> > =C2=A0[<c030fd49>] ? scsi_next_command+0x27/0x34
> > =C2=A0[<d0ab53c5>] ? ath9k_tasklet+0xcc/0x107 [ath9k]
> > =C2=A0[<c02193c3>] ? tasklet_action+0x5f/0x65
> > =C2=A0[<c0219677>] ? __do_softirq+0x60/0xc6
> > =C2=A0[<c021970b>] ? do_softirq+0x2e/0x30
> > =C2=A0[<c02197fd>] ? irq_exit+0x53/0x55
> > =C2=A0[<c020392c>] ? do_IRQ+0x3a/0x72
> > =C2=A0[<c0202be9>] ? common_interrupt+0x29/0x30
> > =C2=A0[<c0247874>] ? __remove_mapping+0x4b/0x8d
> > =C2=A0[<c023ea9f>] ? try_to_release_page+0x20/0x30
> > =C2=A0[<c0247d36>] ? shrink_page_list+0x2b8/0x46c
> > =C2=A0[<c03158ea>] ? sd_prep_fn+0x1a5/0x92b
> > =C2=A0[<c024816b>] ? shrink_inactive_list+0x281/0x552
> > =C2=A0[<c02445d9>] ? determine_dirtyable_memory+0xc/0x12
> > =C2=A0[<c024462c>] ? get_dirty_limits+0x18/0x2b0
> > =C2=A0[<c032875e>] ? ata_bmdma_port_intr+0x21/0xcd
> > =C2=A0[<c0248683>] ? shrink_zone+0x247/0x38f
> > =C2=A0[<c021968c>] ? __do_softirq+0x75/0xc6
> > =C2=A0[<c0247114>] ? shrink_slab+0x13c/0x186
> > =C2=A0[<c0248f25>] ? try_to_free_pages+0x1ab/0x2be
> > =C2=A0[<c0248f25>] ? try_to_free_pages+0x1ab/0x2be
> > =C2=A0[<c0243acf>] ? __alloc_pages_nodemask+0x2b7/0x513
> > =C2=A0[<c025be97>] ? slob_new_pages+0xc/0x23
> > =C2=A0[<c025c038>] ? kmem_cache_alloc_node+0x23/0x53
> > =C2=A0[<c0264b20>] ? getname+0x19/0xae
> > =C2=A0[<c0266d00>] ? user_path_at+0x11/0x64
> > =C2=A0[<c0250949>] ? access_process_vm+0xe0/0x1e7
> > =C2=A0[<c0250a08>] ? access_process_vm+0x19f/0x1e7
> > =C2=A0[<c02603d2>] ? vfs_fstatat+0x25/0x63
> > =C2=A0[<c02604a9>] ? vfs_stat+0x10/0x12
> > =C2=A0[<c02604ba>] ? sys_stat64+0xf/0x23
> > =C2=A0[<c025e86b>] ? fput+0x88/0x191
> > =C2=A0[<c026ab3b>] ? dput+0x92/0xd4
> > =C2=A0[<c025e8ff>] ? fput+0x11c/0x191
> > =C2=A0[<c026ebec>] ? mntput_no_expire+0x13/0x60
> > =C2=A0[<c025c398>] ? filp_close+0x3b/0x54
> > =C2=A0[<c025c403>] ? sys_close+0x52/0x72
> > =C2=A0[<c038ad3d>] ? syscall_call+0x7/0xb
> > =C2=A0[<c0380000>] ? unix_dgram_sendmsg+0x258/0x3c1
> > Mem-Info:
>
>
>
