From: Thomas Graf <tgraf@infradead.org>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 1 Mar 2011 10:07:58 -0500
Message-ID: <20110301150758.GC10761@canuck.infradead.org>
References: <1298977984.3284.15.camel@edumazet-laptop>
 <20110301112759.GK9763@canuck.infradead.org>
 <1298979909.3284.28.camel@edumazet-laptop>
 <20110301121829.GM9763@canuck.infradead.org>
 <20110301121951.GA7267@gondor.apana.org.au>
 <20110301135053.GA6684@canuck.infradead.org>
 <1298988419.3284.107.camel@edumazet-laptop>
 <20110301142235.GA10761@canuck.infradead.org>
 <20110301143050.GB10761@canuck.infradead.org>
 <1298991160.3284.108.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:53201 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756539Ab1CAPIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 10:08:05 -0500
Content-Disposition: inline
In-Reply-To: <1298991160.3284.108.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 03:52:40PM +0100, Eric Dumazet wrote:
> Le mardi 01 mars 2011 =E0 09:30 -0500, Thomas Graf a =E9crit :
> > On Tue, Mar 01, 2011 at 09:22:35AM -0500, Thomas Graf wrote:
> > > On Tue, Mar 01, 2011 at 03:06:59PM +0100, Eric Dumazet wrote:
> > > > Would be nice to cpu affine named to _not_ run on CPU11, just t=
o
> > > > specialize it for TX completions and have softirq time percenta=
ge and
> > > > "perf top -C 11 " results
> >=20
> > CPU 1 isolated as well (named running with mask 0,2-10)
> >=20
> > -------------------------------------------------------------------=
---------------------------------------------------
> >    PerfTop:     580 irqs/sec  kernel:100.0%  exact:  0.0% [1000Hz c=
pu-clock-msecs],  (all, CPU: 1)
> > -------------------------------------------------------------------=
---------------------------------------------------
> >=20
> >              samples  pcnt function                    DSO
> >              _______ _____ ___________________________ ____________=
_______________________________________________
> >=20
> >               283.00  9.2% get_rx_page_info            /lib/modules=
/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
> >               256.00  8.4% _raw_spin_unlock_irqrestore /lib/modules=
/2.6.38-rc5+/build/vmlinux                    =20
> >               190.00  6.2% be_poll_rx                  /lib/modules=
/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
> >               182.00  5.9% get_page_from_freelist      /lib/modules=
/2.6.38-rc5+/build/vmlinux                    =20
> >               157.00  5.1% intel_idle                  /lib/modules=
/2.6.38-rc5+/build/vmlinux                    =20
> >               143.00  4.7% __do_softirq                /lib/modules=
/2.6.38-rc5+/build/vmlinux                    =20
> >               133.00  4.3% sock_queue_rcv_skb          /lib/modules=
/2.6.38-rc5+/build/vmlinux                    =20
> >               133.00  4.3% __udp4_lib_lookup           /lib/modules=
/2.6.38-rc5+/build/vmlinux                    =20
> >               131.00  4.3% sk_run_filter               /lib/modules=
/2.6.38-rc5+/build/vmlinux  =20
>=20
> sk_run_filter ? Do you have a packet filter running ?

dhclient was running. With dhclient killed:

-----------------------------------------------------------------------=
-----------------------------------------------
   PerfTop:     726 irqs/sec  kernel:99.9%  exact:  0.0% [1000Hz cpu-cl=
ock-msecs],  (all, CPU: 1)
-----------------------------------------------------------------------=
-----------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ________________=
___________________________________________

              472.00 10.6% get_rx_page_info            /lib/modules/2.6=
=2E38-rc5+/kernel/drivers/net/benet/be2net.ko
              419.00  9.4% _raw_spin_unlock_irqrestore /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
              280.00  6.3% be_poll_rx                  /lib/modules/2.6=
=2E38-rc5+/kernel/drivers/net/benet/be2net.ko
              259.00  5.8% get_page_from_freelist      /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
              248.00  5.6% __do_softirq                /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
              238.00  5.4% intel_idle                  /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
              204.00  4.6% sock_queue_rcv_skb          /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
              189.00  4.3% __udp4_lib_lookup           /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
              178.00  4.0% getnstimeofday              /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
              169.00  3.8% __alloc_skb                 /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
              144.00  3.2% read_tsc                    /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
              143.00  3.2% sock_def_readable           /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
              138.00  3.1% udp_queue_rcv_skb           /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
              115.00  2.6% kmem_cache_alloc_node_trace /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
              114.00  2.6% __netif_receive_skb         /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
              109.00  2.5% _raw_spin_lock              /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
              100.00  2.3% is_swiotlb_buffer           /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               90.00  2.0% __phys_addr                 /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               82.00  1.8% __udp4_lib_rcv              /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               80.00  1.8% kmem_cache_alloc_node       /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               73.00  1.6% ip_route_input_common       /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               60.00  1.4% memcpy                      /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               59.00  1.3% dma_issue_pending_all       /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               58.00  1.3% ip_rcv                      /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               57.00  1.3% be_post_rx_frags            /lib/modules/2.6=
=2E38-rc5+/kernel/drivers/net/benet/be2net.ko
               49.00  1.1% __alloc_pages_nodemask      /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               45.00  1.0% alloc_pages_current         /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               27.00  0.6% get_rps_cpu                 /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               23.00  0.5% napi_complete               /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               22.00  0.5% ip_local_deliver            /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               18.00  0.4% selinux_socket_sock_rcv_skb /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               17.00  0.4% native_read_tsc             /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               16.00  0.4% local_bh_enable             /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               16.00  0.4% next_zones_zonelist         /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               14.00  0.3% sk_filter                   /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               13.00  0.3% eth_type_trans              /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               10.00  0.2% __kmalloc_node_track_caller /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
               10.00  0.2% _raw_spin_lock_irqsave      /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
                9.00  0.2% raw_local_deliver           /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
                8.00  0.2% __udp_queue_rcv_skb         /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
                8.00  0.2% netif_receive_skb           /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
                8.00  0.2% ip_queue_rcv_skb            /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
                7.00  0.2% net_rx_action               /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
                6.00  0.1% swiotlb_map_page            /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
                6.00  0.1% __sk_mem_schedule           /lib/modules/2.6=
=2E38-rc5+/build/vmlinux                    =20
                6.00  0.1% dso__find_symbol            /usr/bin/perf   =
                                          =20
                6.00  0.1% __netdev_alloc_skb          /lib/modules/2.6=
=2E38-rc5+/build/vmlinux             =20
