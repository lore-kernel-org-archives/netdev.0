From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance tests
Date: Tue, 17 Jun 2003 13:37:03 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030617203703.GB25773@netnation.com>
References: <20030616.160856.35828947.davem@redhat.com> <20030616232750.GD18484@netnation.com> <20030616234937.GE18484@netnation.com> <20030617.085921.28790392.davem@redhat.com> <16111.18107.699689.704597@robur.slu.se> <20030617200721.GA25773@netnation.com> <1055881034.3199.43.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	"David S. Miller" <davem@redhat.com>, ralph+d@istop.com,
	hadi@shell.cyberus.ca, xerox@foonet.net, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Martin Josefsson <gandalf@wlug.westbo.se>
Content-Disposition: inline
In-Reply-To: <1055881034.3199.43.camel@tux.rsn.bth.se>
List-Id: netdev.vger.kernel.org

On Tue, Jun 17, 2003 at 10:17:14PM +0200, Martin Josefsson wrote:
> 
> >  size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf
> > 17929        13  214343     0     0     0     0 163822         0       0      0   50521   50519         0    0
> 
> Did you have rp_filter enabled? Looks like it.

Yes, good spotting.  Forwarding rate more than doubles when I turn off
rp_filter off (Debian turns it on by default).

60.0049 seconds passed, avg forwarding rate: 108222.462 pps
60.0041 seconds passed, avg forwarding rate: 108868.822 pps
60.0042 seconds passed, avg forwarding rate: 108767.194 pps
60.0040 seconds passed, avg forwarding rate: 108872.188 pps
60.0045 seconds passed, avg forwarding rate: 108856.575 pps
60.0041 seconds passed, avg forwarding rate: 108743.443 pps

Cpu type: Athlon
Cpu speed was (MHz estimation) : 1394.26
Counter 0 counted RETIRED_INSNS events (Retired instructions (includes exceptions, interrupts, resyncs)) with a unit mask of 0x00 (No unit mask) count 697000
vma      samples  %           symbol name
c02bf730 15382    33.0213     fn_hash_lookup
c0292b70 2127     4.56614     ip_route_input_slow
c02916b0 1380     2.96252     rt_intern_hash
c0222330 1340     2.87665     tg3_start_xmit
c02bd550 1336     2.86806     fib_validate_source
c0221710 1219     2.61689     tg3_rx
c02be8e0 1154     2.47735     fib_semantic_match
c0294e50 1068     2.29273     ip_rcv
c028f220 983      2.11026     pfifo_fast_dequeue
c0135230 981      2.10596     kmem_cache_free
c02b8040 906      1.94496     inet_select_addr
c0290d70 901      1.93422     rt_hash_code
c0134ff0 877      1.8827      free_block
c028eb20 873      1.87411     eth_header
c0135170 805      1.72814     kmem_cache_alloc
c02885c0 798      1.71311     netif_receive_skb
c02933a0 788      1.69164     ip_route_input
c028c520 778      1.67017     neigh_resolve_output
c0295df0 744      1.59718     ip_forward
c0134e20 734      1.57572     cache_alloc_refill
c01351b0 727      1.56069     __kmalloc
c028b530 686      1.47267     neigh_lookup
c01adc80 535      1.14851     memcpy
c0135270 510      1.09484     kfree
c0284620 506      1.08626     alloc_skb
c0291460 498      1.06908     rt_garbage_collect
c028ec90 480      1.03044     eth_type_trans
c028ae20 439      0.942424    dst_alloc
c0128a00 437      0.938131    call_rcu
c02972d0 433      0.929544    ip_finish_output
c0297570 407      0.873728    ip_output
c011f080 380      0.815766    local_bh_enable
c0288080 376      0.807179    dev_queue_xmit
c028eeb0 369      0.792151    qdisc_restart
c0221e90 361      0.774977    tg3_set_txd
c028af50 360      0.772831    dst_destroy
c028f1a0 352      0.755657    pfifo_fast_enqueue
c028c3a0 317      0.68052     neigh_hh_init
c02215c0 315      0.676227    tg3_recycle_rx
c0221350 308      0.6612      tg3_tx
c02be9b0 294      0.631145    __fib_res_prefsrc
c010fc40 200      0.42935     do_gettimeofday
c02b48c0 195      0.418617    arp_hash
c0292860 195      0.418617    rt_set_nexthop
c02b4df0 178      0.382122    arp_bind_neighbour
c0294500 159      0.341334    dst_free

 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf
20262         5  109659     0     0     0     0     0         0       0      0  109659  109657         1    0
19229         7  109493     0     0     0     0     0         0       0      0  109493  109491         0    0
20320         4  109576     0     0     0     0     0         0       0      0  109576  109574         1    0
19280         9  109439     0     0     0     0     0         0       0      0  109439  109437         1    0
20325        10  109314     0     0     0     0     0         0       0      0  109314  109312         1    0
18983         6  109530     0     0     0     0     0         0       0      0  109530  109528         1    0
20313         5  109867     0     0     0     0     0         0       0      0  109867  109865         0    0
19127         4  109256     0     0     0     0     0         0       0      0  109256  109254         1    0
18897         4  109508     0     0     0     0     0         0       0      0  109508  109506         1    0
20338        11  109717     0     0     0     0     0         0       0      0  109717  109715         0    0
19054         7  109209     0     0     0     0     0         0       0      0  109209  109207         1    0
20397        11  109273     0     0     0     0     0         0       0      0  109273  109271         1    0

Simon-

[        Simon Kirby        ][        Network Operations        ]
[     sim@netnation.com     ][   NetNation Communications Inc.  ]
[  Opinions expressed are not necessarily those of my employer. ]
