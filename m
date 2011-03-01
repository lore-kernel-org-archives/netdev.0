From: Thomas Graf <tgraf@infradead.org>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 1 Mar 2011 09:30:50 -0500
Message-ID: <20110301143050.GB10761@canuck.infradead.org>
References: <1298975602.3284.13.camel@edumazet-laptop>
 <20110301110708.GJ9763@canuck.infradead.org>
 <1298977984.3284.15.camel@edumazet-laptop>
 <20110301112759.GK9763@canuck.infradead.org>
 <1298979909.3284.28.camel@edumazet-laptop>
 <20110301121829.GM9763@canuck.infradead.org>
 <20110301121951.GA7267@gondor.apana.org.au>
 <20110301135053.GA6684@canuck.infradead.org>
 <1298988419.3284.107.camel@edumazet-laptop>
 <20110301142235.GA10761@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:40949 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753069Ab1CAOa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 09:30:57 -0500
Content-Disposition: inline
In-Reply-To: <20110301142235.GA10761@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 09:22:35AM -0500, Thomas Graf wrote:
> On Tue, Mar 01, 2011 at 03:06:59PM +0100, Eric Dumazet wrote:
> > Would be nice to cpu affine named to _not_ run on CPU11, just to
> > specialize it for TX completions and have softirq time percentage and
> > "perf top -C 11 " results

CPU 1 isolated as well (named running with mask 0,2-10)

----------------------------------------------------------------------------------------------------------------------
   PerfTop:     580 irqs/sec  kernel:100.0%  exact:  0.0% [1000Hz cpu-clock-msecs],  (all, CPU: 1)
----------------------------------------------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ___________________________________________________________

              283.00  9.2% get_rx_page_info            /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
              256.00  8.4% _raw_spin_unlock_irqrestore /lib/modules/2.6.38-rc5+/build/vmlinux                     
              190.00  6.2% be_poll_rx                  /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
              182.00  5.9% get_page_from_freelist      /lib/modules/2.6.38-rc5+/build/vmlinux                     
              157.00  5.1% intel_idle                  /lib/modules/2.6.38-rc5+/build/vmlinux                     
              143.00  4.7% __do_softirq                /lib/modules/2.6.38-rc5+/build/vmlinux                     
              133.00  4.3% sock_queue_rcv_skb          /lib/modules/2.6.38-rc5+/build/vmlinux                     
              133.00  4.3% __udp4_lib_lookup           /lib/modules/2.6.38-rc5+/build/vmlinux                     
              131.00  4.3% sk_run_filter               /lib/modules/2.6.38-rc5+/build/vmlinux                     
              114.00  3.7% getnstimeofday              /lib/modules/2.6.38-rc5+/build/vmlinux                     
              112.00  3.7% __alloc_skb                 /lib/modules/2.6.38-rc5+/build/vmlinux                     
              103.00  3.4% read_tsc                    /lib/modules/2.6.38-rc5+/build/vmlinux                     
              100.00  3.3% __netif_receive_skb         /lib/modules/2.6.38-rc5+/build/vmlinux                     
               95.00  3.1% udp_queue_rcv_skb           /lib/modules/2.6.38-rc5+/build/vmlinux                     
               82.00  2.7% sock_def_readable           /lib/modules/2.6.38-rc5+/build/vmlinux                     
               79.00  2.6% kmem_cache_alloc_node_trace /lib/modules/2.6.38-rc5+/build/vmlinux                     
               72.00  2.3% _raw_spin_lock              /lib/modules/2.6.38-rc5+/build/vmlinux                     
               67.00  2.2% __phys_addr                 /lib/modules/2.6.38-rc5+/build/vmlinux                     
               63.00  2.1% is_swiotlb_buffer           /lib/modules/2.6.38-rc5+/build/vmlinux                     
               51.00  1.7% __udp4_lib_rcv              /lib/modules/2.6.38-rc5+/build/vmlinux                     
               48.00  1.6% memcpy                      /lib/modules/2.6.38-rc5+/build/vmlinux                     
               47.00  1.5% ip_rcv                      /lib/modules/2.6.38-rc5+/build/vmlinux                     
               46.00  1.5% kmem_cache_alloc_node       /lib/modules/2.6.38-rc5+/build/vmlinux                     
               44.00  1.4% dma_issue_pending_all       /lib/modules/2.6.38-rc5+/build/vmlinux                     
               40.00  1.3% ip_route_input_common       /lib/modules/2.6.38-rc5+/build/vmlinux                     
               36.00  1.2% __alloc_pages_nodemask      /lib/modules/2.6.38-rc5+/build/vmlinux                     
               33.00  1.1% be_post_rx_frags            /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
               24.00  0.8% alloc_pages_current         /lib/modules/2.6.38-rc5+/build/vmlinux                     
               21.00  0.7% packet_rcv                  /lib/modules/2.6.38-rc5+/build/vmlinux                     
               20.00  0.7% local_bh_enable             /lib/modules/2.6.38-rc5+/build/vmlinux                     
               17.00  0.6% consume_skb                 /lib/modules/2.6.38-rc5+/build/vmlinux                     
               16.00  0.5% next_zones_zonelist         /lib/modules/2.6.38-rc5+/build/vmlinux                     
               14.00  0.5% selinux_socket_sock_rcv_skb /lib/modules/2.6.38-rc5+/build/vmlinux                     
               13.00  0.4% ip_local_deliver            /lib/modules/2.6.38-rc5+/build/vmlinux                     
               11.00  0.4% sk_filter                   /lib/modules/2.6.38-rc5+/build/vmlinux                     
               10.00  0.3% get_rps_cpu                 /lib/modules/2.6.38-rc5+/build/vmlinux                     
                9.00  0.3% native_read_tsc             /lib/modules/2.6.38-rc5+/build/vmlinux                     
                8.00  0.3% local_bh_disable            /lib/modules/2.6.38-rc5+/build/vmlinux                     
                8.00  0.3% eth_type_trans              /lib/modules/2.6.38-rc5+/build/vmlinux                     
                8.00  0.3% napi_complete               /lib/modules/2.6.38-rc5+/build/vmlinux                     
                7.00  0.2% netif_receive_skb           /lib/modules/2.6.38-rc5+/build/vmlinux                     
                7.00  0.2% dso__find_symbol            /usr/bin/perf                                              
                7.00  0.2% __kmalloc_node_track_caller /lib/modules/2.6.38-rc5+/build/vmlinux             
