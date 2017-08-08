From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Performance comparision for 10G ethernet no vlans vs 10G ethernet
 traffic on one vlan
Date: Tue, 8 Aug 2017 12:53:03 +0200
Message-ID: <ec5a2b7c-2e3d-090d-7c36-0b6e72343079@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp7.iq.pl ([86.111.240.244]:50584 "EHLO smtp7.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751921AbdHHKyP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Aug 2017 06:54:15 -0400
Received: from [192.168.2.200] (unknown [185.78.72.19])
        (Authenticated sender: pstaszewski@itcare.pl)
        by smtp.iq.pl (Postfix) with ESMTPSA id 3xRWVY3R3Jz3xSg
        for <netdev@vger.kernel.org>; Tue,  8 Aug 2017 12:54:13 +0200 (CEST)
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi


Wondering why there is such a big difference when testing forwarding 
host with forwarding traffic on vlan and without vlan.

Kernel used: 4.12.4

UDP stream ~10Mpps - random destination from network 172.16.0.0/12 + 
random udp port


Forwarding performance with 8x RSS queues (no vlan on TX device enp216s0f1)

ip config:

RX NIC

7: enp216s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state 
UP group default qlen 8192
     link/ether 0c:c4:7a:ea:21:44 brd ff:ff:ff:ff:ff:ff
     inet 10.0.0.1/30 scope global enp216s0f0
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:feea:2144/64 scope link
        valid_lft forever preferred_lft forever

TX NIC

8: enp216s0f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state 
UP group default qlen 8192
     link/ether 0c:c4:7a:ea:21:45 brd ff:ff:ff:ff:ff:ff
     inet 10.0.0.5/30 scope global enp216s0f1
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:feea:2145/64 scope link
        valid_lft forever preferred_lft forever

       enp216s0f0:      9772859.00 P/s             0.00 P/s 9772859.00 P/s
        enp216s0f1:            0.00 P/s       9772883.00 P/s 9772883.00 P/s
------------------------------------------------------------------------------ 

             total:      9772863.00 P/s       9772886.00 P/s 19545750.00 
P/s

mpstat -P ALL 1 10

Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft %steal  
%guest  %gnice   %idle
Average:     all    0.00    0.00    0.00    0.00    0.00 11.89 0.00    
0.00    0.00   88.11
Average:       0    0.00    0.00    0.00    0.00    0.00 0.10 0.00    
0.00    0.00   99.90
Average:       1    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:       2    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:       3    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:       4    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:       5    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:       6    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:       7    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:       8    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:       9    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      10    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      11    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      12    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      13    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      14    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      15    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      16    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      17    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      18    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      19    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      20    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      21    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      22    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      23    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      24    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      25    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      26    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      27    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      28    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      29    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      30    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      31    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      32    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      33    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      34    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      35    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      36    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      37    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      38    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      39    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      40    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      41    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      42    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      43    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      44    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      45    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      46    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      47    0.00    0.00    0.00    0.00    0.00 0.00 0.00    
0.00    0.00  100.00
Average:      48    0.00    0.00    0.00    0.00    0.00 84.10 0.00    
0.00    0.00   15.90
Average:      49    0.00    0.00    0.00    0.00    0.00 83.20 0.00    
0.00    0.00   16.80
Average:      50    0.00    0.00    0.00    0.00    0.00 81.98 0.00    
0.00    0.00   18.02
Average:      51    0.00    0.00    0.00    0.00    0.00 80.80 0.00    
0.00    0.00   19.20
Average:      52    0.00    0.00    0.00    0.00    0.00 82.20 0.00    
0.00    0.00   17.80
Average:      53    0.00    0.00    0.00    0.00    0.00 85.30 0.00    
0.00    0.00   14.70
Average:      54    0.00    0.00    0.00    0.00    0.00 85.30 0.00    
0.00    0.00   14.70
Average:      55    0.00    0.00    0.00    0.00    0.00 82.88 0.00    
0.00    0.00   17.12


    PerfTop:   55080 irqs/sec  kernel:99.8%  exact:  0.0% [4000Hz 
cycles],  (all, 56 CPUs)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 


     21.93%  [kernel]       [k] do_raw_spin_lock
      7.22%  [kernel]       [k] fib_table_lookup
      6.79%  [kernel]       [k] acpi_processor_ffh_cstate_enter
      5.46%  [kernel]       [k] ixgbe_poll
      4.98%  [kernel]       [k] netif_receive_skb_internal
      2.90%  [kernel]       [k] __build_skb
      2.82%  [kernel]       [k] ipt_do_table
      2.44%  [kernel]       [k] ixgbe_xmit_frame_ring
      2.42%  [kernel]       [k] ip_rcv
      2.31%  [kernel]       [k] get_rps_cpu
      1.98%  [kernel]       [k] ip_finish_output2
      1.87%  [kernel]       [k] __dev_queue_xmit
      1.82%  [kernel]       [k] __netif_receive_skb_core
      1.57%  [kernel]       [k] ip_route_input_noref
      1.39%  [kernel]       [k] kmem_cache_alloc
      1.29%  [kernel]       [k] ip_forward
      1.27%  [kernel]       [k] irq_entries_start
      1.27%  [kernel]       [k] skb_release_data
      1.15%  [kernel]       [k] netif_skb_features
      1.14%  [kernel]       [k] sch_direct_xmit
      1.12%  [kernel]       [k] page_frag_free
      0.99%  [kernel]       [k] __local_bh_enable_ip
      0.78%  [kernel]       [k] dev_gro_receive
      0.77%  [kernel]       [k] fib_validate_source
      0.71%  [kernel]       [k] ip_rcv_finish
      0.71%  [kernel]       [k] get_dma_ops
      0.70%  [kernel]       [k] __netdev_pick_tx
      0.68%  [kernel]       [k] dev_hard_start_xmit
      0.66%  [kernel]       [k] deliver_ptype_list_skb
      0.52%  [kernel]       [k] ixgbe_alloc_rx_buffers
      0.51%  [kernel]       [k] netdev_pick_tx
      0.48%  [kernel]       [k] cpuidle_enter_state
      0.48%  [kernel]       [k] eth_type_trans
      0.47%  [kernel]       [k] nf_hook_slow
      0.46%  [kernel]       [k] build_skb
      0.44%  [kernel]       [k] is_swiotlb_buffer






And scenario with one vlan added to enp216s0f1 (vlan tag 1000)

ip config

RX NIC

7: enp216s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state 
UP group default qlen 8192
     link/ether 0c:c4:7a:ea:21:44 brd ff:ff:ff:ff:ff:ff
     inet 10.0.0.1/30 scope global enp216s0f0
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:feea:2144/64 scope link
        valid_lft forever preferred_lft forever

TX NIC with assigned vlan 1000

8: enp216s0f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state 
UP group default qlen 8192
     link/ether 0c:c4:7a:ea:21:45 brd ff:ff:ff:ff:ff:ff
     inet6 fe80::ec4:7aff:feea:2145/64 scope link
        valid_lft forever preferred_lft forever

10: vlan1000@enp216s0f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 
qdisc noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:ea:21:45 brd ff:ff:ff:ff:ff:ff
     inet 10.0.0.5/30 scope global vlan1000
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:feea:2145/64 scope link
        valid_lft forever preferred_lft forever


  bwm-ng v0.6.1 (probing every 0.500s), press 'h' for help
   input: /proc/net/dev type: rate
   \         iface                   Rx Tx                Total
==============================================================================
         enp24s0f3:           61.88 P/s             7.98 P/s            
69.86 P/s
                lo:            0.00 P/s             0.00 P/s             
0.00 P/s
          vlan1000:            0.00 P/s       6309299.50 P/s 6309299.50 P/s
        enp216s0f0:      6308918.50 P/s             0.00 P/s 6308918.50 P/s
        enp216s0f1:            0.00 P/s       6308912.50 P/s 6308912.50 P/s
------------------------------------------------------------------------------
             total:      6308980.00 P/s      12618220.00 P/s 18927200.00 P/s


pps drops from 9.7Mpps to 6.3Mpps

Cpu load rises to 100% cpu on all 8x Cores where RSS from NIC's are bind


Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft %steal  
%guest  %gnice   %idle
Average:     all    0.01    0.00    0.01    0.00    0.00 14.29    
0.00    0.00    0.00   85.70
Average:       0    0.10    0.00    0.30    0.00    0.00 0.10    0.00    
0.00    0.00   99.50
Average:       1    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       2    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       3    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       4    0.00    0.00    0.10    0.00    0.00 0.00    0.00    
0.00    0.00   99.90
Average:       5    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       6    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       7    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       8    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       9    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      10    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      11    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      12    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      13    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      14    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      15    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      16    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      17    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      18    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      19    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      20    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      21    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      22    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      23    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      24    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      25    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      26    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      27    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      28    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      29    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      30    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      31    0.20    0.00    0.10    0.00    0.00 0.00    0.00    
0.00    0.00   99.70
Average:      32    0.00    0.00    0.10    0.00    0.00 0.00    0.00    
0.00    0.00   99.90
Average:      33    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      34    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      35    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      36    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      37    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      38    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      39    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      40    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      41    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      42    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      43    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      44    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      45    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      46    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      47    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      48    0.00    0.00    0.00    0.00    0.00 100.00    
0.00    0.00    0.00    0.00
Average:      49    0.00    0.00    0.10    0.00    0.00 99.90    
0.00    0.00    0.00    0.00
Average:      50    0.00    0.00    0.00    0.00    0.00 100.00    
0.00    0.00    0.00    0.00
Average:      51    0.00    0.00    0.00    0.00    0.00 100.00    
0.00    0.00    0.00    0.00
Average:      52    0.00    0.00    0.00    0.00    0.00 100.00    
0.00    0.00    0.00    0.00
Average:      53    0.00    0.00    0.00    0.00    0.00 100.00    
0.00    0.00    0.00    0.00
Average:      54    0.00    0.00    0.00    0.00    0.00 100.00    
0.00    0.00    0.00    0.00
Average:      55    0.00    0.00    0.00    0.00    0.00 100.00    
0.00    0.00    0.00    0.00


And perf top:

    PerfTop:   38413 irqs/sec  kernel:99.7%  exact:  0.0% [4000Hz 
cycles],  (all, 56 CPUs)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

     11.96%  [kernel]       [k] do_raw_spin_lock
      9.62%  [kernel]       [k] dst_release
      9.19%  [kernel]       [k] skb_dst_force
      8.15%  [kernel]       [k] rt_cache_valid
      7.00%  [kernel]       [k] ip_finish_output2
      6.17%  [kernel]       [k] fib_table_lookup
      3.59%  [kernel]       [k] ixgbe_poll
      3.32%  [kernel]       [k] eth_type_trans
      2.59%  [kernel]       [k] dev_gro_receive
      2.05%  [kernel]       [k] __build_skb
      1.99%  [kernel]       [k] ixgbe_xmit_frame_ring
      1.82%  [kernel]       [k] ip_rcv
      1.79%  [kernel]       [k] acpi_processor_ffh_cstate_enter
      1.64%  [kernel]       [k] __dev_queue_xmit
      1.59%  [kernel]       [k] netif_skb_features
      1.24%  [kernel]       [k] ipt_do_table
      1.12%  [kernel]       [k] __netif_receive_skb_core
      1.08%  [kernel]       [k] dev_hard_start_xmit
      1.06%  [kernel]       [k] ip_route_input_noref
      0.98%  [kernel]       [k] ip_forward
      0.87%  [kernel]       [k] skb_release_data
      0.82%  [kernel]       [k] sch_direct_xmit
      0.77%  [kernel]       [k] inet_gro_receive
      0.71%  [kernel]       [k] __local_bh_enable_ip
      0.64%  [kernel]       [k] kmem_cache_alloc
      0.63%  [kernel]       [k] page_frag_free
      0.60%  [kernel]       [k] netdev_pick_tx
      0.58%  [kernel]       [k] validate_xmit_skb
      0.57%  [kernel]       [k] deliver_ptype_list_skb
      0.49%  [kernel]       [k] ip_rcv_finish
      0.49%  [kernel]       [k] vlan_dev_hard_start_xmit
      0.49%  [kernel]       [k] get_dma_ops
      0.48%  [kernel]       [k] eth_header
      0.48%  [kernel]       [k] fib_validate_source
      0.42%  [kernel]       [k] skb_network_protocol
      0.41%  [kernel]       [k] neigh_connected_output
      0.40%  [kernel]       [k] swiotlb_map_page
      0.38%  [kernel]       [k] build_skb
      0.37%  [kernel]       [k] ixgbe_alloc_rx_buffers
      0.32%  [kernel]       [k] ip_output
      0.31%  [kernel]       [k] __netdev_pick_tx
      0.31%  [kernel]       [k] nf_hook_slow
      0.28%  [kernel]       [k] ip_finish_output
      0.28%  [kernel]       [k] is_swiotlb_buffer
      0.27%  [kernel]       [k] udp4_gro_receive
      0.27%  [kernel]       [k] validate_xmit_skb_list
      0.26%  [kernel]       [k] virt_to_head_page


ethtool:

ethtool -k enp216s0f1
Features for enp216s0f1:
rx-checksumming: on
tx-checksumming: on
         tx-checksum-ipv4: off [fixed]
         tx-checksum-ip-generic: on
         tx-checksum-ipv6: off [fixed]
         tx-checksum-fcoe-crc: off [fixed]
         tx-checksum-sctp: on
scatter-gather: on
         tx-scatter-gather: on
         tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
         tx-tcp-segmentation: on
         tx-tcp-ecn-segmentation: off [fixed]
         tx-tcp-mangleid-segmentation: off
         tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: on
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: on
tx-gre-csum-segmentation: on
tx-ipxip4-segmentation: on
tx-ipxip6-segmentation: on
tx-udp_tnl-segmentation: on
tx-udp_tnl-csum-segmentation: on
tx-gso-partial: on
tx-sctp-segmentation: off [fixed]
tx-esp-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off
hw-tc-offload: off
esp-hw-offload: off [fixed]
esp-tx-csum-hw-offload: off [fixed]

ethtool -k enp216s0f0
Features for enp216s0f0:
rx-checksumming: on
tx-checksumming: on
         tx-checksum-ipv4: off [fixed]
         tx-checksum-ip-generic: on
         tx-checksum-ipv6: off [fixed]
         tx-checksum-fcoe-crc: off [fixed]
         tx-checksum-sctp: on
scatter-gather: on
         tx-scatter-gather: on
         tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
         tx-tcp-segmentation: on
         tx-tcp-ecn-segmentation: off [fixed]
         tx-tcp-mangleid-segmentation: off
         tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: on
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: on
tx-gre-csum-segmentation: on
tx-ipxip4-segmentation: on
tx-ipxip6-segmentation: on
tx-udp_tnl-segmentation: on
tx-udp_tnl-csum-segmentation: on
tx-gso-partial: on
tx-sctp-segmentation: off [fixed]
tx-esp-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off
hw-tc-offload: off
esp-hw-offload: off [fixed]
esp-tx-csum-hw-offload: off [fixed]

ethtool -i enp216s0f0
driver: ixgbe
version: 5.0.0-k
firmware-version: 0x800006da
expansion-rom-version:
bus-info: 0000:d8:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes

ethtool -i enp216s0f1
driver: ixgbe
version: 5.0.0-k
firmware-version: 0x800006da
expansion-rom-version:
bus-info: 0000:d8:00.1
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes


BR

Paweł
