From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance tests
Date: Tue, 17 Jun 2003 13:07:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617200721.GA25773@netnation.com>
References: <20030616.160856.35828947.davem@redhat.com> <20030616232750.GD18484@netnation.com> <20030616234937.GE18484@netnation.com> <20030617.085921.28790392.davem@redhat.com> <16111.18107.699689.704597@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, ralph+d@istop.com,
   hadi@shell.cyberus.ca, xerox@foonet.net, fw@deneb.enyo.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16111.18107.699689.704597@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 17, 2003 at 06:50:03PM +0200, Robert Olsson wrote:

> David S. Miller writes:
> 
>  >    60.0073 seconds passed, avg forwarding rate: 157557.710 pps
> 
>  > To be honest, this isn't half-bad for pure DoS load.
> 
>  No thats pretty good and profiles looks as expected. It would interesting
>  to get the singeflow performance as a comparison.

I changed Juno to send from a single IP, but it only spat out about
330000 pps, which the dual Tigon3 Opteron box forwarded completely.
In order to do a single flow forwarding test, I need to be able to create
more input traffic somehow.  Seeing as you wrote pktgen.c, maybe you
could help in this department. :)

>  Also think Simon used only /32 routes... I took "real" Internet-routing
>  and made a script so it can be used for experiments. I can make it available.

Yes, I found that area less interesting since Dave M. fixed the hash
buckets.  But yes, the prefix scanning will slow it down some.

Whoa.  Uhm.  A lot.  I should compare with 2.4 again to see what's going
on here.

60.0042 seconds passed, avg forwarding rate: 50759.683 pps
60.0039 seconds passed, avg forwarding rate: 50311.258 pps
60.0046 seconds passed, avg forwarding rate: 50420.562 pps
60.0036 seconds passed, avg forwarding rate: 50399.389 pps
60.0038 seconds passed, avg forwarding rate: 50431.732 pps
60.0041 seconds passed, avg forwarding rate: 50403.777 pps
60.0036 seconds passed, avg forwarding rate: 50210.604 pps
60.0033 seconds passed, avg forwarding rate: 50279.220 pps
60.0036 seconds passed, avg forwarding rate: 50549.291 pps
60.0046 seconds passed, avg forwarding rate: 50437.615 pps

Cpu type: Athlon
Cpu speed was (MHz estimation) : 1394.26
Counter 0 counted RETIRED_INSNS events (Retired instructions (includes exceptions, interrupts, resyncs)) with a unit mask of 0x00 (No unit mask) count 697000
vma      samples  %           symbol name
c02bf730 16019    33.2014     fn_hash_lookup
c0292b70 3882     8.04593     ip_route_input_slow
c0221710 2335     4.83958     tg3_rx
c02bd550 2004     4.15354     fib_validate_source
c0290d70 1955     4.05198     rt_hash_code
c0294e50 1670     3.46128     ip_rcv
c02933a0 1404     2.90997     ip_route_input
c01351b0 1349     2.79597     __kmalloc
c02885c0 1314     2.72343     netif_receive_skb
c02b8040 1168     2.42083     inet_select_addr
c0135270 1123     2.32756     kfree
c0284620 987      2.04568     alloc_skb
c028ec90 900      1.86536     eth_type_trans
c0135170 860      1.78246     kmem_cache_alloc
c02be8e0 844      1.7493      fib_semantic_match
c0135230 812      1.68297     kmem_cache_free
c0222330 652      1.35135     tg3_start_xmit
c02916b0 648      1.34306     rt_intern_hash
c02215c0 542      1.12336     tg3_recycle_rx
c010fc40 459      0.951335    do_gettimeofday
c028f220 422      0.874648    pfifo_fast_dequeue
c02be9b0 419      0.86843     __fib_res_prefsrc
c028eb20 417      0.864285    eth_header
c0295df0 386      0.800033    ip_forward
c028c520 363      0.752363    neigh_resolve_output
c0284860 345      0.715056    __kfree_skb
c0284840 311      0.644586    kfree_skbmem
c02847a0 295      0.611424    skb_release_data
c028b530 285      0.590698    neigh_lookup
c01adc80 276      0.572044    memcpy
c0134ff0 269      0.557536    free_block
c0291460 240      0.49743     rt_garbage_collect
c0134e20 236      0.489139    cache_alloc_refill
c02972d0 216      0.447687    ip_finish_output
c0114030 215      0.445614    get_offset_tsc
c0128a00 197      0.408307    call_rcu
c028ae20 193      0.400017    dst_alloc
c0288080 187      0.387581    dev_queue_xmit
c028af50 184      0.381363    dst_destroy
c028f1a0 175      0.362709    pfifo_fast_enqueue
c011f080 170      0.352346    local_bh_enable
c0221350 168      0.348201    tg3_tx
c0221e90 160      0.33162     tg3_set_txd
c0297570 152      0.315039    ip_output
c028c3a0 149      0.308821    neigh_hh_init
c028eeb0 141      0.29224     qdisc_restart

 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf
17929        13  214343     0     0     0     0 163822         0       0      0   50521   50519         0    0
18296        18  213694     0     0     0     0 163018         0       0      0   50676   50674         1    0
17616        11  214529     0     0     0     0 163993         0       0      0   50536   50534         0    0
17841        12  213816     0     0     0     0 163157         0       0      0   50659   50657         1    0
18272         7  214093     0     0     0     0 163583         0       0      0   50510   50508         1    0
18216         9  214843     0     0     0     0 164214         0       0      0   50629   50627         0    0
18318        16  214976     0     0     0     0 164299         0       0      0   50677   50675         0    0
18099         9  213447     0     0     0     0 162995         0       0      0   50452   50450         1    0
17610        14  216438     0     0     0     0 165408         0       0      0   51030   51028         1    0
17643        14  214638     0     0     0     0 163987         0       0      0   50651   50649         0    0
17516         7  213185     0     0     0     0 163016         0       0      0   50169   50167         1    0
18355        10  213894     0     0     0     0 163564         0       0      0   50330   50328         1    0
17723        11  214477     0     0     0     0 163705         0       0      0   50772   50770         0    0
17915         6  214342     0     0     0     0 163625         0       0      0   50717   50715         0    0
18166        19  213965     0     0     0     0 163521         0       0      0   50444   50442         0    0
17943        19  213417     0     0     0     0 162955         0       0      0   50462   50460         2    0
17515         5  214423     0     0     0     0 163718         0       0      0   50705   50703         0    0
18231        10  213434     0     0     0     0 162919         0       0      0   50515   50513         1    0
17523         8  213856     0     0     0     0 163385         0       0      0   50471   50469         0    0
18217        16  214940     0     0     0     0 164165         0       0      0   50775   50773         0    0

...recompiling with fibstats...

Erm.  I can't get fib_stats2.pat to apply against 2.5.71, 2.5.71+davem's
join-two-diffs patch, 2.4.21-rc7, or 2.5.71+davem's rtcache changes. 
What's it supposed to be against?

[sroot@debinst:/d/linux-2.5]# patch -p0 --dry < ../fib_stats2.pat
patching file include/net/ip_fib.h
Hunk #1 succeeded at 139 (offset 4 lines).
patching file net/ipv4/fib_hash.c
Hunk #3 succeeded at 305 (offset -11 lines).
Hunk #4 succeeded at 1110 with fuzz 1 (offset -14 lines).
Hunk #5 succeeded at 1166 (offset -14 lines).
patching file net/ipv4/route.c
Hunk #1 FAILED at 2754.
Hunk #2 succeeded at 2760 (offset -6 lines).
Hunk #3 succeeded at 2783 (offset -6 lines).
Hunk #4 FAILED at 2793.
2 out of 4 hunks FAILED -- saving rejects to file net/ipv4/route.c.rej

In any event, here is the profile of the single flow case with the full
routing table (probably identical to the empty routing table case).  The
sender is pushing enough for NAPI to kick in, so there is a lot of tg3
overhead that would be with more traffic:

60.0041 seconds passed, avg forwarding rate: 329808.310 pps

Cpu type: Athlon
Cpu speed was (MHz estimation) : 1394.26
Counter 0 counted RETIRED_INSNS events (Retired instructions (includes
exceptions, interrupts, resyncs)) with a unit mask of 0x00 (No unit mask)
count 697000
vma      samples  %           symbol name
c0222330 4470     8.51445     tg3_start_xmit
c0221710 3760     7.16204     tg3_rx
c0294e50 3142     5.98488     ip_rcv
c02885c0 2428     4.62485     netif_receive_skb
c0295df0 2065     3.93341     ip_forward
c028f220 2058     3.92007     pfifo_fast_dequeue
c02933a0 2033     3.87245     ip_route_input
c01351b0 1987     3.78483     __kmalloc
c0290d70 1904     3.62674     rt_hash_code
c02972d0 1752     3.33721     ip_finish_output
c01adc80 1649     3.14101     memcpy
c0134ff0 1626     3.0972      free_block
c0284620 1511     2.87815     alloc_skb
c0135270 1489     2.83624     kfree
c0288080 1461     2.78291     dev_queue_xmit
c028ec90 1351     2.57338     eth_type_trans
c0135170 1319     2.51243     kmem_cache_alloc
c028f1a0 1243     2.36766     pfifo_fast_enqueue
c0134e20 1172     2.23242     cache_alloc_refill
c0297570 1145     2.18099     ip_output
c0135230 1133     2.15814     kmem_cache_free
c0221350 1085     2.06671     tg3_tx
c0221a50 991      1.88766     tg3_poll
c02215c0 893      1.70098     tg3_recycle_rx
c0221e90 832      1.58479     tg3_set_txd
c0221b60 812      1.5467      tg3_interrupt
c028eeb0 755      1.43812     qdisc_restart
c010fc40 672      1.28002     do_gettimeofday
c011f080 578      1.10097     local_bh_enable
c0284840 492      0.937161    kfree_skbmem
c010a8b2 426      0.811444    restore_all
c02847a0 375      0.714299    skb_release_data
c010c6a0 327      0.622869    handle_IRQ_event
c010c910 288      0.548582    do_IRQ
c0284860 284      0.540963    __kfree_skb
c0114030 283      0.539058    get_offset_tsc
c021f4b0 270      0.514296    tg3_enable_ints
c0115e10 234      0.445723    end_level_ioapic_irq
c011f4a0 220      0.419056    cpu_raise_softirq
c028eb20 199      0.379055    eth_header
c0288500 188      0.358102    net_tx_action
c028c520 187      0.356197    neigh_resolve_output
c0134b40 179      0.340959    cache_init_objs
c0288900 171      0.32572     net_rx_action
c0132290 165      0.314292    buffered_rmqueue
c01321b0 122      0.232385    free_hot_cold_page

If I start two threads on the sender (Xeon w/HT), I'm able to push 420000
pps, which only partially starts to use NAPI on the Opteron box.  Going
to try 2.4 again for a comparison (note: 2.5 seems to have an opposite
PCI scan order from 2.4 for the dual Tigon3s).

Simon-

[        Simon Kirby        ][        Network Operations        ]
[     sim@netnation.com     ][   NetNation Communications Inc.  ]
[  Opinions expressed are not necessarily those of my employer. ]
