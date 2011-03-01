From: Thomas Graf <tgraf@infradead.org>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 1 Mar 2011 06:27:59 -0500
Message-ID: <20110301112759.GK9763@canuck.infradead.org>
References: <20110227110614.GA6246@gondor.apana.org.au>
 <20110228113659.GA20726@gondor.apana.org.au>
 <20110228141322.GF9763@canuck.infradead.org>
 <1298910174.2941.585.camel@edumazet-laptop>
 <20110228163742.GH9763@canuck.infradead.org>
 <1298912869.2941.687.camel@edumazet-laptop>
 <20110301101955.GI9763@canuck.infradead.org>
 <1298975602.3284.13.camel@edumazet-laptop>
 <20110301110708.GJ9763@canuck.infradead.org>
 <1298977984.3284.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:42447 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755822Ab1CAL2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 06:28:09 -0500
Content-Disposition: inline
In-Reply-To: <1298977984.3284.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 12:13:04PM +0100, Eric Dumazet wrote:
> Its a bit strange two cpus spend time in softirq, unless you have two
> queryperf sources, and a multiqueue NIC, or maybe you use two NICS ?

one NIC, 2 clients (12 instances per client)

[root@hp-bl460cg7-01 ~]# cat /sys/class/net/eth0/queues/rx-0/rps_cpus 
00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000

[root@hp-bl460cg7-01 ~]# netstat -s | grep err
    1781377 packet receive errors

> Mind use "perf top -C 1" and "perf top -C 11" to check what these cpus
> do ?

--------------------------------------------------------------------------------------------------------------------
   PerfTop:   16198 irqs/sec  kernel:99.1%  exact:  0.0% [1000Hz cpu-clock-msecs],  (all, CPU: 1)
--------------------------------------------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ___________________________________________________________

            51675.00 33.2% _raw_spin_unlock_irqrestore [kernel.kallsyms]                                          
            12426.00  8.0% clflush_cache_range         [kernel.kallsyms]                                          
             5511.00  3.5% be_poll_rx                  /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
             4567.00  2.9% __udp4_lib_lookup           [kernel.kallsyms]                                          
             3981.00  2.6% __kmalloc_node_track_caller [kernel.kallsyms]                                          
             3975.00  2.6% get_rx_page_info            /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
             3725.00  2.4% sk_run_filter               [kernel.kallsyms]                                          
             3606.00  2.3% get_page_from_freelist      [kernel.kallsyms]                                          
             3178.00  2.0% __domain_mapping            [kernel.kallsyms]                                          
             3122.00  2.0% kmem_cache_alloc_node       [kernel.kallsyms]                                          
             2839.00  1.8% sock_queue_rcv_skb          [kernel.kallsyms]                                          
             2246.00  1.4% __netif_receive_skb         [kernel.kallsyms]                                          
             2245.00  1.4% nf_iterate                  [kernel.kallsyms]                                          
             2081.00  1.3% __udp4_lib_rcv              [kernel.kallsyms]                                          
             2042.00  1.3% ipt_do_table                [kernel.kallsyms]                                          
             1901.00  1.2% _raw_spin_lock              [kernel.kallsyms]                                          
             1856.00  1.2% __alloc_skb                 [kernel.kallsyms]                                          
             1645.00  1.1% read_tsc                    [kernel.kallsyms]                                          
             1562.00  1.0% nf_ct_tuple_equal           [kernel.kallsyms]                                          
             1562.00  1.0% ip_rcv                      [kernel.kallsyms]                                          
             1495.00  1.0% __nf_conntrack_find_get     [kernel.kallsyms]                                          
             1477.00  0.9% sock_def_readable           [kernel.kallsyms]                                          
             1363.00  0.9% find_first_bit              [kernel.kallsyms]                                          
             1360.00  0.9% domain_get_iommu            [kernel.kallsyms]                                          
             1255.00  0.8% udp_queue_rcv_skb           [kernel.kallsyms]                                          
             1174.00  0.8% xfrm4_policy_check.clone.0  [kernel.kallsyms]                                          
             1138.00  0.7% hash_conntrack_raw          [kernel.kallsyms]                                          
             1000.00  0.6% intel_unmap_page            [kernel.kallsyms]                                          
              959.00  0.6% load_pointer                [kernel.kallsyms]                                          
              957.00  0.6% sock_flag                   [kernel.kallsyms]                                          
              938.00  0.6% nf_conntrack_in             [kernel.kallsyms]                                          
              891.00  0.6% _local_bh_enable_ip         [kernel.kallsyms]                                          
              884.00  0.6% eth_type_trans              [kernel.kallsyms]                                          
              832.00  0.5% be_post_rx_frags            /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
              829.00  0.5% __alloc_pages_nodemask      [kernel.kallsyms]                                          
              813.00  0.5% kmem_cache_alloc            [kernel.kallsyms]                                          
              802.00  0.5% netif_receive_skb           [kernel.kallsyms]                                          
              802.00  0.5% ip_route_input_common       [kernel.kallsyms]                                          
              723.00  0.5% nf_ct_get_tuple             [kernel.kallsyms]                                          
              720.00  0.5% __intel_map_single          [kernel.kallsyms]                                          
              720.00  0.5% udp_error                   [kernel.kallsyms]                                          

--------------------------------------------------------------------------------------------------------------------
   PerfTop:   16360 irqs/sec  kernel:72.6%  exact:  0.0% [1000Hz cpu-clock-msecs],  (all, CPU: 11)
--------------------------------------------------------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ ___________________________________________________________

            16993.00 32.4% _raw_spin_unlock_irqrestore   [kernel.kallsyms]                                          
             5833.00 11.1% clflush_cache_range           [kernel.kallsyms]                                          
             3315.00  6.3% be_tx_compl_process           /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
             1818.00  3.5% kmem_cache_free               [kernel.kallsyms]                                          
             1415.00  2.7% isc_rwlock_lock               /usr/lib64/libisc.so.62.0.1                                
             1090.00  2.1% be_poll_tx_mcc                /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
              811.00  1.5% skb_release_head_state        [kernel.kallsyms]                                          
              772.00  1.5% skb_release_data              [kernel.kallsyms]                                          
              712.00  1.4% dns_rbt_findnode              /usr/lib64/libdns.so.69.0.1                                
              703.00  1.3% isc_rwlock_unlock             /usr/lib64/libisc.so.62.0.1                                
              695.00  1.3% dma_pte_clear_range           [kernel.kallsyms]                                          
              618.00  1.2% kfree_skb                     [kernel.kallsyms]                                          
              597.00  1.1% kfree                         [kernel.kallsyms]                                          
              553.00  1.1% intel_unmap_page              [kernel.kallsyms]                                          
              531.00  1.0% __do_softirq                  [kernel.kallsyms]                                          
              504.00  1.0% isc_stats_increment           /usr/lib64/libisc.so.62.0.1                                
              397.00  0.8% virt_to_head_page             [kernel.kallsyms]                                          
              306.00  0.6% _raw_spin_lock                [kernel.kallsyms]                                          
              270.00  0.5% domain_get_iommu              [kernel.kallsyms]                                          
              256.00  0.5% dns_name_fullcompare          /usr/lib64/libdns.so.69.0.1                                
              233.00  0.4% find_first_bit                [kernel.kallsyms]                                          
              222.00  0.4% dns_name_equal                /usr/lib64/libdns.so.69.0.1                                
              218.00  0.4% __pthread_mutex_lock_internal /lib64/libpthread-2.12.so                                  
              207.00  0.4% dns_rbtnodechain_init         /usr/lib64/libdns.so.69.0.1                                
              196.00  0.4% dns_acl_match                 /usr/lib64/libdns.so.69.0.1                                
              194.00  0.4% dma_pte_free_pagetable        [kernel.kallsyms]                                          
              192.00  0.4% dns_name_getlabelsequence     /usr/lib64/libdns.so.69.0.1                                

