From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance tests
Date: Mon, 16 Jun 2003 16:49:37 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030616234937.GE18484@netnation.com>
References: <20030616223714.GB18484@netnation.com> <20030616.154401.132900800.davem@redhat.com> <20030616230922.GC18484@netnation.com> <20030616.160856.35828947.davem@redhat.com> <20030616232750.GD18484@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ralph+d@istop.com, hadi@shell.cyberus.ca, xerox@foonet.net,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030616232750.GD18484@netnation.com>
List-Id: netdev.vger.kernel.org

On Mon, Jun 16, 2003 at 04:27:50PM -0700, Simon Kirby wrote:

> On Mon, Jun 16, 2003 at 04:08:56PM -0700, David S. Miller wrote:
> 
> > It depends upon the first patch that I enclosed.
> 
> Never mind. :)  Such patches don't work very well with patch --dry.

Okay, here goes 2.5.71 + this patch:

60.0049 seconds passed, avg forwarding rate: 160190.859 pps
60.0085 seconds passed, avg forwarding rate: 157118.708 pps
60.0046 seconds passed, avg forwarding rate: 157211.097 pps
60.0073 seconds passed, avg forwarding rate: 157557.710 pps

...Looks like a tad worse than with your patch, but not by much. 
Forwarding rate is still pretty crappy for an Opteron.  Will fiddle
a bit more tonight to see what I can do.

Cpu type: Athlon
Cpu speed was (MHz estimation) : 1394.27
Counter 0 counted RETIRED_INSNS events (Retired instructions (includes exceptions, interrupts, resyncs)) with a unit mask of 0x00 (No unit mask) count 697000
vma      samples  %           symbol name
c02c0ea0 5113     9.07075     fn_hash_lookup
c0293970 3264     5.79052     ip_route_input_slow
c028ef90 2734     4.85027     nf_iterate
c028f280 2525     4.47949     nf_hook_slow
c02924b0 2127     3.77342     rt_intern_hash
c0222330 2125     3.76987     tg3_start_xmit
c02becc0 1755     3.11347     fib_validate_source
c0290020 1684     2.98751     pfifo_fast_dequeue
c0296220 1531     2.71608     ip_rcv_finish
c0135230 1449     2.57061     kmem_cache_free
c0134ff0 1431     2.53867     free_block
c0221710 1369     2.42868     tg3_rx
c0295cb0 1350     2.39498     ip_rcv
c0135170 1304     2.31337     kmem_cache_alloc
c02941a0 1258     2.23176     ip_route_input
c028f920 1255     2.22644     eth_header
c0134e20 1148     2.03662     cache_alloc_refill
c0291b70 1104     1.95856     rt_hash_code
c02886a0 1082     1.91953     netif_receive_skb
c01351b0 983      1.7439      __kmalloc
c028b610 923      1.63745     neigh_lookup
c02c0050 914      1.62149     fib_semantic_match
c029a660 857      1.52037     ip_finish_output2
c028c600 829      1.47069     neigh_resolve_output
c01adc80 766      1.35893     memcpy
c0135270 743      1.31812     kfree
c0297000 741      1.31458     ip_forward
c0284620 686      1.217       alloc_skb
c02b9730 666      1.18152     inet_select_addr
c028fa90 663      1.1762      eth_type_trans
c0128a00 649      1.15136     call_rcu
c0297240 623      1.10524     ip_forward_finish
c028af00 620      1.09991     dst_alloc
c0288160 597      1.05911     dev_queue_xmit
c028ffa0 570      1.01121     pfifo_fast_enqueue
c028b030 486      0.862191    dst_destroy
c0292260 485      0.860417    rt_garbage_collect
c028fcb0 472      0.837355    qdisc_restart
c0221350 467      0.828484    tg3_tx
c028c480 463      0.821388    neigh_hh_init
c02215c0 455      0.807196    tg3_recycle_rx
c02d0f70 447      0.793003    ipv4_sabotage_out
c0298580 443      0.785907    ip_finish_output
c011f080 430      0.762844    local_bh_enable
c010fc40 358      0.635112    do_gettimeofday
c0284860 345      0.612049    __kfree_skb

 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf
22910        10  158190     0     0     0     0     0         0       0      0  158190  158188         1    0
20590        10  158330     0     0     0     0     0         0       0      0  158330  158328         1    0
20515        14  158306     0     0     0     0     0         0       0      0  158306  158304         1    0
21000         4  158964     0     0     0     0     0         0       0      0  158964  158962         1    0
21631         8  159300     0     0     0     0     0         0       0      0  159300  159298         0    0
20329        13  160059     0     0     0     0     0         0       0      0  160059  160057         1    0
22995         7  157441     0     0     0     0     0         0       0      0  157441  157439         1    0
22418         9  156831     0     0     0     0     0         0       0      0  156831  156829         1    0
22417        11  157321     0     0     0     0     0         0       0      0  157321  157319         1    0
21339         6  157898     0     0     0     0     0         0       0      0  157898  157896         0    0
22562        10  157734     0     0     0     0     0         0       0      0  157734  157732         1    0
20488        12  159496     0     0     0     0     0         0       0      0  159496  159493         1    0
22527        10  157674     0     0     0     0     0         0       0      0  157674  157672         1    0
21992         7  156729     0     0     0     0     0         0       0      0  156729  156727         0    0
21372        10  157106     0     0     0     0     0         0       0      0  157106  157104         1    0
22950        10  156402     0     0     0     0     0         0       0      0  156402  156400         2    0
20471        11  157057     0     0     0     0     0         0       0      0  157057  157055         1    0
20864        13  159082     0     0     0     0     0         0       0      0  159082  159080         0    0
22416        10  157658     0     0     0     0     0         0       0      0  157658  157656         1    0
22659         8  157348     0     0     0     0     0         0       0      0  157348  157346         1    0

Simon-

[        Simon Kirby        ][        Network Operations        ]
[     sim@netnation.com     ][   NetNation Communications Inc.  ]
[  Opinions expressed are not necessarily those of my employer. ]
