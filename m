From: Thomas Graf <tgraf@infradead.org>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 1 Mar 2011 08:50:53 -0500
Message-ID: <20110301135053.GA6684@canuck.infradead.org>
References: <20110228163742.GH9763@canuck.infradead.org>
 <1298912869.2941.687.camel@edumazet-laptop>
 <20110301101955.GI9763@canuck.infradead.org>
 <1298975602.3284.13.camel@edumazet-laptop>
 <20110301110708.GJ9763@canuck.infradead.org>
 <1298977984.3284.15.camel@edumazet-laptop>
 <20110301112759.GK9763@canuck.infradead.org>
 <1298979909.3284.28.camel@edumazet-laptop>
 <20110301121829.GM9763@canuck.infradead.org>
 <20110301121951.GA7267@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:33425 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051Ab1CANvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 08:51:00 -0500
Content-Disposition: inline
In-Reply-To: <20110301121951.GA7267@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 08:19:51PM +0800, Herbert Xu wrote:
> On Tue, Mar 01, 2011 at 07:18:29AM -0500, Thomas Graf wrote:
> >
> > 
> > ... makes it use CPU 5 for rxq2 and the qps goes up from 250kqps to 270kqps
> 
> I think the increase here comes from the larger number of packets
> in flight more than anything.
> 
> The bottleneck is still the TX queue (both software and hardware).

Disabled netfilter and reran test

Now does ~316kqps (rx was split over 2 queues)

----------------------------------------------------------------------------------------------------------------------
   PerfTop:   30608 irqs/sec  kernel:66.1%  exact:  0.0% [1000Hz cpu-clock-msecs],  (all, CPU: 1)
----------------------------------------------------------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ ___________________________________________________________

            19237.00  5.6% _raw_spin_unlock_irqrestore   /lib/modules/2.6.38-rc5+/build/vmlinux                     
            17170.00  5.0% get_rx_page_info              /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
            11411.00  3.3% be_poll_rx                    /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
            11320.00  3.3% isc_rwlock_lock               /usr/lib64/libisc.so.62.0.1                                
            10669.00  3.1% __do_softirq                  /lib/modules/2.6.38-rc5+/build/vmlinux                     
            10655.00  3.1% get_page_from_freelist        /lib/modules/2.6.38-rc5+/build/vmlinux                     
             9523.00  2.8% intel_idle                    /lib/modules/2.6.38-rc5+/build/vmlinux                     
             8677.00  2.5% __udp4_lib_lookup             /lib/modules/2.6.38-rc5+/build/vmlinux                     
             8379.00  2.4% sock_queue_rcv_skb            /lib/modules/2.6.38-rc5+/build/vmlinux                     
             8226.00  2.4% sk_run_filter                 /lib/modules/2.6.38-rc5+/build/vmlinux                     
             6724.00  1.9% __netif_receive_skb           /lib/modules/2.6.38-rc5+/build/vmlinux                     
             6553.00  1.9% __alloc_skb                   /lib/modules/2.6.38-rc5+/build/vmlinux                     
             6205.00  1.8% udp_queue_rcv_skb             /lib/modules/2.6.38-rc5+/build/vmlinux                     
             6038.00  1.7% _raw_spin_lock                /lib/modules/2.6.38-rc5+/build/vmlinux                     
             5868.00  1.7% isc_rwlock_unlock             /usr/lib64/libisc.so.62.0.1                                
             5696.00  1.6% dns_rbt_findnode              /usr/lib64/libdns.so.69.0.1                                
             5647.00  1.6% read_tsc                      /lib/modules/2.6.38-rc5+/build/vmlinux                     
             5633.00  1.6% getnstimeofday                /lib/modules/2.6.38-rc5+/build/vmlinux                     
             5448.00  1.6% kmem_cache_alloc_node_trace   /lib/modules/2.6.38-rc5+/build/vmlinux                     
             5272.00  1.5% finish_task_switch            /lib/modules/2.6.38-rc5+/build/vmlinux                     
             4719.00  1.4% sock_def_readable             /lib/modules/2.6.38-rc5+/build/vmlinux                     
             4002.00  1.2% is_swiotlb_buffer             /lib/modules/2.6.38-rc5+/build/vmlinux                     
             3914.00  1.1% memcpy                        /lib/modules/2.6.38-rc5+/build/vmlinux                     
             3717.00  1.1% isc_stats_increment           /usr/lib64/libisc.so.62.0.1                                
             3706.00  1.1% __udp4_lib_rcv                /lib/modules/2.6.38-rc5+/build/vmlinux                     
             3653.00  1.1% ip_rcv                        /lib/modules/2.6.38-rc5+/build/vmlinux                     
             3598.00  1.0% kmem_cache_alloc_node         /lib/modules/2.6.38-rc5+/build/vmlinux                     
             3407.00  1.0% ip_route_input_common         /lib/modules/2.6.38-rc5+/build/vmlinux                     
             2683.00  0.8% be_post_rx_frags              /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
             2666.00  0.8% __pthread_mutex_lock_internal /lib64/libpthread-2.12.so                                  
             2331.00  0.7% __phys_addr                   /lib/modules/2.6.38-rc5+/build/vmlinux                     
             2230.00  0.6% __alloc_pages_nodemask        /lib/modules/2.6.38-rc5+/build/vmlinux                     
             2023.00  0.6% dns_name_fullcompare          /usr/lib64/libdns.so.69.0.1                                
             1972.00  0.6% packet_rcv                    /lib/modules/2.6.38-rc5+/build/vmlinux                     
             1902.00  0.6% eth_type_trans                /lib/modules/2.6.38-rc5+/build/vmlinux                     
             1860.00  0.5% __pthread_mutex_unlock        /lib64/libpthread-2.12.so                                  
             1804.00  0.5% fget_light                    /lib/modules/2.6.38-rc5+/build/vmlinux                     
             1739.00  0.5% alloc_pages_current           /lib/modules/2.6.38-rc5+/build/vmlinux                     
             1736.00  0.5% dns_rbtnodechain_init         /usr/lib64/libdns.so.69.0.1                            

----------------------------------------------------------------------------------------------------------------------
   PerfTop:   29038 irqs/sec  kernel:48.0%  exact:  0.0% [1000Hz cpu-clock-msecs],  (all, CPU: 11)
----------------------------------------------------------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ ___________________________________________________________

            12833.00  7.5% intel_idle                    /lib/modules/2.6.38-rc5+/build/vmlinux                     
            10771.00  6.3% isc_rwlock_lock               /usr/lib64/libisc.so.62.0.1                                
             8713.00  5.1% be_tx_compl_process           /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
             6452.00  3.8% kfree                         /lib/modules/2.6.38-rc5+/build/vmlinux                     
             5935.00  3.5% skb_release_data              /lib/modules/2.6.38-rc5+/build/vmlinux                     
             5552.00  3.2% kmem_cache_free               /lib/modules/2.6.38-rc5+/build/vmlinux                     
             5292.00  3.1% isc_rwlock_unlock             /usr/lib64/libisc.so.62.0.1                                
             4893.00  2.9% dns_rbt_findnode              /usr/lib64/libdns.so.69.0.1                                
             4413.00  2.6% kfree_skb                     /lib/modules/2.6.38-rc5+/build/vmlinux                     
             3802.00  2.2% be_poll_tx_mcc                /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
             3515.00  2.1% isc_stats_increment           /usr/lib64/libisc.so.62.0.1                                
             3016.00  1.8% _raw_spin_unlock_irqrestore   /lib/modules/2.6.38-rc5+/build/vmlinux                     
             2202.00  1.3% __do_softirq                  /lib/modules/2.6.38-rc5+/build/vmlinux                     
             2027.00  1.2% _raw_spin_lock                /lib/modules/2.6.38-rc5+/build/vmlinux                     
             1935.00  1.1% finish_task_switch            /lib/modules/2.6.38-rc5+/build/vmlinux                     
             1906.00  1.1% __pthread_mutex_lock_internal /lib64/libpthread-2.12.so                                  
             1837.00  1.1% dns_name_fullcompare          /usr/lib64/libdns.so.69.0.1                                
             1702.00  1.0% dns_rbtnodechain_init         /usr/lib64/libdns.so.69.0.1                                
             1561.00  0.9% fget_light                    /lib/modules/2.6.38-rc5+/build/vmlinux                     
             1559.00  0.9% dns_name_getlabelsequence     /usr/lib64/libdns.so.69.0.1                                
             1491.00  0.9% dns_name_equal                /usr/lib64/libdns.so.69.0.1                                
             1464.00  0.9% __pthread_mutex_unlock        /lib64/libpthread-2.12.so                                  
             1454.00  0.9% dns_acl_match                 /usr/lib64/libdns.so.69.0.1                                
             1293.00  0.8% dns_zone_attach               /usr/lib64/libdns.so.69.0.1                                
             1245.00  0.7% be_xmit                       /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
             1159.00  0.7% dns_message_rendersection     /usr/lib64/libdns.so.69.0.1                                
             1115.00  0.7% isc___mempool_get             /usr/lib64/libisc.so.62.0.1                                
             1100.00  0.6% copy_user_generic_string      /lib/modules/2.6.38-rc5+/build/vmlinux                     
             1030.00  0.6% dns_name_fromwire             /usr/lib64/libdns.so.69.0.1                                
             1015.00  0.6% dns_name_hash                 /usr/lib64/libdns.so.69.0.1                                
             1013.00  0.6% isc_radix_search              /usr/lib64/libisc.so.62.0.1                                
              970.00  0.6% __ip_route_output_key         /lib/modules/2.6.38-rc5+/build/vmlinux                     
              917.00  0.5% fput                          /lib/modules/2.6.38-rc5+/build/vmlinux                     
              817.00  0.5% dev_queue_xmit                /lib/modules/2.6.38-rc5+/build/vmlinux                     
              812.00  0.5% sk_run_filter                 /lib/modules/2.6.38-rc5+/build/vmlinux                     
              806.00  0.5% avc_has_perm_noaudit          /lib/modules/2.6.38-rc5+/build/vmlinux                     
              802.00  0.5% sock_wfree                    /lib/modules/2.6.38-rc5+/build/vmlinux                     
              793.00  0.5% dns_name_towire               /usr/lib64/libdns.so.69.0.1                                
              754.00  0.4% sock_alloc_send_pskb          /lib/modules/2.6.38-rc5+/build/vmlinux                     
              752.00  0.4% dns_message_parse             /usr/lib64/libdns.so.69.0.1                                
              749.00  0.4% dns_rdata_towire              /usr/lib64/libdns.so.69.0.1                                
              728.00  0.4% dns_rdataset_init             /usr/lib64/libdns.so.69.0.1                                
              709.00  0.4% isc___mempool_put             /usr/lib64/libisc.so.62.0.1                                
              699.00  0.4% skb_release_head_state        /lib/modules/2.6.38-rc5+/build/vmlinux                     
              685.00  0.4% _raw_spin_lock_bh             /lib/modules/2.6.38-rc5+/build/vmlinux                     
              683.00  0.4% dns_name_concatenate          /usr/lib64/libdns.so.69.0.1                                
              678.00  0.4% __ip_append_data              /lib/modules/2.6.38-rc5+/build/vmlinux                     
              673.00  0.4% tick_nohz_stop_sched_tick     /lib/modules/2.6.38-rc5+/build/vmlinux                     
              662.00  0.4% sys_sendmsg                   /lib/modules/2.6.38-rc5+/build/vmlinux                     
              654.00  0.4% dns_compress_findglobal       /usr/lib64/libdns.so.69.0.1                                
              654.00  0.4% memcpy                        /lib64/libc-2.12.so                                        
              637.00  0.4% dns_compress_invalidate       /usr/lib64/libdns.so.69.0.1                                
              597.00  0.3% isc__buffer_init              /usr/lib64/libisc.so.62.0.1                                
              595.00  0.3% dns_zone_detach               /usr/lib64/libdns.so.69.0.1                                
WARNING: failed to keep up with mmap data.
WARNING: failed to keep up with mmap data.


----------------------------------------------------------------------------------------------------------------------
   PerfTop:   29539 irqs/sec  kernel:47.0%  exact:  0.0% [1000Hz cpu-clock-msecs],  (all, CPU: 11)
----------------------------------------------------------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ ___________________________________________________________

            14478.00  7.5% intel_idle                    /lib/modules/2.6.38-rc5+/build/vmlinux                     
            12279.00  6.3% isc_rwlock_lock               /usr/lib64/libisc.so.62.0.1                                
             9844.00  5.1% be_tx_compl_process           /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
             7368.00  3.8% kfree                         /lib/modules/2.6.38-rc5+/build/vmlinux                     
             6696.00  3.5% skb_release_data              /lib/modules/2.6.38-rc5+/build/vmlinux                     
             6240.00  3.2% kmem_cache_free               /lib/modules/2.6.38-rc5+/build/vmlinux                     
             6034.00  3.1% isc_rwlock_unlock             /usr/lib64/libisc.so.62.0.1                                
             5547.00  2.9% dns_rbt_findnode              /usr/lib64/libdns.so.69.0.1                                
             5012.00  2.6% kfree_skb                     /lib/modules/2.6.38-rc5+/build/vmlinux                     
             4290.00  2.2% be_poll_tx_mcc                /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
             4024.00  2.1% isc_stats_increment           /usr/lib64/libisc.so.62.0.1                                
             3417.00  1.8% _raw_spin_unlock_irqrestore   /lib/modules/2.6.38-rc5+/build/vmlinux                     
             2470.00  1.3% __do_softirq                  /lib/modules/2.6.38-rc5+/build/vmlinux                     
             2312.00  1.2% _raw_spin_lock                /lib/modules/2.6.38-rc5+/build/vmlinux                     
             2138.00  1.1% finish_task_switch            /lib/modules/2.6.38-rc5+/build/vmlinux                     
             2136.00  1.1% __pthread_mutex_lock_internal /lib64/libpthread-2.12.so                                  
             2061.00  1.1% dns_name_fullcompare          /usr/lib64/libdns.so.69.0.1                                
             1961.00  1.0% dns_rbtnodechain_init         /usr/lib64/libdns.so.69.0.1                                
             1797.00  0.9% dns_name_getlabelsequence     /usr/lib64/libdns.so.69.0.1                                
             1743.00  0.9% fget_light                    /lib/modules/2.6.38-rc5+/build/vmlinux                     
             1723.00  0.9% dns_name_equal                /usr/lib64/libdns.so.69.0.1                                
             1673.00  0.9% __pthread_mutex_unlock        /lib64/libpthread-2.12.so                                  
             1671.00  0.9% dns_acl_match                 /usr/lib64/libdns.so.69.0.1                                
             1488.00  0.8% dns_zone_attach               /usr/lib64/libdns.so.69.0.1                                
             1428.00  0.7% be_xmit                       /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
             1369.00  0.7% dns_message_rendersection     /usr/lib64/libdns.so.69.0.1                                
             1278.00  0.7% isc___mempool_get             /usr/lib64/libisc.so.62.0.1                                
             1251.00  0.6% copy_user_generic_string      /lib/modules/2.6.38-rc5+/build/vmlinux                     
             1193.00  0.6% dns_name_fromwire             /usr/lib64/libdns.so.69.0.1                                
             1182.00  0.6% isc_radix_search              /usr/lib64/libisc.so.62.0.1                        
