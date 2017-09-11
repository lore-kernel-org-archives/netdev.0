From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Kernel 4.13.0-rc4-next-20170811 - IP Routing / Forwarding
 performance vs Core/RSS number / HT on
Date: Mon, 11 Sep 2017 18:57:55 +0200
Message-ID: <0123de5c-a7ad-7e62-b7d0-cd19bd34c573@itcare.pl>
References: <3ac1a817-5c62-2490-64e7-2512f0ee3b3e@itcare.pl>
 <20170812142358.08291888@redhat.com>
 <af5b3482-8f26-52b5-4a00-3a5a42b7449f@itcare.pl>
 <ce33b7b3-ae00-b6f0-e82a-6df3d5a5e995@itcare.pl>
 <20170814181957.5be27906@redhat.com> <1502729870.8411.63.camel@redhat.com>
 <80b3bf71-dc6b-7b96-43d6-dbb3c53c5a8b@itcare.pl>
 <1502759225.4936.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <1502759849.4936.46.camel@edumazet-glaptop3.roam.corp.google.com>
 <709ff9f4-39f9-b5e5-206d-b16edd8c7320@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Paolo Abeni <pabeni@redhat.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp16.iq.pl ([86.111.242.222]:51821 "EHLO smtp16.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751894AbdIKRAB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 11 Sep 2017 13:00:01 -0400
In-Reply-To: <709ff9f4-39f9-b5e5-206d-b16edd8c7320@itcare.pl>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested with connectx-5

Without patch

10Mpps - > 16 cores used

    PerfTop:   66258 irqs/sec  kernel:99.3%  exact:  0.0% [4000Hz 
cycles],  (all, 32 CPUs)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 


     10.12%  [kernel]       [k] do_raw_spin_lock
      6.31%  [kernel]       [k] fib_table_lookup
      6.12%  [kernel]       [k] mlx5e_handle_rx_cqe_mpwrq
      4.90%  [kernel]       [k] rt_cache_valid
      3.99%  [kernel]       [k] mlx5e_xmit
      3.03%  [kernel]       [k] ip_rcv
      2.68%  [kernel]       [k] __netif_receive_skb_core
      2.54%  [kernel]       [k] skb_dst_force
      2.41%  [kernel]       [k] ip_finish_output2
      2.21%  [kernel]       [k] __build_skb
      2.03%  [kernel]       [k] __dev_queue_xmit
      1.96%  [kernel]       [k] mlx5e_txwqe_complete
      1.79%  [kernel]       [k] ipt_do_table
      1.78%  [kernel]       [k] inet_gro_receive
      1.69%  [kernel]       [k] ip_forward
      1.66%  [kernel]       [k] udp_v4_early_demux
      1.65%  [kernel]       [k] dst_release
      1.56%  [kernel]       [k] ip_rcv_finish
      1.45%  [kernel]       [k] dev_gro_receive
      1.45%  [kernel]       [k] netif_skb_features
      1.39%  [kernel]       [k] mlx5e_poll_tx_cq
      1.35%  [kernel]       [k] mlx5e_txwqe_build_dsegs
      1.35%  [kernel]       [k] ip_route_input_rcu
      1.15%  [kernel]       [k] dev_hard_start_xmit
      1.12%  [kernel]       [k] napi_gro_receive
      1.07%  [kernel]       [k] netif_receive_skb_internal
      0.98%  [kernel]       [k] sch_direct_xmit
      0.95%  [kernel]       [k] kmem_cache_alloc
      0.89%  [kernel]       [k] read_tsc
      0.88%  [kernel]       [k] mlx5e_build_rx_skb
      0.86%  [kernel]       [k] mlx5_cqwq_get_cqe
      0.82%  [kernel]       [k] page_frag_free
      0.78%  [kernel]       [k] __local_bh_enable_ip
      0.69%  [kernel]       [k] skb_network_protocol
      0.68%  [kernel]       [k] __netif_receive_skb
      0.67%  [kernel]       [k] vlan_dev_hard_start_xmit
      0.65%  [kernel]       [k] mlx5e_poll_rx_cq
      0.65%  [kernel]       [k] validate_xmit_skb
      0.60%  [kernel]       [k] eth_type_trans
      0.60%  [kernel]       [k] deliver_ptype_list_skb
      0.60%  [kernel]       [k] fib_validate_source
      0.55%  [kernel]       [k] eth_header
      0.53%  [kernel]       [k] netdev_pick_tx
      0.53%  [kernel]       [k] __napi_alloc_skb
      0.51%  [kernel]       [k] __udp4_lib_lookup
      0.50%  [kernel]       [k] eth_type_vlan
      0.49%  [kernel]       [k] ip_output
      0.49%  [kernel]       [k] page_frag_alloc
      0.49%  [kernel]       [k] ip_finish_output
      0.48%  [kernel]       [k] neigh_connected_output
      0.45%  [kernel]       [k] nf_hook_slow
      0.44%  [kernel]       [k] udp4_gro_receive
      0.39%  [kernel]       [k] mlx5e_features_check
      0.39%  [kernel]       [k] mlx5e_napi_poll
      0.37%  [kernel]       [k] __jhash_nwords
      0.37%  [kernel]       [k] udp_gro_receive
      0.36%  [kernel]       [k] swiotlb_map_page
      0.33%  [kernel]       [k] mlx5_cqwq_get_wqe
      0.33%  [kernel]       [k] __netdev_pick_tx
      0.29%  [kernel]       [k] ktime_get_with_offset
      0.29%  [kernel]       [k] get_dma_ops
      0.29%  [kernel]       [k] validate_xmit_skb_list
      0.26%  [kernel]       [k] vlan_passthru_hard_header
      0.26%  [kernel]       [k] __udp4_lib_lookup_skb
      0.24%  [kernel]       [k] get_dma_ops
      0.24%  [kernel]       [k] skb_release_data
      0.23%  [kernel]       [k] ip_forward_finish
      0.23%  [kernel]       [k] kmem_cache_free_bulk
      0.23%  [kernel]       [k] timekeeping_get_ns
      0.22%  [kernel]       [k] ip_skb_dst_mtu
      0.21%  [kernel]       [k] compound_head
      0.20%  [kernel]       [k] skb_gro_reset_offset
      0.20%  [kernel]       [k] is_swiotlb_buffer
      0.19%  [kernel]       [k] __net_timestamp.isra.90
      0.19%  [kernel]       [k] dst_metric.constprop.61
      0.18%  [kernel]       [k] skb_orphan_frags.constprop.126
      0.18%  [kernel]       [k] _kfree_skb_defer
      0.18%  [kernel]       [k] irq_entries_start
      0.17%  [kernel]       [k] dev_hard_header.constprop.54
      0.17%  [kernel]       [k] dma_mapping_error
      0.17%  [kernel]       [k] neigh_resolve_output




With patch

12Mpps -> 16 cores

    PerfTop:   66209 irqs/sec  kernel:99.3%  exact:  0.0% [4000Hz 
cycles],  (all, 32 CPUs)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

     10.67%  [kernel]       [k] do_raw_spin_lock
      6.96%  [kernel]       [k] fib_table_lookup
      6.53%  [kernel]       [k] mlx5e_handle_rx_cqe_mpwrq
      4.17%  [kernel]       [k] mlx5e_xmit
      3.22%  [kernel]       [k] ip_rcv
      3.07%  [kernel]       [k] __netif_receive_skb_core
      2.86%  [kernel]       [k] __dev_queue_xmit
      2.36%  [kernel]       [k] __build_skb
      2.33%  [kernel]       [k] ip_forward
      2.05%  [kernel]       [k] mlx5e_txwqe_complete
      2.02%  [kernel]       [k] ip_finish_output2
      2.00%  [kernel]       [k] ipt_do_table
      1.84%  [kernel]       [k] ip_rcv_finish
      1.83%  [kernel]       [k] inet_gro_receive
      1.80%  [kernel]       [k] udp_v4_early_demux
      1.61%  [kernel]       [k] dev_gro_receive
      1.55%  [kernel]       [k] netif_skb_features
      1.52%  [kernel]       [k] mlx5e_txwqe_build_dsegs
      1.47%  [kernel]       [k] mlx5e_poll_tx_cq
      1.39%  [kernel]       [k] ip_route_input_rcu
      1.38%  [kernel]       [k] dev_hard_start_xmit
      1.17%  [kernel]       [k] netif_receive_skb_internal
      1.16%  [kernel]       [k] napi_gro_receive
      1.03%  [kernel]       [k] kmem_cache_alloc
      1.02%  [kernel]       [k] sch_direct_xmit
      0.97%  [kernel]       [k] read_tsc
      0.94%  [kernel]       [k] page_frag_free
      0.91%  [kernel]       [k] mlx5_cqwq_get_cqe
      0.90%  [kernel]       [k] mlx5e_build_rx_skb
      0.89%  [kernel]       [k] skb_network_protocol
      0.83%  [kernel]       [k] __local_bh_enable_ip
      0.79%  [kernel]       [k] validate_xmit_skb
      0.77%  [kernel]       [k] vlan_dev_hard_start_xmit
      0.74%  [kernel]       [k] __netif_receive_skb
      0.72%  [kernel]       [k] mlx5e_poll_rx_cq
      0.70%  [kernel]       [k] netdev_pick_tx
      0.69%  [kernel]       [k] eth_type_vlan
      0.68%  [kernel]       [k] __netdev_pick_tx
      0.66%  [kernel]       [k] nf_hook_slow
      0.65%  [kernel]       [k] deliver_ptype_list_skb
      0.62%  [kernel]       [k] fib_validate_source
      0.61%  [kernel]       [k] eth_header
      0.60%  [kernel]       [k] eth_type_trans
      0.59%  [kernel]       [k] __udp4_lib_lookup
      0.58%  [kernel]       [k] __napi_alloc_skb
      0.53%  [kernel]       [k] ip_finish_output
      0.51%  [kernel]       [k] neigh_connected_output
      0.50%  [kernel]       [k] ip_output
      0.50%  [kernel]       [k] rt_cache_valid
      0.44%  [kernel]       [k] udp4_gro_receive
      0.43%  [kernel]       [k] mlx5e_napi_poll
      0.40%  [kernel]       [k] udp_gro_receive
      0.40%  [kernel]       [k] page_frag_alloc
      0.40%  [kernel]       [k] __jhash_nwords
      0.39%  [kernel]       [k] swiotlb_map_page
      0.38%  [kernel]       [k] mlx5_cqwq_get_wqe
      0.36%  [kernel]       [k] mlx5e_features_check
      0.32%  [kernel]       [k] get_dma_ops
      0.31%  [kernel]       [k] ktime_get_with_offset
      0.31%  [kernel]       [k] validate_xmit_skb_list
      0.28%  [kernel]       [k] vlan_passthru_hard_header
      0.28%  [kernel]       [k] get_dma_ops
      0.27%  [kernel]       [k] __udp4_lib_lookup_skb
      0.26%  [kernel]       [k] skb_gro_reset_offset
      0.25%  [kernel]       [k] skb_release_data
      0.25%  [kernel]       [k] timekeeping_get_ns
      0.24%  [kernel]       [k] kmem_cache_free_bulk
      0.24%  [kernel]       [k] ip_forward_finish
      0.23%  [kernel]       [k] compound_head
      0.23%  [kernel]       [k] ip_skb_dst_mtu
      0.22%  [kernel]       [k] __net_timestamp.isra.90
      0.22%  [kernel]       [k] is_swiotlb_buffer
      0.21%  [kernel]       [k] neigh_resolve_output
      0.21%  [kernel]       [k] dst_metric.constprop.61
      0.20%  [kernel]       [k] skb_orphan_frags.constprop.126
      0.20%  [kernel]       [k] irq_entries_start
      0.19%  [kernel]       [k] mlx5e_calc_min_inline
      0.19%  [kernel]       [k] dev_hard_header.constprop.54
      0.19%  [kernel]       [k] _kfree_skb_defer
      0.18%  [kernel]       [k] _raw_spin_lock
      0.18%  [kernel]       [k] ip_route_input_noref





W dniu 2017-09-09 o 11:03, Paweł Staszewski pisze:
> Hi
>
>
> Are there any plans to have this fix normally in kernel ?
>
> Or it is mostly only hack - not longterm fix and need to be different ?
>
>
> All tests that was done shows that without this patch there is about 
> 20-30% network forwarding performance degradation when using vlan 
> interfaces
>
>
> Thanks
> Paweł
>
>
>
> W dniu 2017-08-15 o 03:17, Eric Dumazet pisze:
>> On Mon, 2017-08-14 at 18:07 -0700, Eric Dumazet wrote:
>>
>>> Or try to hack the IFF_XMIT_DST_RELEASE flag on the vlan netdev.
>> Something like :
>>
>> diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
>> index 
>> 5e831de3103e2f7092c7fa15534def403bc62fb4..9472de846d5c0960996261cb2843032847fa4bf7 
>> 100644
>> --- a/net/8021q/vlan_netlink.c
>> +++ b/net/8021q/vlan_netlink.c
>> @@ -143,6 +143,7 @@ static int vlan_newlink(struct net *src_net, 
>> struct net_device *dev,
>>       vlan->vlan_proto = proto;
>>       vlan->vlan_id     = nla_get_u16(data[IFLA_VLAN_ID]);
>>       vlan->real_dev     = real_dev;
>> +    dev->priv_flags |= (real_dev->priv_flags & IFF_XMIT_DST_RELEASE);
>>       vlan->flags     = VLAN_FLAG_REORDER_HDR;
>>         err = vlan_check_real_dev(real_dev, vlan->vlan_proto, 
>> vlan->vlan_id);
>>
>>
>>
>>
>
>
