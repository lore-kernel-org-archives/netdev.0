From: Thomas Graf <tgraf@infradead.org>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 1 Mar 2011 07:01:12 -0500
Message-ID: <20110301120112.GL9763@canuck.infradead.org>
References: <20110228141322.GF9763@canuck.infradead.org>
 <1298910174.2941.585.camel@edumazet-laptop>
 <20110228163742.GH9763@canuck.infradead.org>
 <1298912869.2941.687.camel@edumazet-laptop>
 <20110301101955.GI9763@canuck.infradead.org>
 <1298975602.3284.13.camel@edumazet-laptop>
 <20110301110708.GJ9763@canuck.infradead.org>
 <1298977984.3284.15.camel@edumazet-laptop>
 <20110301112759.GK9763@canuck.infradead.org>
 <1298979909.3284.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:38258 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575Ab1CAMBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 07:01:19 -0500
Content-Disposition: inline
In-Reply-To: <1298979909.3284.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 12:45:09PM +0100, Eric Dumazet wrote:

This is how perf top looks like with SO_REUSEPORT

----------------------------------------------------------------------------------------------------------------------------------
   PerfTop:   27498 irqs/sec  kernel:50.5%  exact:  0.0% [1000Hz cpu-clock-msecs],  (all, CPU: 1)
----------------------------------------------------------------------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ __________________

            16464.00  6.0% isc_rwlock_lock               libisc.so.62.0.1
            15462.00  5.7% intel_idle                    [kernel.kallsyms]
            13140.00  4.8% _spin_unlock_irqrestore       [kernel.kallsyms]
             9283.00  3.4% __do_softirq                  [kernel.kallsyms]
             8469.00  3.1% finish_task_switch            [kernel.kallsyms]
             8189.00  3.0% __udp4_lib_lookup             [kernel.kallsyms]
             8096.00  3.0% dns_rbt_findnode              libdns.so.69.0.1
             7619.00  2.8% isc_rwlock_unlock             libisc.so.62.0.1
             5090.00  1.9% isc_stats_increment           libisc.so.62.0.1
             4325.00  1.6% tick_nohz_stop_sched_tick     [kernel.kallsyms]
             3656.00  1.3% _spin_lock                    [kernel.kallsyms]
             3540.00  1.3% __pthread_mutex_lock_internal libpthread-2.12.so
             3168.00  1.2% _spin_lock_bh                 [kernel.kallsyms]
             2576.00  0.9% dns_name_fullcompare          libdns.so.69.0.1
             2492.00  0.9% __pthread_mutex_unlock        libpthread-2.12.so
             2486.00  0.9% isc___mempool_get             libisc.so.62.0.1
             2475.00  0.9% dns_rbtnodechain_init         libdns.so.69.0.1
             2454.00  0.9% be_poll_rx                    [be2net]
             2417.00  0.9% sk_run_filter                 [kernel.kallsyms]
             2411.00  0.9% tick_nohz_restart_sched_tick  [kernel.kallsyms]
             2331.00  0.9% dns_name_equal                libdns.so.69.0.1
             2198.00  0.8% net_rx_action                 [kernel.kallsyms]
             2135.00  0.8% fget_light                    [kernel.kallsyms]
             2130.00  0.8% dns_zone_attach               libdns.so.69.0.1
             2073.00  0.8% dns_name_getlabelsequence     libdns.so.69.0.1
             2024.00  0.7% copy_user_generic_string      [kernel.kallsyms]
             2003.00  0.7% dns_acl_match                 libdns.so.69.0.1
             1868.00  0.7% be_xmit                       [be2net]

----------------------------------------------------------------------------------------------------------------------------------
   PerfTop:   16206 irqs/sec  kernel:88.6%  exact:  0.0% [1000Hz cpu-clock-msecs],  (all, CPU: 3)
----------------------------------------------------------------------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ __________________

            15662.00 11.3% __udp4_lib_lookup             [kernel.kallsyms]
            10404.00  7.5% intel_idle                    [kernel.kallsyms]
            10248.00  7.4% _spin_unlock_irqrestore       [kernel.kallsyms]
             4386.00  3.2% __do_softirq                  [kernel.kallsyms]
             4324.00  3.1% be_poll_rx                    [be2net]
             4165.00  3.0% get_rx_page_info              [be2net]
             4050.00  2.9% get_page_from_freelist        [kernel.kallsyms]
             4045.00  2.9% finish_task_switch            [kernel.kallsyms]
             3861.00  2.8% sk_run_filter                 [kernel.kallsyms]
             3544.00  2.5% ip_route_input                [kernel.kallsyms]
             3385.00  2.4% _spin_lock                    [kernel.kallsyms]
             2583.00  1.9% get_rps_cpu                   [kernel.kallsyms]
             2042.00  1.5% tick_nohz_stop_sched_tick     [kernel.kallsyms]
             1971.00  1.4% kmem_cache_alloc_node_notrace [kernel.kallsyms]
             1788.00  1.3% _read_lock                    [kernel.kallsyms]
             1777.00  1.3% __netif_receive_skb           [kernel.kallsyms]
             1777.00  1.3% isc_rwlock_lock               libisc.so.62.0.1
             1769.00  1.3% memcpy_c                      [kernel.kallsyms]
             1618.00  1.2% __alloc_skb                   [kernel.kallsyms]
             1591.00  1.1% __pthread_mutex_lock_internal libpthread-2.12.so
             1576.00  1.1% kmem_cache_alloc_node         [kernel.kallsyms]
             1450.00  1.0% sock_queue_rcv_skb            [kernel.kallsyms]
             1427.00  1.0% tick_nohz_restart_sched_tick  [kernel.kallsyms]
             1214.00  0.9% __udp4_lib_rcv                [kernel.kallsyms]
             1124.00  0.8% net_rx_action                 [kernel.kallsyms]
             1113.00  0.8% getnstimeofday                [kernel.kallsyms]
             1072.00  0.8% selinux_socket_sock_rcv_skb   [kernel.kallsyms]
             1016.00  0.7% ip_rcv                        [kernel.kallsyms]
              992.00  0.7% sock_def_readable             [kernel.kallsyms]
              961.00  0.7% dns_rbt_findnode              libdns.so.69.0.1
              899.00  0.6% fget                          [kernel.kallsyms]
              898.00  0.6% datagram_poll                 [kernel.kallsyms]
              809.00  0.6% isc_rwlock_unlock             libisc.so.62.0.1
              803.00  0.6% __alloc_pages_nodemask        [kernel.kallsyms]
              799.00  0.6% udp_queue_rcv_skb             [kernel.kallsyms]
              694.00  0.5% packet_rcv                    [kernel.kallsyms]
              662.00  0.5% mutex_lock                    [kernel.kallsyms]

------------------------------------------------------------------------------------------------------------------------------------------
   PerfTop:   31619 irqs/sec  kernel:37.7%  exact:  0.0% [1000Hz cpu-clock-msecs],  (all, CPU: 10)
-------------------------------------------------------------------------------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ __________________

             6726.00  7.7% isc_rwlock_lock               libisc.so.62.0.1
             4597.00  5.3% _spin_unlock_irqrestore       [kernel.kallsyms]
             4230.00  4.9% intel_idle                    [kernel.kallsyms]
             3319.00  3.8% dns_rbt_findnode              libdns.so.69.0.1
             3178.00  3.7% isc_rwlock_unlock             libisc.so.62.0.1
             2682.00  3.1% finish_task_switch            [kernel.kallsyms]
             2164.00  2.5% isc_stats_increment           libisc.so.62.0.1
             1435.00  1.7% tick_nohz_stop_sched_tick     [kernel.kallsyms]
             1407.00  1.6% _spin_lock_bh                 [kernel.kallsyms]
             1288.00  1.5% __pthread_mutex_lock_internal libpthread-2.12.so
             1264.00  1.5% copy_user_generic_string      [kernel.kallsyms]
             1082.00  1.2% _spin_lock                    [kernel.kallsyms]
             1061.00  1.2% be_xmit                       [be2net]
             1024.00  1.2% __pthread_mutex_unlock        libpthread-2.12.so
             1014.00  1.2% dns_rbtnodechain_init         libdns.so.69.0.1
              989.00  1.1% isc___mempool_get             libisc.so.62.0.1
              964.00  1.1% dns_name_equal                libdns.so.69.0.1
              957.00  1.1% dns_name_getlabelsequence     libdns.so.69.0.1
              944.00  1.1% dns_name_fullcompare          libdns.so.69.0.1
              858.00  1.0% dns_zone_attach               libdns.so.69.0.1
              793.00  0.9% udp_sendmsg                   [kernel.kallsyms]
              785.00  0.9% tick_nohz_restart_sched_tick  [kernel.kallsyms]
              784.00  0.9% dns_acl_match                 libdns.so.69.0.1
              776.00  0.9% fget_light                    [kernel.kallsyms]
              723.00  0.8% dns_name_hash                 libdns.so.69.0.1
              691.00  0.8% dns_message_rendersection     libdns.so.69.0.1
              675.00  0.8% dns_name_fromwire             libdns.so.69.0.1
              658.00  0.8% udp_recvmsg                   [kernel.kallsyms]
              646.00  0.7% kmem_cache_free               [kernel.kallsyms]
              641.00  0.7% kfree                         [kernel.kallsyms]
              535.00  0.6% isc_radix_search              libisc.so.62.0.1
              531.00  0.6% dev_queue_xmit                [kernel.kallsyms]


-------------------------------------------------------------------------------------------------------------------------------------------
   PerfTop:   31136 irqs/sec  kernel:48.3%  exact:  0.0% [1000Hz cpu-clock-msecs],  (all, CPU: 11)
-------------------------------------------------------------------------------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ __________________

            13043.00  6.0% isc_rwlock_lock               libisc.so.62.0.1
            10852.00  5.0% _spin_unlock_irqrestore       [kernel.kallsyms]
            10538.00  4.9% be_tx_compl_process           [be2net]
             8275.00  3.8% kfree                         [kernel.kallsyms]
             6467.00  3.0% kmem_cache_free               [kernel.kallsyms]
             6453.00  3.0% dns_rbt_findnode              libdns.so.69.0.1
             6423.00  3.0% intel_idle                    [kernel.kallsyms]
             6199.00  2.9% isc_rwlock_unlock             libisc.so.62.0.1
             5492.00  2.5% sock_wfree                    [kernel.kallsyms]
             5372.00  2.5% finish_task_switch            [kernel.kallsyms]
             5321.00  2.4% kfree_skb                     [kernel.kallsyms]
             4030.00  1.9% isc_stats_increment           libisc.so.62.0.1
             3820.00  1.8% skb_release_data              [kernel.kallsyms]
             3518.00  1.6% be_poll_tx_mcc                [be2net]
             3034.00  1.4% sock_def_write_space          [kernel.kallsyms]
             2599.00  1.2% __do_softirq                  [kernel.kallsyms]
             2572.00  1.2% tick_nohz_stop_sched_tick     [kernel.kallsyms]
             2519.00  1.2% __pthread_mutex_lock_internal libpthread-2.12.so
             2497.00  1.1% _spin_lock_bh                 [kernel.kallsyms]
             2045.00  0.9% dns_name_fullcompare          libdns.so.69.0.1
             1960.00  0.9% isc___mempool_get             libisc.so.62.0.1
             1873.00  0.9% dns_rbtnodechain_init         libdns.so.69.0.1
             1861.00  0.9% _spin_lock                    [kernel.kallsyms]
             1806.00  0.8% __pthread_mutex_unlock        libpthread-2.12.so
             1791.00  0.8% dns_name_equal                libdns.so.69.0.1
             1757.00  0.8% dns_zone_attach               libdns.so.69.0.1
             1621.00  0.7% dns_name_getlabelsequence     libdns.so.69.0.1
             1576.00  0.7% fget_light                    [kernel.kallsyms]
             1532.00  0.7% dns_acl_match                 libdns.so.69.0.1
             1515.00  0.7% tick_nohz_restart_sched_tick  [kernel.kallsyms]
             1510.00  0.7% be_xmit                       [be2net]

