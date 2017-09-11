From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Kernel 4.13.0-rc4-next-20170811 - IP Routing / Forwarding
 performance vs Core/RSS number / HT on
Date: Tue, 12 Sep 2017 00:11:21 +0200
Message-ID: <ae79fc09-d7bb-5dda-4df4-324900a10196@itcare.pl>
References: <3ac1a817-5c62-2490-64e7-2512f0ee3b3e@itcare.pl>
 <20170812142358.08291888@redhat.com>
 <af5b3482-8f26-52b5-4a00-3a5a42b7449f@itcare.pl>
 <ce33b7b3-ae00-b6f0-e82a-6df3d5a5e995@itcare.pl>
 <20170814181957.5be27906@redhat.com> <1502729870.8411.63.camel@redhat.com>
 <80b3bf71-dc6b-7b96-43d6-dbb3c53c5a8b@itcare.pl>
 <1502759225.4936.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <1502759849.4936.46.camel@edumazet-glaptop3.roam.corp.google.com>
 <709ff9f4-39f9-b5e5-206d-b16edd8c7320@itcare.pl>
 <0123de5c-a7ad-7e62-b7d0-cd19bd34c573@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Paolo Abeni <pabeni@redhat.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp16.iq.pl ([86.111.242.222]:42278 "EHLO smtp16.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750911AbdIKWN0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 11 Sep 2017 18:13:26 -0400
In-Reply-To: <0123de5c-a7ad-7e62-b7d0-cd19bd34c573@itcare.pl>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another test for this patch with linux-next tree

with patch:

  bwm-ng v0.6.1 (probing every 1.000s), press 'h' for help
   input: /proc/net/dev type: rate
   -         iface                   Rx Tx                Total
==============================================================================
          vlan1004:            1.00 P/s        606842.31 P/s 606843.31 P/s
                lo:            0.00 P/s             0.00 P/s             
0.00 P/s
          vlan1016:            0.00 P/s        607730.56 P/s 607730.56 P/s
          vlan1020:            0.00 P/s        606891.25 P/s 606891.25 P/s
          vlan1018:            0.00 P/s        607580.88 P/s 607580.88 P/s
          vlan1014:            0.00 P/s        607606.81 P/s 607606.81 P/s
          vlan1005:            0.00 P/s        606788.44 P/s 606788.44 P/s
          enp2s0f0:            2.00 P/s             2.00 P/s             
3.99 P/s
          vlan1017:            0.00 P/s        607643.75 P/s 607643.75 P/s
          enp132s0:     13079658.00 P/s             0.00 P/s 13079658.00 P/s
          vlan1000:            0.00 P/s        604409.19 P/s 604409.19 P/s
          vlan1010:            0.00 P/s        606984.06 P/s 606984.06 P/s
          vlan1019:            0.00 P/s        607452.12 P/s 607452.12 P/s
          vlan1008:            0.00 P/s        606803.44 P/s 606803.44 P/s
          vlan1011:            0.00 P/s        607048.94 P/s 607048.94 P/s
          vlan1001:            0.00 P/s        606773.50 P/s 606773.50 P/s
          vlan1006:            0.00 P/s        606811.38 P/s 606811.38 P/s
          vlan1012:            0.00 P/s        607051.94 P/s 607051.94 P/s
          vlan1013:            0.00 P/s        607067.88 P/s 607067.88 P/s
            enp4s0:            2.00 P/s      13020803.00 P/s 13020805.00 P/s
          vlan1007:            0.00 P/s        606798.44 P/s 606798.44 P/s
          vlan1002:            0.00 P/s        606840.31 P/s 606840.31 P/s
          vlan1009:            0.00 P/s        606809.38 P/s 606809.38 P/s
          enp2s0f1:          100.80 P/s             0.00 P/s           
100.80 P/s
          vlan1015:            0.00 P/s        607089.81 P/s 607089.81 P/s
          vlan1003:            1.00 P/s        606928.19 P/s 606929.19 P/s
------------------------------------------------------------------------------
             total:     13079765.00 P/s      25766758.00 P/s 38846524.00 P/s


13Mpps forwarded (32cores active for two mlx5 nics)

80% cpu load (20%idle all cores)


    PerfTop:  126552 irqs/sec  kernel:99.3%  exact:  0.0% [4000Hz 
cycles],  (all, 32 CPUs)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

      8.25%  [kernel]       [k] fib_table_lookup
      7.98%  [kernel]       [k] do_raw_spin_lock
      6.20%  [kernel]       [k] mlx5e_handle_rx_cqe_mpwrq
      4.21%  [kernel]       [k] mlx5e_xmit
      3.37%  [kernel]       [k] __dev_queue_xmit
      2.95%  [kernel]       [k] ip_rcv
      2.72%  [kernel]       [k] ipt_do_table
      2.24%  [kernel]       [k] ip_finish_output2
      2.22%  [kernel]       [k] __netif_receive_skb_core
      2.17%  [kernel]       [k] ip_forward
      2.15%  [kernel]       [k] __build_skb
      1.99%  [kernel]       [k] ip_route_input_rcu
      1.70%  [kernel]       [k] mlx5e_txwqe_complete
      1.54%  [kernel]       [k] dev_gro_receive
      1.45%  [kernel]       [k] mlx5_cqwq_get_cqe
      1.38%  [kernel]       [k] udp_v4_early_demux
      1.35%  [kernel]       [k] netif_skb_features
      1.33%  [kernel]       [k] inet_gro_receive
      1.29%  [kernel]       [k] dev_hard_start_xmit
      1.27%  [kernel]       [k] ip_rcv_finish
      1.19%  [kernel]       [k] mlx5e_build_rx_skb
      1.15%  [kernel]       [k] __netdev_pick_tx
      1.11%  [kernel]       [k] kmem_cache_alloc
      1.09%  [kernel]       [k] mlx5e_poll_tx_cq
      1.07%  [kernel]       [k] mlx5e_txwqe_build_dsegs
      1.00%  [kernel]       [k] vlan_dev_hard_start_xmit
      0.90%  [kernel]       [k] __napi_alloc_skb
      0.87%  [kernel]       [k] validate_xmit_skb
      0.87%  [kernel]       [k] read_tsc
      0.83%  [kernel]       [k] napi_gro_receive
      0.79%  [kernel]       [k] skb_network_protocol
      0.79%  [kernel]       [k] sch_direct_xmit
      0.78%  [kernel]       [k] __local_bh_enable_ip
      0.78%  [kernel]       [k] netdev_pick_tx
      0.75%  [kernel]       [k] __udp4_lib_lookup
      0.72%  [kernel]       [k] netif_receive_skb_internal
      0.71%  [kernel]       [k] page_frag_free
      0.71%  [kernel]       [k] deliver_ptype_list_skb
      0.70%  [kernel]       [k] fib_validate_source
      0.69%  [kernel]       [k] mlx5_cqwq_get_cqe
      0.69%  [kernel]       [k] __netif_receive_skb
      0.68%  [kernel]       [k] vlan_passthru_hard_header
      0.61%  [kernel]       [k] rt_cache_valid
      0.59%  [kernel]       [k] iptable_filter_hook



Without patch:

12,7Mpps forwarded (32cores active for two mlx5 nics)

100% cpu load ( rx drops on receiving side )

TX is about 13.05Mpps from pktgen


  bwm-ng v0.6.1 (probing every 1.000s), press 'h' for help
   input: /proc/net/dev type: rate
   /         iface                   Rx Tx                Total
==============================================================================
          vlan1004:            0.00 P/s        589709.31 P/s 589709.31 P/s
                lo:            0.00 P/s             0.00 P/s             
0.00 P/s
          vlan1016:            0.00 P/s        589495.50 P/s 589495.50 P/s
          vlan1020:            0.00 P/s        589968.06 P/s 589968.06 P/s
          vlan1018:            0.00 P/s        589896.12 P/s 589896.12 P/s
          vlan1014:            0.00 P/s        589496.50 P/s 589496.50 P/s
          vlan1005:            0.00 P/s        589502.50 P/s 589502.50 P/s
          enp2s0f0:           42.96 P/s             2.00 P/s            
44.96 P/s
          vlan1017:            0.00 P/s        589508.50 P/s 589508.50 P/s
          enp132s0:     12700689.00 P/s             0.00 P/s 12700689.00 P/s
          vlan1000:            0.00 P/s        587671.38 P/s 587671.38 P/s
          vlan1010:            0.00 P/s        589330.69 P/s 589330.69 P/s
          vlan1019:            0.00 P/s        589808.19 P/s 589808.19 P/s
          vlan1008:            0.00 P/s        589283.75 P/s 589283.75 P/s
          vlan1011:            0.00 P/s        589482.56 P/s 589482.56 P/s
          vlan1001:            0.00 P/s        589971.06 P/s 589971.06 P/s
          vlan1006:            0.00 P/s        589785.25 P/s 589785.25 P/s
          vlan1012:            0.00 P/s        589494.50 P/s 589494.50 P/s
          vlan1013:            0.00 P/s        589495.50 P/s 589495.50 P/s
            enp4s0:            0.00 P/s      12601841.00 P/s 12601841.00 P/s
          vlan1007:            0.00 P/s        589537.50 P/s 589537.50 P/s
          vlan1002:            0.00 P/s        589943.06 P/s 589943.06 P/s
          vlan1009:            0.00 P/s        589306.69 P/s 589306.69 P/s
          enp2s0f1:           99.90 P/s             0.00 P/s            
99.90 P/s
          vlan1015:            0.00 P/s        589553.44 P/s 589553.44 P/s
          vlan1003:            0.00 P/s        589823.19 P/s 589823.19 P/s
------------------------------------------------------------------------------
             total:     12700832.00 P/s      24981906.00 P/s 37682740.00 P/s



    PerfTop:  124056 irqs/sec  kernel:99.3%  exact:  0.0% [4000Hz 
cycles],  (all, 32 CPUs)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

      7.77%  [kernel]       [k] fib_table_lookup
      7.37%  [kernel]       [k] do_raw_spin_lock
      5.43%  [kernel]       [k] mlx5e_handle_rx_cqe_mpwrq
      3.84%  [kernel]       [k] mlx5e_xmit
      3.52%  [kernel]       [k] rt_cache_valid
      3.46%  [kernel]       [k] ip_finish_output2
      3.45%  [kernel]       [k] skb_dst_force
      2.96%  [kernel]       [k] dst_release
      2.62%  [kernel]       [k] __dev_queue_xmit
      2.54%  [kernel]       [k] ip_rcv
      2.26%  [kernel]       [k] ipt_do_table
      1.97%  [kernel]       [k] __build_skb
      1.94%  [kernel]       [k] __netif_receive_skb_core
      1.94%  [kernel]       [k] ip_route_input_rcu
      1.83%  [kernel]       [k] ip_forward
      1.52%  [kernel]       [k] mlx5e_txwqe_complete
      1.42%  [kernel]       [k] dev_gro_receive
      1.31%  [kernel]       [k] mlx5_cqwq_get_cqe
      1.28%  [kernel]       [k] netif_skb_features
      1.21%  [kernel]       [k] ip_rcv_finish
      1.18%  [kernel]       [k] inet_gro_receive
      1.17%  [kernel]       [k] udp_v4_early_demux
      1.14%  [kernel]       [k] dev_hard_start_xmit
      1.03%  [kernel]       [k] mlx5e_txwqe_build_dsegs
      1.02%  [kernel]       [k] mlx5e_poll_tx_cq
      1.02%  [kernel]       [k] mlx5e_build_rx_skb
      1.00%  [kernel]       [k] kmem_cache_alloc
      0.95%  [kernel]       [k] __netdev_pick_tx
      0.93%  [kernel]       [k] vlan_dev_hard_start_xmit
      0.82%  [kernel]       [k] __napi_alloc_skb
      0.79%  [kernel]       [k] read_tsc
      0.76%  [kernel]       [k] validate_xmit_skb
      0.75%  [kernel]       [k] napi_gro_receive
      0.71%  [kernel]       [k] __local_bh_enable_ip
      0.70%  [kernel]       [k] sch_direct_xmit
      0.67%  [kernel]       [k] page_frag_free
      0.66%  [kernel]       [k] skb_network_protocol
      0.66%  [kernel]       [k] nf_hook_slow
      0.63%  [kernel]       [k] netif_receive_skb_internal
      0.62%  [kernel]       [k] vlan_passthru_hard_header
      0.62%  [kernel]       [k] deliver_ptype_list_skb
      0.62%  [kernel]       [k] __netif_receive_skb
      0.61%  [kernel]       [k] fib_validate_source
      0.61%  [kernel]       [k] mlx5_cqwq_get_cqe
      0.55%  [kernel]       [k] eth_type_trans
      0.55%  [kernel]       [k] iptable_filter_hook
      0.53%  [kernel]       [k] __udp4_lib_lookup
      0.53%  [kernel]       [k] udp_gro_receive
      0.51%  [kernel]       [k] eth_header
      0.49%  [kernel]       [k] fib_lookup.constprop.49
      0.48%  [kernel]       [k] ip_output
      0.44%  [kernel]       [k] netdev_pick_tx
      0.43%  [kernel]       [k] validate_xmit_skb_list
      0.42%  [kernel]       [k] swiotlb_map_page
      0.41%  [kernel]       [k] dma_sync_single_for_cpu.constprop.36
      0.41%  [kernel]       [k] mlx5_cqwq_get_wqe
      0.39%  [kernel]       [k] eth_type_vlan
      0.38%  [kernel]       [k] udp4_gro_receive
      0.37%  [kernel]       [k] __jhash_nwords
      0.37%  [kernel]       [k] ip_forward_finish
      0.33%  [kernel]       [k] ip_finish_output
      0.33%  [kernel]       [k] neigh_connected_output
      0.31%  [kernel]       [k] mlx5e_features_check
      0.29%  [kernel]       [k] ktime_get_with_offset
      0.27%  [kernel]       [k] __udp4_lib_lookup_skb
      0.27%  [kernel]       [k] napi_consume_skb
      0.26%  [kernel]       [k] page_frag_alloc
      0.26%  [kernel]       [k] get_dma_ops
      0.25%  [kernel]       [k] udp4_portaddr_hash.isra.29
      0.24%  [kernel]       [k] skb_dst_drop.isra.76
      0.24%  [kernel]       [k] neigh_resolve_output
      0.24%  [kernel]       [k] skb_release_data
      0.22%  [kernel]       [k] kmem_cache_free_bulk
      0.22%  [kernel]       [k] get_dma_ops
      0.22%  [kernel]       [k] _kfree_skb_defer
      0.21%  [kernel]       [k] ip_skb_dst_mtu
      0.21%  [kernel]       [k] is_swiotlb_buffer
      0.21%  [kernel]       [k] find_exception
      0.21%  [kernel]       [k] compound_head
      0.21%  [kernel]       [k] __net_timestamp.isra.89


W dniu 2017-09-11 o 18:57, Paweł Staszewski pisze:
> Tested with connectx-5
>
> Without patch
>
> 10Mpps - > 16 cores used
>
>    PerfTop:   66258 irqs/sec  kernel:99.3%  exact:  0.0% [4000Hz 
> cycles],  (all, 32 CPUs)
> --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
>
>
>     10.12%  [kernel]       [k] do_raw_spin_lock
>      6.31%  [kernel]       [k] fib_table_lookup
>      6.12%  [kernel]       [k] mlx5e_handle_rx_cqe_mpwrq
>      4.90%  [kernel]       [k] rt_cache_valid
>      3.99%  [kernel]       [k] mlx5e_xmit
>      3.03%  [kernel]       [k] ip_rcv
>      2.68%  [kernel]       [k] __netif_receive_skb_core
>      2.54%  [kernel]       [k] skb_dst_force
>      2.41%  [kernel]       [k] ip_finish_output2
>      2.21%  [kernel]       [k] __build_skb
>      2.03%  [kernel]       [k] __dev_queue_xmit
>      1.96%  [kernel]       [k] mlx5e_txwqe_complete
>      1.79%  [kernel]       [k] ipt_do_table
>      1.78%  [kernel]       [k] inet_gro_receive
>      1.69%  [kernel]       [k] ip_forward
>      1.66%  [kernel]       [k] udp_v4_early_demux
>      1.65%  [kernel]       [k] dst_release
>      1.56%  [kernel]       [k] ip_rcv_finish
>      1.45%  [kernel]       [k] dev_gro_receive
>      1.45%  [kernel]       [k] netif_skb_features
>      1.39%  [kernel]       [k] mlx5e_poll_tx_cq
>      1.35%  [kernel]       [k] mlx5e_txwqe_build_dsegs
>      1.35%  [kernel]       [k] ip_route_input_rcu
>      1.15%  [kernel]       [k] dev_hard_start_xmit
>      1.12%  [kernel]       [k] napi_gro_receive
>      1.07%  [kernel]       [k] netif_receive_skb_internal
>      0.98%  [kernel]       [k] sch_direct_xmit
>      0.95%  [kernel]       [k] kmem_cache_alloc
>      0.89%  [kernel]       [k] read_tsc
>      0.88%  [kernel]       [k] mlx5e_build_rx_skb
>      0.86%  [kernel]       [k] mlx5_cqwq_get_cqe
>      0.82%  [kernel]       [k] page_frag_free
>      0.78%  [kernel]       [k] __local_bh_enable_ip
>      0.69%  [kernel]       [k] skb_network_protocol
>      0.68%  [kernel]       [k] __netif_receive_skb
>      0.67%  [kernel]       [k] vlan_dev_hard_start_xmit
>      0.65%  [kernel]       [k] mlx5e_poll_rx_cq
>      0.65%  [kernel]       [k] validate_xmit_skb
>      0.60%  [kernel]       [k] eth_type_trans
>      0.60%  [kernel]       [k] deliver_ptype_list_skb
>      0.60%  [kernel]       [k] fib_validate_source
>      0.55%  [kernel]       [k] eth_header
>      0.53%  [kernel]       [k] netdev_pick_tx
>      0.53%  [kernel]       [k] __napi_alloc_skb
>      0.51%  [kernel]       [k] __udp4_lib_lookup
>      0.50%  [kernel]       [k] eth_type_vlan
>      0.49%  [kernel]       [k] ip_output
>      0.49%  [kernel]       [k] page_frag_alloc
>      0.49%  [kernel]       [k] ip_finish_output
>      0.48%  [kernel]       [k] neigh_connected_output
>      0.45%  [kernel]       [k] nf_hook_slow
>      0.44%  [kernel]       [k] udp4_gro_receive
>      0.39%  [kernel]       [k] mlx5e_features_check
>      0.39%  [kernel]       [k] mlx5e_napi_poll
>      0.37%  [kernel]       [k] __jhash_nwords
>      0.37%  [kernel]       [k] udp_gro_receive
>      0.36%  [kernel]       [k] swiotlb_map_page
>      0.33%  [kernel]       [k] mlx5_cqwq_get_wqe
>      0.33%  [kernel]       [k] __netdev_pick_tx
>      0.29%  [kernel]       [k] ktime_get_with_offset
>      0.29%  [kernel]       [k] get_dma_ops
>      0.29%  [kernel]       [k] validate_xmit_skb_list
>      0.26%  [kernel]       [k] vlan_passthru_hard_header
>      0.26%  [kernel]       [k] __udp4_lib_lookup_skb
>      0.24%  [kernel]       [k] get_dma_ops
>      0.24%  [kernel]       [k] skb_release_data
>      0.23%  [kernel]       [k] ip_forward_finish
>      0.23%  [kernel]       [k] kmem_cache_free_bulk
>      0.23%  [kernel]       [k] timekeeping_get_ns
>      0.22%  [kernel]       [k] ip_skb_dst_mtu
>      0.21%  [kernel]       [k] compound_head
>      0.20%  [kernel]       [k] skb_gro_reset_offset
>      0.20%  [kernel]       [k] is_swiotlb_buffer
>      0.19%  [kernel]       [k] __net_timestamp.isra.90
>      0.19%  [kernel]       [k] dst_metric.constprop.61
>      0.18%  [kernel]       [k] skb_orphan_frags.constprop.126
>      0.18%  [kernel]       [k] _kfree_skb_defer
>      0.18%  [kernel]       [k] irq_entries_start
>      0.17%  [kernel]       [k] dev_hard_header.constprop.54
>      0.17%  [kernel]       [k] dma_mapping_error
>      0.17%  [kernel]       [k] neigh_resolve_output
>
>
>
>
> With patch
>
> 12Mpps -> 16 cores
>
>    PerfTop:   66209 irqs/sec  kernel:99.3%  exact:  0.0% [4000Hz 
> cycles],  (all, 32 CPUs)
> --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
>
>
>     10.67%  [kernel]       [k] do_raw_spin_lock
>      6.96%  [kernel]       [k] fib_table_lookup
>      6.53%  [kernel]       [k] mlx5e_handle_rx_cqe_mpwrq
>      4.17%  [kernel]       [k] mlx5e_xmit
>      3.22%  [kernel]       [k] ip_rcv
>      3.07%  [kernel]       [k] __netif_receive_skb_core
>      2.86%  [kernel]       [k] __dev_queue_xmit
>      2.36%  [kernel]       [k] __build_skb
>      2.33%  [kernel]       [k] ip_forward
>      2.05%  [kernel]       [k] mlx5e_txwqe_complete
>      2.02%  [kernel]       [k] ip_finish_output2
>      2.00%  [kernel]       [k] ipt_do_table
>      1.84%  [kernel]       [k] ip_rcv_finish
>      1.83%  [kernel]       [k] inet_gro_receive
>      1.80%  [kernel]       [k] udp_v4_early_demux
>      1.61%  [kernel]       [k] dev_gro_receive
>      1.55%  [kernel]       [k] netif_skb_features
>      1.52%  [kernel]       [k] mlx5e_txwqe_build_dsegs
>      1.47%  [kernel]       [k] mlx5e_poll_tx_cq
>      1.39%  [kernel]       [k] ip_route_input_rcu
>      1.38%  [kernel]       [k] dev_hard_start_xmit
>      1.17%  [kernel]       [k] netif_receive_skb_internal
>      1.16%  [kernel]       [k] napi_gro_receive
>      1.03%  [kernel]       [k] kmem_cache_alloc
>      1.02%  [kernel]       [k] sch_direct_xmit
>      0.97%  [kernel]       [k] read_tsc
>      0.94%  [kernel]       [k] page_frag_free
>      0.91%  [kernel]       [k] mlx5_cqwq_get_cqe
>      0.90%  [kernel]       [k] mlx5e_build_rx_skb
>      0.89%  [kernel]       [k] skb_network_protocol
>      0.83%  [kernel]       [k] __local_bh_enable_ip
>      0.79%  [kernel]       [k] validate_xmit_skb
>      0.77%  [kernel]       [k] vlan_dev_hard_start_xmit
>      0.74%  [kernel]       [k] __netif_receive_skb
>      0.72%  [kernel]       [k] mlx5e_poll_rx_cq
>      0.70%  [kernel]       [k] netdev_pick_tx
>      0.69%  [kernel]       [k] eth_type_vlan
>      0.68%  [kernel]       [k] __netdev_pick_tx
>      0.66%  [kernel]       [k] nf_hook_slow
>      0.65%  [kernel]       [k] deliver_ptype_list_skb
>      0.62%  [kernel]       [k] fib_validate_source
>      0.61%  [kernel]       [k] eth_header
>      0.60%  [kernel]       [k] eth_type_trans
>      0.59%  [kernel]       [k] __udp4_lib_lookup
>      0.58%  [kernel]       [k] __napi_alloc_skb
>      0.53%  [kernel]       [k] ip_finish_output
>      0.51%  [kernel]       [k] neigh_connected_output
>      0.50%  [kernel]       [k] ip_output
>      0.50%  [kernel]       [k] rt_cache_valid
>      0.44%  [kernel]       [k] udp4_gro_receive
>      0.43%  [kernel]       [k] mlx5e_napi_poll
>      0.40%  [kernel]       [k] udp_gro_receive
>      0.40%  [kernel]       [k] page_frag_alloc
>      0.40%  [kernel]       [k] __jhash_nwords
>      0.39%  [kernel]       [k] swiotlb_map_page
>      0.38%  [kernel]       [k] mlx5_cqwq_get_wqe
>      0.36%  [kernel]       [k] mlx5e_features_check
>      0.32%  [kernel]       [k] get_dma_ops
>      0.31%  [kernel]       [k] ktime_get_with_offset
>      0.31%  [kernel]       [k] validate_xmit_skb_list
>      0.28%  [kernel]       [k] vlan_passthru_hard_header
>      0.28%  [kernel]       [k] get_dma_ops
>      0.27%  [kernel]       [k] __udp4_lib_lookup_skb
>      0.26%  [kernel]       [k] skb_gro_reset_offset
>      0.25%  [kernel]       [k] skb_release_data
>      0.25%  [kernel]       [k] timekeeping_get_ns
>      0.24%  [kernel]       [k] kmem_cache_free_bulk
>      0.24%  [kernel]       [k] ip_forward_finish
>      0.23%  [kernel]       [k] compound_head
>      0.23%  [kernel]       [k] ip_skb_dst_mtu
>      0.22%  [kernel]       [k] __net_timestamp.isra.90
>      0.22%  [kernel]       [k] is_swiotlb_buffer
>      0.21%  [kernel]       [k] neigh_resolve_output
>      0.21%  [kernel]       [k] dst_metric.constprop.61
>      0.20%  [kernel]       [k] skb_orphan_frags.constprop.126
>      0.20%  [kernel]       [k] irq_entries_start
>      0.19%  [kernel]       [k] mlx5e_calc_min_inline
>      0.19%  [kernel]       [k] dev_hard_header.constprop.54
>      0.19%  [kernel]       [k] _kfree_skb_defer
>      0.18%  [kernel]       [k] _raw_spin_lock
>      0.18%  [kernel]       [k] ip_route_input_noref
>
>
>
>
>
> W dniu 2017-09-09 o 11:03, Paweł Staszewski pisze:
>> Hi
>>
>>
>> Are there any plans to have this fix normally in kernel ?
>>
>> Or it is mostly only hack - not longterm fix and need to be different ?
>>
>>
>> All tests that was done shows that without this patch there is about 
>> 20-30% network forwarding performance degradation when using vlan 
>> interfaces
>>
>>
>> Thanks
>> Paweł
>>
>>
>>
>> W dniu 2017-08-15 o 03:17, Eric Dumazet pisze:
>>> On Mon, 2017-08-14 at 18:07 -0700, Eric Dumazet wrote:
>>>
>>>> Or try to hack the IFF_XMIT_DST_RELEASE flag on the vlan netdev.
>>> Something like :
>>>
>>> diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
>>> index 
>>> 5e831de3103e2f7092c7fa15534def403bc62fb4..9472de846d5c0960996261cb2843032847fa4bf7 
>>> 100644
>>> --- a/net/8021q/vlan_netlink.c
>>> +++ b/net/8021q/vlan_netlink.c
>>> @@ -143,6 +143,7 @@ static int vlan_newlink(struct net *src_net, 
>>> struct net_device *dev,
>>>       vlan->vlan_proto = proto;
>>>       vlan->vlan_id     = nla_get_u16(data[IFLA_VLAN_ID]);
>>>       vlan->real_dev     = real_dev;
>>> +    dev->priv_flags |= (real_dev->priv_flags & IFF_XMIT_DST_RELEASE);
>>>       vlan->flags     = VLAN_FLAG_REORDER_HDR;
>>>         err = vlan_check_real_dev(real_dev, vlan->vlan_proto, 
>>> vlan->vlan_id);
>>>
>>>
>>>
>>>
>>
>>
>
>
