From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance tests
Date: Tue, 17 Jun 2003 15:50:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617225036.GG25773@netnation.com>
References: <20030616.160856.35828947.davem@redhat.com> <20030616232750.GD18484@netnation.com> <20030616234937.GE18484@netnation.com> <20030617.085921.28790392.davem@redhat.com> <16111.18107.699689.704597@robur.slu.se> <20030617200721.GA25773@netnation.com> <20030617210700.GE25773@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, ralph+d@istop.com,
   hadi@shell.cyberus.ca, xerox@foonet.net, fw@deneb.enyo.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030617210700.GE25773@netnation.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 17, 2003 at 02:07:01PM -0700, Simon Kirby wrote:

> 60.0104 seconds passed, avg forwarding rate: 259027.200 pps
> 
> This is with standard juno (pseudo-random sources).
> 
> This is with CONFIG_IP_MULTIPLE_TABLES still on, too.

Here is with CONFIG_IP_MULTIPLE_TABLES=n and CONFIG_NETFILTER=n
(rp_filter off and CONFIG_SMP=n in all tests):

60.0050 seconds passed, avg forwarding rate: 276893.102 pps
60.0046 seconds passed, avg forwarding rate: 257257.533 pps
60.0101 seconds passed, avg forwarding rate: 251852.843 pps
60.0106 seconds passed, avg forwarding rate: 248110.756 pps
60.0045 seconds passed, avg forwarding rate: 246280.066 pps

"rtstat -i 1" shows the pps rate decreasing because of the growing
rtcache:

 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf
16688        18  294882     0     0     0     0     0         0       0      0  294882  294880         2    0
16834        24  302376     0     0     0     0     0         0       0      0  302376  302374         2    0
16970        12  294288     0     0     0     0     0         0       0      0  294288  294286         2    0
17037        21  294278     0     0     0     0     0         0       0      0  294278  294276         1    0
17133        20  293080     0     0     0     0     0         0       0      0  293080  293078         1    0
17195        22  293978     0     0     0     0     0         0       0      0  293978  293976         1    0
17293        16  292184     0     0     0     0     0         0       0      0  292184  292182         1    0
17370        19  293681     0     0     0     0     0         0       0      0  293681  293679         1    0
17450        21  293079     0     0     0     0     0         0       0      0  293079  293077         1    0
17542        12  293388     0     0     0     0     0         0       0      0  293388  293386         1    0
17604        16  293684     0     0     0     0     0         0       0      0  293684  293682         1    0
17676        27  294573     0     0     0     0     0         0       0      0  294573  294571         0    0
17762        18  291582     0     0     0     0     0         0       0      0  291582  291580         1    0
...
21615        17  257683     0     0     0     0     0         0       0      0  257683  257681         1    0
21641        23  257077     0     0     0     0     0         0       0      0  257077  257075         0    0
21672        23  257077     0     0     0     0     0         0       0      0  257077  257075         1    0

Profile:

vma      samples  %           symbol name
c025ee10 9228     15.1465     fn_hash_lookup
c02379a0 4025     6.60648     ip_route_input_slow
c0236650 3321     5.45096     rt_intern_hash
c0235d60 2775     4.55478     rt_hash_code
c012d750 2622     4.30365     kmem_cache_alloc
c012d950 2338     3.83751     kmem_cache_free
c0239f50 2323     3.81288     ip_rcv
c0238060 2277     3.73738     ip_route_input
c0233ac0 2190     3.59458     eth_header
c0231b50 2119     3.47805     neigh_resolve_output
c025ca50 2074     3.40419     fib_validate_source
c023aed0 1987     3.26139     ip_forward
c0230a70 1926     3.16126     neigh_lookup
c012d830 1845     3.02831     kmalloc
c0234270 1523     2.49979     pfifo_fast_dequeue
c025dde0 1407     2.3094      fib_semantic_match
c02376c0 1354     2.2224      rt_set_nexthop
c022a730 1322     2.16988     __kfree_skb
c022a480 1248     2.04842     alloc_skb
c012da00 1229     2.01723     kfree
c0259830 1171     1.92204     inet_select_addr
c0233ca0 1169     1.91875     eth_type_trans
c02304a0 994      1.63151     dst_destroy
c0230380 976      1.60197     dst_alloc
c010c910 806      1.32294     do_gettimeofday
c02319d0 793      1.3016      neigh_hh_init
c0236380 739      1.21297     rt_garbage_collect
c0233ef0 732      1.20148     qdisc_restart
c0234200 731      1.19984     pfifo_fast_enqueue
c022e590 695      1.14075     netif_receive_skb
c022dff0 623      1.02257     dev_queue_xmit
c023d6e0 575      0.943783    ip_finish_output
c02562a0 293      0.480919    arp_hash

Full route table:

60.0054 seconds passed, avg forwarding rate: 141888.209 pps

vma      samples  %           symbol name
c025ee10 21133    42.5588     fn_hash_lookup
c02379a0 2219     4.46874     ip_route_input_slow
c0236650 1600     3.22217     rt_intern_hash
c0235d60 1471     2.96238     rt_hash_code
c012d750 1282     2.58176     kmem_cache_alloc
c012d950 1279     2.57572     kmem_cache_free
c0259830 1253     2.52336     inet_select_addr
c0239f50 1231     2.47906     ip_rcv
c0233ac0 1214     2.44482     eth_header
c025dde0 1165     2.34614     fib_semantic_match
c0231b50 1133     2.2817      neigh_resolve_output
c0238060 1126     2.2676      ip_route_input
c025ca50 1120     2.25552     fib_validate_source
c0230a70 1041     2.09642     neigh_lookup
c023aed0 1032     2.0783      ip_forward
c012d830 1002     2.01788     kmalloc
c02376c0 762      1.53456     rt_set_nexthop
c0234270 733      1.47616     pfifo_fast_dequeue
c022a730 709      1.42782     __kfree_skb
c022a480 633      1.27477     alloc_skb
c012da00 629      1.26671     kfree
c0233ca0 623      1.25463     eth_type_trans
c02304a0 549      1.10561     dst_destroy
c0230380 519      1.04519     dst_alloc
c02319d0 447      0.900193    neigh_hh_init
c0236380 426      0.857902    rt_garbage_collect
c010c910 425      0.855889    do_gettimeofday
c022e590 395      0.795473    netif_receive_skb
c0234200 392      0.789431    pfifo_fast_enqueue
c0233ef0 381      0.767279    qdisc_restart
c022dff0 345      0.69478     dev_queue_xmit
c025de90 298      0.600129    __fib_res_prefsrc
c023d6e0 294      0.592073    ip_finish_output
c02567d0 145      0.292009    arp_bind_neighbour

Here's 2.5.72 (which seems to have all of the patches already in), empty
routing table:

60.0085 seconds passed, avg forwarding rate: 166543.268 pps
60.0080 seconds passed, avg forwarding rate: 167055.912 pps
60.0051 seconds passed, avg forwarding rate: 166843.560 pps

vma      samples  %           symbol name
c02c0020 5193     10.2685     fn_hash_lookup
c02930d0 3475     6.87139     ip_route_input_slow
c02222c0 2349     4.64486     tg3_start_xmit
c0291c10 2217     4.38385     rt_intern_hash
c02bde40 1910     3.77679     fib_validate_source
c0293900 1864     3.68583     ip_route_input
c02953d0 1646     3.25477     ip_rcv
c0288b40 1609     3.1816      netif_receive_skb
c0135210 1462     2.89093     kmem_cache_free
c0134fd0 1457     2.88104     free_block
c02216a0 1390     2.74856     tg3_rx
c0135150 1295     2.56071     kmem_cache_alloc
c02912d0 1275     2.52116     rt_hash_code
c028f040 1250     2.47172     eth_header
c0134e00 1250     2.47172     cache_alloc_refill
c028ca40 1223     2.41833     neigh_resolve_output
c028f740 1072     2.11975     pfifo_fast_dequeue
c0135190 1019     2.01495     __kmalloc
c028ba50 991      1.95958     neigh_lookup
c02bf1d0 843      1.66693     fib_semantic_match
c01adc10 816      1.61354     memcpy
c0284ba0 768      1.51863     alloc_skb
c0135250 724      1.43162     kfree
c028f1b0 702      1.38812     eth_type_trans
c02b8930 674      1.33275     inet_select_addr
c0288600 668      1.32089     dev_queue_xmit
c0297850 664      1.31298     ip_finish_output
c0221e20 654      1.29321     tg3_set_txd
c028b340 635      1.25564     dst_alloc
c01289e0 632      1.2497      call_rcu
c0296370 606      1.19829     ip_forward
c0297af0 567      1.12117     ip_output
c028c8c0 547      1.08163     neigh_hh_init
c028b470 547      1.08163     dst_destroy
c011f080 489      0.966938    local_bh_enable
c0221550 477      0.94321     tg3_recycle_rx

Erp, needed a new rtstat.  And a wider console, apparently:

 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf HASH: in_search out_search
22233        18  329638     0     0     0     0     0         0       0      0  329638  329634         2    0          665742          0
20523        22  329074     0     0     0     0     0         0       0      0  329074  329070         2    0          665184          0
23510        26  331502     0     0     0     0     0         0       0      0  331502  331498         2    0          671610          0
22552        24  330464     0     0     0     0     0         0       0      0  330464  330460         4    0          669214          0
20359         8  329512     0     0     0     0     0         0       0      0  329512  329508         2    0          664428          0
19965        22  330090     0     0     0     0     0         0       0      0  330090  330086         2    0          663296          0
20081        20  332660     0     0     0     0     0         0       0      0  332660  332656         2    0          671912          0
21113        22  330458     0     0     0     0     0         0       0      0  330458  330454         2    0          666340          0
19864        14  329778     0     0     0     0     0         0       0      0  329778  329774         2    0          667324          0
20195        18  329702     0     0     0     0     0         0       0      0  329702  329698         2    0          670646          0

Route cache size does not increase on 2.5, so the problems in 2.4 are
probably the result of me hacking in the 2.5 patch.

2.5.72, full routing table:

60.0057 seconds passed, avg forwarding rate: 101800.795 pps
60.0045 seconds passed, avg forwarding rate: 101612.797 pps
60.0046 seconds passed, avg forwarding rate: 102004.873 pps
60.0044 seconds passed, avg forwarding rate: 102042.629 pps
60.0055 seconds passed, avg forwarding rate: 102135.224 pps
60.0057 seconds passed, avg forwarding rate: 102158.546 pps
60.0044 seconds passed, avg forwarding rate: 102200.430 pps

vma      samples  %           symbol name
c02c0020 14206    33.0911     fn_hash_lookup
c02930d0 2103     4.89867     ip_route_input_slow
c02222c0 1436     3.34498     tg3_start_xmit
c0291c10 1328     3.09341     rt_intern_hash
c02bde40 1315     3.06313     fib_validate_source
c0293900 1122     2.61356     ip_route_input
c02953d0 1028     2.3946      ip_rcv
c02bf1d0 1013     2.35966     fib_semantic_match
c0288b40 957      2.22921     netif_receive_skb
c0134fd0 840      1.95667     free_block
c0135210 823      1.91707     kmem_cache_free
c02b8930 811      1.88912     inet_select_addr
c02216a0 804      1.87282     tg3_rx
c028ca40 801      1.86583     neigh_resolve_output
c02912d0 786      1.83089     rt_hash_code
c028f040 709      1.65153     eth_header
c0135190 700      1.63056     __kmalloc
c0134e00 692      1.61193     cache_alloc_refill
c028f740 644      1.50012     pfifo_fast_dequeue
c028ba50 597      1.39064     neigh_lookup
c0135150 591      1.37666     kmem_cache_alloc
c0284ba0 539      1.25553     alloc_skb
c01adc10 491      1.14372     memcpy
c0135250 449      1.04589     kfree
c028b340 437      1.01794     dst_alloc
c028f1b0 433      1.00862     eth_type_trans
c0297af0 422      0.982996    ip_output
c01289e0 402      0.936408    call_rcu
c0297850 400      0.931749    ip_finish_output
c0296370 386      0.899138    ip_forward
c0221e20 384      0.894479    tg3_set_txd
c0288600 365      0.850221    dev_queue_xmit
c011f080 364      0.847892    local_bh_enable
c02919c0 356      0.829257    rt_garbage_collect
c028c8c0 317      0.738411    neigh_hh_init
c028b470 313      0.729094    dst_destroy
c02212e0 299      0.696483    tg3_tx

 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf HASH: in_search out_search
18755        12  202740     0     0     0     0     0         0       0      0  202740  202736         2    0          405030          0
19945        20  203884     0     0     0     0     0         0       0      0  203884  203880         2    0          406726          0
18449         8  204152     0     0     0     0     0         0       0      0  204152  204148         0    0          409590          0
19637        10  205302     0     0     0     0     0         0       0      0  205302  205298         2    0          413004          0
19213        10  204022     0     0     0     0     0         0       0      0  204022  204018         2    0          411092          0
20182         8  204280     0     0     0     0     0         0       0      0  204280  204276         2    0          412044          0
19311        14  203378     0     0     0     0     0         0       0      0  203378  203374         2    0          411052          0
18790        16  202480     0     0     0     0     0         0       0      0  202480  202476         2    0          409440          0
18835        24  204776     0     0     0     0     0         0       0      0  204776  204772         0    0          414416          0
19830         8  204792     0     0     0     0     0         0       0      0  204792  204788         2    0          415514          0

Simon-
