From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Kernel 4.13.0-rc4-next-20170811 - IP Routing / Forwarding
 performance vs Core/RSS number / HT on
Date: Tue, 15 Aug 2017 11:19:06 +0200
Message-ID: <149379ac-1eb0-12e4-81ee-467876e3a8e6@itcare.pl>
References: <3ac1a817-5c62-2490-64e7-2512f0ee3b3e@itcare.pl>
 <20170812142358.08291888@redhat.com>
 <af5b3482-8f26-52b5-4a00-3a5a42b7449f@itcare.pl>
 <ce33b7b3-ae00-b6f0-e82a-6df3d5a5e995@itcare.pl>
 <20170814181957.5be27906@redhat.com> <1502729870.8411.63.camel@redhat.com>
 <80b3bf71-dc6b-7b96-43d6-dbb3c53c5a8b@itcare.pl>
 <1502759225.4936.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <1502759849.4936.46.camel@edumazet-glaptop3.roam.corp.google.com>
 <4b1efff7-4f91-fd78-beb8-2c7ebcf18895@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Paolo Abeni <pabeni@redhat.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.iq.pl ([86.111.242.224]:37876 "EHLO smtp19.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751807AbdHOJUO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 05:20:14 -0400
In-Reply-To: <4b1efff7-4f91-fd78-beb8-2c7ebcf18895@itcare.pl>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With hack:

     14.44%  [kernel]       [k] do_raw_spin_lock
      8.30%  [kernel]       [k] page_frag_free
      7.06%  [mlx5_core]    [k] mlx5e_xmit
      5.97%  [kernel]       [k] acpi_processor_ffh_cstate_enter
      5.73%  [kernel]       [k] fib_table_lookup
      4.81%  [mlx5_core]    [k] mlx5e_poll_tx_cq
      4.51%  [mlx5_core]    [k] skb_from_cqe.isra.32
      3.81%  [kernel]       [k] virt_to_head_page
      2.45%  [kernel]       [k] __dev_queue_xmit
      1.84%  [kernel]       [k] ipt_do_table
      1.77%  [kernel]       [k] napi_consume_skb
      1.62%  [kernel]       [k] __build_skb
      1.46%  [kernel]       [k] netif_skb_features
      1.43%  [kernel]       [k] __netif_receive_skb_core
      1.41%  [kernel]       [k] ip_rcv
      1.08%  [kernel]       [k] dev_hard_start_xmit
      1.02%  [kernel]       [k] build_skb
      1.00%  [mlx5_core]    [k] mlx5_cqwq_get_cqe
      0.96%  [kernel]       [k] ip_route_input_rcu
      0.95%  [kernel]       [k] ip_forward
      0.89%  [kernel]       [k] ip_finish_output2
      0.89%  [kernel]       [k] kmem_cache_alloc
      0.78%  [kernel]       [k] __local_bh_enable_ip
      0.76%  [kernel]       [k] udp_v4_early_demux
      0.75%  [kernel]       [k] compound_head
      0.75%  [kernel]       [k] __netdev_pick_tx
      0.73%  [kernel]       [k] sch_direct_xmit
      0.65%  [kernel]       [k] irq_entries_start
      0.63%  [mlx5_core]    [k] mlx5e_free_rx_wqe_reuse
      0.61%  [kernel]       [k] netdev_pick_tx
      0.61%  [kernel]       [k] validate_xmit_skb
      0.55%  [kernel]       [k] skb_network_protocol
      0.53%  [mlx5_core]    [k] mlx5e_rx_cache_get
      0.53%  [mlx5_core]    [k] mlx5e_build_rx_skb
      0.51%  [kernel]       [k] ip_rcv_finish
      0.50%  [kernel]       [k] eth_header
      0.50%  [kernel]       [k] fib_validate_source
      0.50%  [mlx5_core]    [k] mlx5e_handle_rx_cqe
      0.48%  [mlx5_core]    [k] eq_update_ci
      0.47%  [kernel]       [k] kmem_cache_free_bulk
      0.44%  [kernel]       [k] deliver_ptype_list_skb
      0.43%  [kernel]       [k] skb_release_data
      0.42%  [kernel]       [k] cpuidle_enter_state
      0.40%  [kernel]       [k] virt_to_head_page
      0.39%  [kernel]       [k] vlan_dev_hard_start_xmit
      0.39%  [kernel]       [k] neigh_connected_output
      0.38%  [kernel]       [k] eth_type_vlan
      0.35%  [mlx5_core]    [k] mlx5e_alloc_rx_wqe
      0.32%  [kernel]       [k] nf_hook_slow
      0.32%  [kernel]       [k] swiotlb_map_page
      0.31%  [kernel]       [k] ip_finish_output
      0.29%  [kernel]       [k] ip_output
      0.28%  [kernel]       [k] skb_free_head
      0.25%  [kernel]       [k] netif_receive_skb_internal
      0.25%  [kernel]       [k] __jhash_nwords



Without hack:

     14.25%  [kernel]       [k] dst_release
     14.17%  [kernel]       [k] skb_dst_force
     13.41%  [kernel]       [k] rt_cache_valid
     11.47%  [kernel]       [k] ip_finish_output2
      7.01%  [kernel]       [k] do_raw_spin_lock
      5.07%  [kernel]       [k] page_frag_free
      3.47%  [mlx5_core]    [k] mlx5e_xmit
      2.88%  [kernel]       [k] fib_table_lookup
      2.43%  [mlx5_core]    [k] skb_from_cqe.isra.32
      1.97%  [kernel]       [k] virt_to_head_page
      1.81%  [mlx5_core]    [k] mlx5e_poll_tx_cq
      0.93%  [kernel]       [k] __dev_queue_xmit
      0.87%  [kernel]       [k] __build_skb
      0.84%  [kernel]       [k] ipt_do_table
      0.79%  [kernel]       [k] ip_rcv
      0.79%  [kernel]       [k] acpi_processor_ffh_cstate_enter
      0.78%  [kernel]       [k] netif_skb_features
      0.73%  [kernel]       [k] __netif_receive_skb_core
      0.52%  [kernel]       [k] dev_hard_start_xmit
      0.52%  [kernel]       [k] build_skb
      0.51%  [kernel]       [k] ip_route_input_rcu
      0.50%  [kernel]       [k] skb_unref
      0.49%  [kernel]       [k] ip_forward
      0.48%  [mlx5_core]    [k] mlx5_cqwq_get_cqe
      0.44%  [kernel]       [k] udp_v4_early_demux
      0.41%  [kernel]       [k] napi_consume_skb
      0.40%  [kernel]       [k] __local_bh_enable_ip
      0.39%  [kernel]       [k] ip_rcv_finish
      0.39%  [kernel]       [k] kmem_cache_alloc
      0.38%  [kernel]       [k] sch_direct_xmit
      0.33%  [kernel]       [k] validate_xmit_skb
      0.32%  [mlx5_core]    [k] mlx5e_free_rx_wqe_reuse
      0.29%  [kernel]       [k] netdev_pick_tx
      0.28%  [mlx5_core]    [k] mlx5e_build_rx_skb
      0.27%  [kernel]       [k] deliver_ptype_list_skb
      0.26%  [kernel]       [k] fib_validate_source
      0.26%  [mlx5_core]    [k] mlx5e_napi_poll
      0.26%  [mlx5_core]    [k] mlx5e_handle_rx_cqe
      0.26%  [mlx5_core]    [k] mlx5e_rx_cache_get
      0.25%  [kernel]       [k] eth_header
      0.23%  [kernel]       [k] skb_network_protocol
      0.20%  [kernel]       [k] nf_hook_slow
      0.20%  [kernel]       [k] vlan_passthru_hard_header
      0.20%  [kernel]       [k] vlan_dev_hard_start_xmit
      0.19%  [kernel]       [k] swiotlb_map_page
      0.18%  [kernel]       [k] compound_head
      0.18%  [kernel]       [k] neigh_connected_output
      0.18%  [mlx5_core]    [k] mlx5e_alloc_rx_wqe
      0.18%  [kernel]       [k] ip_output
      0.17%  [kernel]       [k] prefetch_freepointer.isra.70
      0.17%  [kernel]       [k] __slab_free
      0.16%  [kernel]       [k] eth_type_vlan
      0.16%  [kernel]       [k] ip_finish_output
      0.15%  [kernel]       [k] kmem_cache_free_bulk
      0.14%  [kernel]       [k] netif_receive_skb_internal


W dniu 2017-08-15 o 11:11, Paweł Staszewski pisze:
> Hi
>
>
> Yes it helped - now there is almost no difference when using vlans or 
> not:
>
> 10.5Mpps - with vlan
>
> 11Mpps - without vlan
>
>
>
>
> W dniu 2017-08-15 o 03:17, Eric Dumazet pisze:
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
>>       vlan->vlan_proto = proto;
>>       vlan->vlan_id     = nla_get_u16(data[IFLA_VLAN_ID]);
>>       vlan->real_dev     = real_dev;
>> +    dev->priv_flags |= (real_dev->priv_flags & IFF_XMIT_DST_RELEASE);
>>       vlan->flags     = VLAN_FLAG_REORDER_HDR;
>>         err = vlan_check_real_dev(real_dev, vlan->vlan_proto, 
>> vlan->vlan_id);
>>
>>
>>
>>
>
>
