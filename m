From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance tests
Date: Mon, 16 Jun 2003 15:37:14 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030616223714.GB18484@netnation.com>
References: <20030610075732.GD23009@netnation.com> <20030612.232002.41633789.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ralph+d@istop.com, hadi@shell.cyberus.ca, xerox@foonet.net,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030612.232002.41633789.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Thu, Jun 12, 2003 at 11:20:02PM -0700, David S. Miller wrote:

>    In any case, setting gc_min_interval to 0 definitely helped, but I
>    suspect Dave's patches will make a bigger difference.  Next up is
>    2.5.70-bk14 and 2.5.70-bk14+davem's stuff from yesterday.
> 
> Did you get stuck in some mud? :-)  It's been two days.
> 
> I even posted new patches for you to test, get on it :)))

Ok, I dug myself out. :)

I have oprofile working, and I wrote a simple application to measure
received pps on the receiving box with gettimeofday() accuracy.  To
reduce noise I am profiling for one minute periods.  The sender is
capable of sending about 315,000 pps via an e1000.

So, which kernels shall I try?  When I set the thing up I was using
2.5.70-bk14, but I am compiling 2.4.71, and I will try with your patch
above and with Alexey's.

Stock 2.4.21-rc7 (CONFIG_IP_MULTIPLE_TABLES=y):

60.0047 seconds passed, avg forwarding rate: 122169.980 pps
60.0052 seconds passed, avg forwarding rate: 123650.166 pps
60.0045 seconds passed, avg forwarding rate: 122352.499 pps
60.0059 seconds passed, avg forwarding rate: 121830.346 pps
60.0046 seconds passed, avg forwarding rate: 121714.614 pps
60.0057 seconds passed, avg forwarding rate: 121927.324 pps
60.0061 seconds passed, avg forwarding rate: 121995.740 pps
60.0064 seconds passed, avg forwarding rate: 122168.417 pps
60.0030 seconds passed, avg forwarding rate: 123245.149 pps
60.0062 seconds passed, avg forwarding rate: 122613.361 pps

(CPU type is still Opteron, oprofile is wrong. :))
Cpu type: Hammer
Cpu speed was (MHz estimation) : 1393.98
Counter 0 counted RETIRED_INSNS events (Retired instructions (includes exceptions, interrupts, resyncs)) with a unit mask of 0x00 (No unit mask) count 697000
vma      samples  %           symbol name
c0278b00 4537     12.6063     fn_hash_lookup
c027a1d0 3293     9.14976     fib_lookup
c024aa70 2989     8.30508     rt_intern_hash
c024c7d0 2195     6.09892     ip_route_input
c024c000 2020     5.61267     ip_route_input_slow
c024ed20 1244     3.45652     ip_rcv
c0247650 1234     3.42873     eth_header
c0276490 1226     3.4065      fib_validate_source
c024a710 1173     3.25924     rt_garbage_collect
c0132ee0 930      2.58405     kmalloc
c0242f60 924      2.56738     neigh_lookup
c02502a0 915      2.54237     ip_forward
c0132da0 875      2.43123     kmem_cache_alloc
c02444e0 735      2.04223     neigh_resolve_output
c0249f70 734      2.03946     rt_hash_code
c0133070 717      1.99222     kmem_cache_free
c024bcd0 666      1.85051     rt_set_nexthop
c023bfe0 632      1.75604     __kfree_skb
c02778e0 620      1.7227      fib_semantic_match
c023bce0 611      1.69769     alloc_skb
c0247f30 529      1.46985     pfifo_fast_dequeue
c0247830 524      1.45596     eth_type_trans
c02404b0 521      1.44762     netif_receive_skb
c0132cb0 520      1.44485     free_block
c0247a80 487      1.35315     qdisc_restart
c01330f0 466      1.2948      kfree
c02426e0 456      1.26702     dst_alloc
c023fd60 454      1.26146     dev_queue_xmit
c0132bd0 401      1.1142      kmem_cache_alloc_batch
c0272740 370      1.02806     inet_select_addr
c0252e80 353      0.980828    ip_finish_output
c0244350 325      0.903029    neigh_hh_init
c0242840 321      0.891914    dst_destroy
c010d5c0 315      0.875243    do_gettimeofday
c0247ec0 276      0.76688     pfifo_fast_enqueue
c024baa0 245      0.680745    ipv4_dst_destroy
c023bf70 216      0.600167    kfree_skbmem
c0120160 210      0.583495    cpu_raise_softirq
c026f1e0 156      0.433454    arp_bind_neighbour
c0277990 136      0.377883    __fib_res_prefsrc
c027a020 126      0.350097    fib_rules_policy
c0279d60 96       0.266741    fib_rule_put
c0240370 68       0.188941    net_tx_action
c026ec10 37       0.102806    arp_hash
c023bf00 34       0.0944707   skb_release_data
c0240770 14       0.0388997   net_rx_action

 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf
118130        56  123028     0     0     0     0     0         0       0      0  123028  123024         0    0
109456        58  122426     0     0     0     0     0         0       0      0  122426  122422         0    0
113318        52  124832     0     0     0     0     0         0       0      0  124832  124828         0    0
104356        53  122131     0     0     0     0     0         0       0      0  122131  122127         0    0
98333        56  125064     0     0     0     0     0         0       0      0  125064  125060         0    0
125925        57  125899     0     0     0     0     0         0       0      0  125899  125896         0    0
117516        44  122676     0     0     0     0     0         0       0      0  122676  122672         0    0
121088        48  124472     0     0     0     0     0         0       0      0  124472  124468         0    0
113049        43  123041     0     0     0     0     0         0       0      0  123041  123037         0    0
104339        43  122377     0     0     0     0     0         0       0      0  122377  122373         0    0
98324        46  125074     0     0     0     0     0         0       0      0  125074  125070         0    0
126818        40  126816     0     0     0     0     0         0       0      0  126816  126813         0    0
131018        54  124958     0     0     0     0     0         0       0      0  124958  124954         0    0
122303        51  122369     0     0     0     0     0         0       0      0  122369  122365         0    0
113661        46  122438     0     0     0     0     0         0       0      0  122438  122434         0    0
104350        49  121771     0     0     0     0     0         0       0      0  121771  121767         0    0
98330        58  125062     0     0     0     0     0         0       0      0  125062  125058         0    0
102841        36  124675     0     0     0     0     0         0       0      0  124675  124671         0    0
131031        49  126507     0     0     0     0     0         0       0      0  126507  126504         0    0


Stock 2.5.70-bk14 (CONFIG_IP_MULTIPLE_TABLES=y):

(There is some noise in forward pps rate because the route cache keeps
ballooning and collapsing all over the place.)

60.0042 seconds passed, avg forwarding rate: 102595.362 pps
60.0039 seconds passed, avg forwarding rate: 102690.418 pps
60.0043 seconds passed, avg forwarding rate: 102254.257 pps
60.0036 seconds passed, avg forwarding rate: 102708.344 pps
60.0052 seconds passed, avg forwarding rate: 102647.544 pps
60.0036 seconds passed, avg forwarding rate: 102697.595 pps
60.0042 seconds passed, avg forwarding rate: 102326.652 pps
60.0043 seconds passed, avg forwarding rate: 102615.183 pps
60.0081 seconds passed, avg forwarding rate: 101990.399 pps
60.0036 seconds passed, avg forwarding rate: 102220.386 pps

Cpu type: Athlon
Cpu speed was (MHz estimation) : 1394.27
Counter 0 counted RETIRED_INSNS events (Retired instructions (includes exceptions, interrupts, resyncs)) with a unit mask of 0x00 (No unit mask) count 697000
vma      samples  %           symbol name
c0290480 8213     15.6283     rt_garbage_collect
c011ee80 4979     9.47443     local_bh_enable
c02bf140 3616     6.8808      fn_hash_lookup
c02906d0 1977     3.76199     rt_intern_hash
c0291b10 1949     3.70871     ip_route_input_slow
c028d1d0 1647     3.13404     nf_iterate
c028d4c0 1575     2.99703     nf_hook_slow
c0220c10 1513     2.87905     tg3_start_xmit
c02c0a00 1470     2.79723     fib_lookup
c02923e0 1169     2.22446     ip_route_input
c0220010 895      1.70308     tg3_rx
c0134e20 877      1.66882     kmem_cache_free
c0134d60 863      1.64218     kmem_cache_alloc
c028e270 855      1.62696     pfifo_fast_dequeue
c0134bf0 855      1.62696     free_block
c02bcf30 837      1.59271     fib_validate_source
c0294450 833      1.5851      ip_rcv_finish
c0286b20 782      1.48805     netif_receive_skb
c028db70 765      1.4557      eth_header
c0293ee0 750      1.42716     ip_rcv
c0290190 727      1.38339     rt_may_expire
c028fda0 689      1.31108     rt_hash_code
c0295210 679      1.29205     ip_forward
c0134a30 648      1.23306     cache_alloc_refill
c0134da0 636      1.21023     kmalloc
c0298870 591      1.1246      ip_finish_output2
c0134e60 520      0.989496    kfree
c01ad3d0 504      0.95905     memcpy
c028a860 498      0.947633    neigh_resolve_output
c0282c90 477      0.907672    alloc_skb
c02c08e0 474      0.901964    fib_rules_policy
c02be300 474      0.901964    fib_semantic_match
c0289870 471      0.896255    neigh_lookup
c028dce0 466      0.886741    eth_type_trans
c0289160 445      0.84678     dst_alloc
c0295450 442      0.841072    ip_forward_finish
c02865e0 407      0.774471    dev_queue_xmit
c02b7950 383      0.728802    inet_select_addr
c0289290 344      0.65459     dst_destroy
c0296790 325      0.618435    ip_finish_output
c02b4140 320      0.608921    arp_hash
c021fc50 317      0.603212    tg3_tx
c02d0090 313      0.595601    ipv4_sabotage_out
c028e1f0 306      0.58228     pfifo_fast_enqueue
c021fec0 296      0.563252    tg3_recycle_rx
c028a6e0 294      0.559446    neigh_hh_init

 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf
 5402        29   82379     0     0     0     0     0         0       0      0   76979   76401       575  575
131075        29  125867     0     0     0     0     0         0       0      0  123076  122879       194  194
117660        26  118554     0     0     0     0     0         0       0      0  110363  109467       896  896
86134        22  100138     0     0     0     0     0         0       0      0   91947   91353       591  591
48682        28   94224     0     0     0     0     0         0       0      0   86033   85427       603  603
 3419        28   86216     0     0     0     0     0         0       0      0   82916   82390       523  523
131075        25  127871     0     0     0     0     0         0       0      0  122980  122879        98   98
116937        33  117383     0     0     0     0     0         0       0      0  109192  108744       448  448
83306        17   98079     0     0     0     0     0         0       0      0   89888   89248       637  637
43585        17   91951     0     0     0     0     0         0       0      0   83760   83158       599  599
  715        23   88681     0     0     0     0     0         0       0      0   88081   87487       591  591
104407        37  134703     0     0     0     0     0         0       0      0  127112  127111         0    0
67650        14   94902     0     0     0     0     0         0       0      0   86711   86122       587  587
23861        25   87875     0     0     0     0     0         0       0      0   79684   79090       591  591
  670        26  108386     0     0     0     0     0         0       0      0  107786  107211       572  572
131075        38  130550     0     0     0     0     0         0       0      0  122959  122879        77   77
99588        14  108546     0     0     0     0     0         0       0      0  100355   99586       768  768
61804        27   93912     0     0     0     0     0         0       0      0   85721   85095       624  624
14826        27   84721     0     0     0     0     0         0       0      0   76530   75901       626  626


2.4.71 (CONFIG_IP_MULTIPLE_TABLES=y) w/correction to make
flow_cache_init compile w/CONFIG_SMP=n (register_cpu_notifier):

60.0060 seconds passed, avg forwarding rate: 103857.780 pps
60.0036 seconds passed, avg forwarding rate: 104893.408 pps
60.0061 seconds passed, avg forwarding rate: 104623.946 pps
60.0040 seconds passed, avg forwarding rate: 104457.440 pps
60.0057 seconds passed, avg forwarding rate: 104505.375 pps
60.0042 seconds passed, avg forwarding rate: 103663.532 pps
60.0043 seconds passed, avg forwarding rate: 104240.425 pps
60.0042 seconds passed, avg forwarding rate: 104422.699 pps
60.0034 seconds passed, avg forwarding rate: 104252.729 pps
60.0058 seconds passed, avg forwarding rate: 104138.597 pps

Cpu type: Athlon
Cpu speed was (MHz estimation) : 1394.27 Counter 0 counted RETIRED_INSNS events (Retired instructions (includes exceptions, interrupts, resyncs)) with a unit mask of 0x00 (No unit mask)
count 697000
vma      samples  %           symbol name
c0292270 8941     16.2664     rt_garbage_collect
c011f080 5295     9.63323     local_bh_enable
c02c0fb0 3943     7.17353     fn_hash_lookup
c02924c0 2209     4.01885     rt_intern_hash
c0293900 2115     3.84783     ip_route_input_slow
c028ef90 1725     3.1383      nf_iterate
c028f280 1673     3.0437      nf_hook_slow
c02c2880 1536     2.79445     fib_lookup
c02941d0 1381     2.51246     ip_route_input
c0222330 1307     2.37783     tg3_start_xmit
c0296240 1000     1.81931     ip_rcv_finish
c0134ff0 961      1.74835     free_block
c0221710 918      1.67012     tg3_rx
c0290030 909      1.65375     pfifo_fast_dequeue
c0135230 861      1.56642     kmem_cache_free
c0295cd0 844      1.53549     ip_rcv
c02bed90 835      1.51912     fib_validate_source
c0135170 822      1.49547     kmem_cache_alloc
c028f930 818      1.48819     eth_header
c0291f80 741      1.34811     rt_may_expire
c02886a0 726      1.32082     netif_receive_skb
c0291b80 708      1.28807     rt_hash_code
c0134e20 684      1.24441     cache_alloc_refill
c01351b0 644      1.17163     __kmalloc
c028b610 595      1.08249     neigh_lookup
c028c600 542      0.986064    neigh_resolve_output
c0284620 538      0.978787    alloc_skb
c029a680 534      0.97151     ip_finish_output2
c0135270 510      0.927846    kfree
c01adc80 484      0.880544    memcpy
c028af00 468      0.851435    dst_alloc
c02c0160 438      0.796856    fib_semantic_match
c028faa0 434      0.789579    eth_type_trans
c0297020 419      0.762289    ip_forward
c0288160 418      0.76047     dev_queue_xmit
c02c2760 398      0.724084    fib_rules_policy
c0297260 394      0.716807    ip_forward_finish
c02b9790 391      0.711349    inet_select_addr
c0221e90 374      0.680421    tg3_set_txd
c028ffb0 348      0.633119    pfifo_fast_enqueue
c028fcc0 339      0.616745    qdisc_restart
c028b030 326      0.593094    dst_destroy
c02d1fb0 301      0.547611    ipv4_sabotage_out
c02985a0 299      0.543973    ip_finish_output
c0128a00 293      0.533057    call_rcu
c0221350 284      0.516683    tg3_tx

 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf
26127        24   92112     0     0     0     0     0         0       0      0   83920   83318       599  599
  722        32  106131     0     0     0     0     0         0       0      0  105531  104945       583  583
131075        23  130793     0     0     0     0     0         0       0      0  123201  122879       319  319
131074        27  131449     0     0     0     0     0         0       0      0  123257  122878       376  376
120198        23  120965     0     0     0     0     0         0       0      0  112773  112005       768  768
93359        26  104746     0     0     0     0     0         0       0      0   96554   96040       511  511
59620        17   97943     0     0     0     0     0         0       0      0   89751   89140       608  608
18593        20   90640     0     0     0     0     0         0       0      0   82448   81851       593  593
   70        23  113117     0     0     0     0     0         0       0      0  113117  112479       636  636
131075        22  131306     0     0     0     0     0         0       0      0  123114  122879       232  232
110767        18  111534     0     0     0     0     0         0       0      0  103342  102574       768  768
79859        20  100776     0     0     0     0     0         0       0      0   92584   91971       610  610
43481        24   95328     0     0     0     0     0         0       0      0   87136   86500       632  632
  704        34   88794     0     0     0     0     0         0       0      0   88194   87591       601  601
131075        36  130692     0     0     0     0     0         0       0      0  123100  122879       218  218
110844        25  111611     0     0     0     0     0         0       0      0  103419  102651       768  768
80008        18  100862     0     0     0     0     0         0       0      0   92670   92043       624  624
43390        24   95064     0     0     0     0     0         0       0      0   86872   86260       608  608
  720        31   88869     0     0     0     0     0         0       0      0   88269   87682       585  585


2.4.71 (CONFIG_IP_MULTIPLE_TABLES=n)

60.0039 seconds passed, avg forwarding rate: 108482.881 pps
60.0036 seconds passed, avg forwarding rate: 107850.012 pps
60.0043 seconds passed, avg forwarding rate: 108330.941 pps
60.0063 seconds passed, avg forwarding rate: 108424.657 pps
60.0071 seconds passed, avg forwarding rate: 108575.916 pps
60.0040 seconds passed, avg forwarding rate: 107774.861 pps
60.0053 seconds passed, avg forwarding rate: 107765.720 pps
60.0065 seconds passed, avg forwarding rate: 108021.888 pps
60.0039 seconds passed, avg forwarding rate: 107364.055 pps
60.0061 seconds passed, avg forwarding rate: 107593.173 pps

Cpu type: Athlon
Cpu speed was (MHz estimation) : 1394.27
Counter 0 counted RETIRED_INSNS events (Retired instructions (includes exceptions, interrupts, resyncs)) with a unit mask of 0x00 (No unit mask) count 697000
vma      samples  %           symbol name
c0292260 7149     13.2856     rt_garbage_collect
c011f080 6875     12.7764     local_bh_enable
c02c0df0 3440     6.39286     fn_hash_lookup
c02924b0 2180     4.05129     rt_intern_hash
c02938c0 2158     4.01041     ip_route_input_slow
c028ef90 1769     3.28749     nf_iterate
c0222330 1644     3.05519     tg3_start_xmit
c028f280 1601     2.97528     nf_hook_slow
c02940f0 1209     2.24679     ip_route_input
c02bec10 1187     2.20591     fib_validate_source
c0135230 987      1.83423     kmem_cache_free
c0134ff0 950      1.76547     free_block
c0135170 924      1.71715     kmem_cache_alloc
c0295c00 918      1.706       ip_rcv
c0221710 908      1.68742     tg3_rx
c0290020 907      1.68556     pfifo_fast_dequeue
c0296170 897      1.66698     ip_rcv_finish
c028f920 808      1.50158     eth_header
c0291b70 804      1.49415     rt_hash_code
c02886a0 740      1.37521     netif_receive_skb
c0134e20 739      1.37335     cache_alloc_refill
c0291f70 736      1.36778     rt_may_expire
c0296f50 703      1.30645     ip_forward
c028b610 676      1.25627     neigh_lookup
c01351b0 669      1.24326     __kmalloc
c02bffa0 637      1.18379     fib_semantic_match
c029a5b0 635      1.18008     ip_finish_output2
c0135270 614      1.14105     kfree
c0284620 544      1.01096     alloc_skb
c028c600 515      0.957071    neigh_resolve_output
c01adc80 498      0.925479    memcpy
c028fa90 464      0.862293    eth_type_trans
c0288160 457      0.849285    dev_queue_xmit
c0297190 425      0.789816    ip_forward_finish
c028af00 420      0.780524    dst_alloc
c02b9680 411      0.763799    inet_select_addr
c028ffa0 350      0.650437    pfifo_fast_enqueue
c028b030 350      0.650437    dst_destroy
c02984d0 330      0.613269    ip_finish_output
c0221350 326      0.605835    tg3_tx
c0128a00 324      0.602119    call_rcu
c028fcb0 323      0.60026     qdisc_restart
c028c480 323      0.60026     neigh_hh_init
c02215c0 291      0.540792    tg3_recycle_rx
c02d0e80 258      0.479465    ipv4_sabotage_in
c02d0ec0 257      0.477606    ipv4_sabotage_out

 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf
103545        28  107316     0     0     0     0     0         0       0      0   99124   98495       626  626
76151        24  104300     0     0     0     0     0         0       0      0   96108   95485       620  620
10200        26   83194     0     0     0     0     0         0       0      0   75002   74396       603  603
  702        38  122078     0     0     0     0     0         0       0      0  121478  120872       603  603
131075        39  130952     0     0     0     0     0         0       0      0  123360  122879       478  478
126869        28  126996     0     0     0     0     0         0       0      0  118804  118676       128  128
85330        22  107046     0     0     0     0     0         0       0      0   98854   98259       591  591
50739        22   97102     0     0     0     0     0         0       0      0   88910   88288       620  620
10501        17   91459     0     0     0     0     0         0       0      0   83267   82641       623  623
  689        34  121790     0     0     0     0     0         0       0      0  121190  120571       616  616
131075        33  130963     0     0     0     0     0         0       0      0  123371  122879       489  489
110335        44  126916     0     0     0     0     0         0       0      0  118724  118659        64   64
81862        16  103228     0     0     0     0     0         0       0      0   95036   94406       628  628
50717        24  100536     0     0     0     0     0         0       0      0   92344   91734       607  607
12301        33   93251     0     0     0     0     0         0       0      0   85059   84463       593  593
  684        33  119995     0     0     0     0     0         0       0      0  119395  118771       621  621
131074        26  146318     0     0     0     0     0         0       0      0  138726  138610       113  113
114248        25  115015     0     0     0     0     0         0       0      0  106823  106055       768  768
88917        18  106318     0     0     0     0     0         0       0      0   98126   97548       575  575
57970        24  100752     0     0     0     0     0         0       0      0   92560   91932       625  625


2.5.71-davem-rtcache-jun9:

60.006 seconds passed, avg forwarding rate: 160182.941 pps
60.0077 seconds passed, avg forwarding rate: 159805.476 pps
60.007 seconds passed, avg forwarding rate: 160274.907 pps
60.0084 seconds passed, avg forwarding rate: 160212.101 pps
60.0045 seconds passed, avg forwarding rate: 159345.161 pps
60.0076 seconds passed, avg forwarding rate: 159552.768 pps
60.0046 seconds passed, avg forwarding rate: 159416.702 pps
60.0035 seconds passed, avg forwarding rate: 160435.829 pps
60.0043 seconds passed, avg forwarding rate: 160015.150 pps
60.0072 seconds passed, avg forwarding rate: 159309.661 pps

Cpu type: Athlon
Cpu speed was (MHz estimation) : 1394.27
Counter 0 counted RETIRED_INSNS events (Retired instructions (includes exceptions, interrupts, resyncs)) with a unit mask of 0x00 (No unit mask) count 697000
vma      samples  %           symbol name
c02c0fa0 4875     8.75586     fn_hash_lookup
c02939f0 3839     6.89513     ip_route_input_slow
c028f040 2507     4.50276     nf_iterate
c028f330 2450     4.40038     nf_hook_slow
c0222330 2377     4.26927     tg3_start_xmit
c02bedc0 1722     3.09284     fib_validate_source
c0134ff0 1478     2.6546      free_block
c0292560 1444     2.59353     rt_intern_hash
c0221710 1409     2.53067     tg3_rx
c0135230 1406     2.52528     kmem_cache_free
c0296320 1399     2.51271     ip_rcv_finish
c0294260 1281     2.30077     ip_route_input
c02886a0 1235     2.21815     netif_receive_skb
c028f9d0 1194     2.14451     eth_header
c028af00 1153     2.07087     dst_alloc
c0291c20 1120     2.0116      rt_hash_code
c0295db0 1111     1.99544     ip_rcv
c0135170 1109     1.99185     kmem_cache_alloc
c0134e20 1109     1.99185     cache_alloc_refill
c02900d0 1016     1.82481     pfifo_fast_dequeue
c028b6c0 1014     1.82122     neigh_lookup
c01351b0 1003     1.80146     __kmalloc
c02c0150 894      1.60569     fib_semantic_match
c01adc80 838      1.50511     memcpy
c029a760 837      1.50331     ip_finish_output2
c028c6b0 801      1.43866     neigh_resolve_output
c0288160 792      1.42249     dev_queue_xmit
c0135270 789      1.4171      kfree
c0284620 740      1.32909     alloc_skb
c011f080 661      1.1872      local_bh_enable
c028fb40 656      1.17822     eth_type_trans
c02b9830 648      1.16386     inet_select_addr
c0297340 601      1.07944     ip_forward_finish
c02929d0 591      1.06148     __rt_hash_shrink
c0290050 540      0.96988     pfifo_fast_enqueue
c028b0e0 532      0.955511    dst_destroy
c0298680 511      0.917794    ip_finish_output
c0128a00 501      0.899833    call_rcu
c0297100 479      0.860319    ip_forward
c02d1070 478      0.858523    ipv4_sabotage_out
c0221350 451      0.810029    tg3_tx
c028c530 431      0.774108    neigh_hh_init
c02215c0 426      0.765127    tg3_recycle_rx
c028fd60 394      0.707653    qdisc_restart
c02d1030 375      0.673528    ipv4_sabotage_in
c0292310 359      0.64479     rt_garbage_collect

 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf
21502         9  160507     0     0     0     0     0         0       0      0  160507  160507         0    0
23701        15  160485     0     0     0     0     0         0       0      0  160485  160484         1    0
21866         6  160498     0     0     0     0     0         0       0      0  160498  160498         0    0
23551        12  160464     0     0     0     0     0         0       0      0  160464  160464         0    0
23266        13  160203     0     0     0     0     0         0       0      0  160203  160203         0    0
22095         9  160591     0     0     0     0     0         0       0      0  160591  160591         0    0
23962        15  160461     0     0     0     0     0         0       0      0  160461  160460         0    0
22066        13  158691     0     0     0     0     0         0       0      0  158691  158691         0    0
22951        10  160166     0     0     0     0     0         0       0      0  160166  160166         0    0
21861        18  159134     0     0     0     0     0         0       0      0  159134  159134         0    0
21097         6  159126     0     0     0     0     0         0       0      0  159126  159125         1    0
22943         6  161350     0     0     0     0     0         0       0      0  161350  161350         0    0
21692         4  160124     0     0     0     0     0         0       0      0  160124  160124         0    0
23524        16  161184     0     0     0     0     0         0       0      0  161184  161184         0    0
20471        15  160833     0     0     0     0     0         0       0      0  160833  160833         0    0
23160         5  161643     0     0     0     0     0         0       0      0  161643  161642         0    0
21981        10  160518     0     0     0     0     0         0       0      0  160518  160518         0    0
20640        11  160145     0     0     0     0     0         0       0      0  160145  160145         0    0
21536        14  160194     0     0     0     0     0         0       0      0  160194  160194         0    0
21110        10  161550     0     0     0     0     0         0       0      0  161550  161550         0    0

...What next? :)

Simon-
