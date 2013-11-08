From: "Anton 'EvilMan' Danilov" <littlesmilingcloud@gmail.com>
Subject: Fwd: Using HTB over MultiQ
Date: Fri, 8 Nov 2013 20:11:31 +0400
Message-ID: <CAEzD07+nrP4AnMXUjZSyG3_TUEk0_HdovPJUnwPrpTemOUEzgA@mail.gmail.com>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>
	<1383833480.9412.58.camel@edumazet-glaptop2.roam.corp.google.com>
	<1383834021.9412.61.camel@edumazet-glaptop2.roam.corp.google.com>
	<527BA63F.7040900@intel.com>
	<CAEzD07JwrnqeB35BiTC2ztpyei2KNDtYO8zuewicKNBwyxmOtQ@mail.gmail.com>
	<1383923220.9412.236.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAEzD07LmzCtVWM4wnq57N+NfqDUK3bLWDisSceyPfg4MiWz5=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:64303 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756856Ab3KHQLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 11:11:33 -0500
Received: by mail-wi0-f174.google.com with SMTP id cb5so2405536wib.1
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 08:11:32 -0800 (PST)
In-Reply-To: <CAEzD07LmzCtVWM4wnq57N+NfqDUK3bLWDisSceyPfg4MiWz5=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

3/11/8 Eric Dumazet <eric.dumazet@gmail.com>:
> Please post :
>
> ethtool -S eth0  # or other nics
>
dau@diamond-b-new:~$ sudo ethtool -i eth0
driver: ixgbe
version: 3.18.7
firmware-version: 0x61c10001
bus-info: 0000:06:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no

dau@diamond-b-new:~$ sudo ethtool -S eth0
NIC statistics:
     rx_packets: 27615733650
     tx_packets: 22631364386
     rx_bytes: 21970067159056
     tx_bytes: 10777613703708
     rx_errors: 970
     tx_errors: 0
     rx_dropped: 0
     tx_dropped: 0
     multicast: 0
     collisions: 0
     rx_over_errors: 0
     rx_crc_errors: 969
     rx_frame_errors: 0
     rx_fifo_errors: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     rx_pkts_nic: 27615733771
     tx_pkts_nic: 22631364450
     rx_bytes_nic: 22080530126479
     tx_bytes_nic: 10903921708333
     lsc_int: 7
     tx_busy: 0
     non_eop_descs: 0
     broadcast: 1
     rx_no_buffer_count: 0
     tx_timeout_count: 0
     tx_restart_queue: 0
     rx_long_length_errors: 0
     rx_short_length_errors: 0
     tx_flow_control_xon: 6158021
     rx_flow_control_xon: 0
     tx_flow_control_xoff: 6492967
     rx_flow_control_xoff: 0
     rx_csum_offload_errors: 10963
     alloc_rx_page_failed: 0
     alloc_rx_buff_failed: 0
     rx_no_dma_resources: 0
     hw_rsc_aggregated: 0
     hw_rsc_flushed: 0
     fdir_match: 12699568207
     fdir_miss: 17278480118
     fdir_overflow: 105313
     os2bmc_rx_by_bmc: 0
     os2bmc_tx_by_bmc: 0
     os2bmc_tx_by_host: 0
     os2bmc_rx_by_host: 0
     tx_queue_0_packets: 3513849609
     tx_queue_0_bytes: 1713928985198
     tx_queue_1_packets: 2975756171
     tx_queue_1_bytes: 1482722458160
     tx_queue_2_packets: 2767637888
     tx_queue_2_bytes: 1193622863115
     tx_queue_3_packets: 2544906780
     tx_queue_3_bytes: 1135152930636
     tx_queue_4_packets: 2372537806
     tx_queue_4_bytes: 999288935581
     tx_queue_5_packets: 2440784133
     tx_queue_5_bytes: 1061348848250
     tx_queue_6_packets: 3649915131
     tx_queue_6_bytes: 2220031265880
     tx_queue_7_packets: 2365976873
     tx_queue_7_bytes: 971517421682
    ...skip empty queues..
     rx_queue_0_packets: 3833356046
     rx_queue_0_bytes: 2979383872046
     rx_queue_1_packets: 3468460501
     rx_queue_1_bytes: 2944894700402
     rx_queue_2_packets: 4490817931
     rx_queue_2_bytes: 3331801734194
     rx_queue_3_packets: 3040960354
     rx_queue_3_bytes: 2311877907901
     rx_queue_4_packets: 2825992742
     rx_queue_4_bytes: 2145413330911
     rx_queue_5_packets: 3032906907
     rx_queue_5_bytes: 2455554004223
     rx_queue_6_packets: 3675117297
     rx_queue_6_bytes: 3266611260920
     rx_queue_7_packets: 3248121993
     rx_queue_7_bytes: 2534530380798

> perf record -a -g sleep 10
>
> perf report | tail -n 200
>
# Samples: 299K of event 'cycles'
# Event count (approx.): 274090453333
#
# Overhead          Command             Shared Object
                     Symbol
# ........  ...............  ........................
...........................................
#
    11.36%          swapper  [kernel.kallsyms]         [k]
_raw_spin_lock
                    |
                    --- _raw_spin_lock
                       |
                       |--92.83%-- dev_queue_xmit
                       |          ip_finish_output
                       |          ip_output
                       |          ip_forward_finish
                       |          ip_forward
                       |          ip_rcv_finish
                       |          ip_rcv
                       |          __netif_receive_skb_core
                       |          __netif_receive_skb
                       |          netif_receive_skb
                       |          napi_gro_receive
                       |          ixgbe_poll
                       |          net_rx_action
                       |          __do_softirq
                       |          call_softirq
                       |          do_softirq
                       |          irq_exit
                       |          |
                       |          |--96.12%-- do_IRQ
                       |          |          common_interrupt
                       |          |          |
                       |          |          |--86.81%-- cpuidle_idle_call
                       |          |          |          arch_cpu_idle
                       |          |          |          cpu_startup_entry
                       |          |          |          |
                       |          |          |          |--78.31%--
start_secondary
                       |          |          |          |
                       |          |          |           --21.69%-- rest_init
                       |          |          |                     start_kernel
                       |          |          |
x86_64_start_reservations
                       |          |          |
x86_64_start_kernel
                       |          |          |
                       |          |          |--12.90%-- cpuidle_enter_state
                       |          |          |          cpuidle_idle_call
                       |          |          |          arch_cpu_idle
                       |          |          |          cpu_startup_entry
                       |          |          |          |
                       |          |          |          |--80.50%--
start_secondary
                       |          |          |          |
                       |          |          |           --19.50%-- rest_init
                       |          |          |                     start_kernel
                       |          |          |
x86_64_start_reservations
                       |          |          |
x86_64_start_kernel
                       |          |           --0.30%-- [...]
                       |          |
                       |          |--3.87%-- smp_apic_timer_interrupt
                       |          |          apic_timer_interrupt
                       |          |          |
                       |          |          |--44.35%-- cpu_startup_entry
                       |          |          |          |
                       |          |          |          |--72.25%--
start_secondary
                       |          |          |          |
                       |          |          |           --27.75%-- rest_init
                       |          |          |                     start_kernel
                       |          |          |
x86_64_start_reservations
                       |          |          |
x86_64_start_kernel
                       |          |          |
                       |          |          |--37.26%-- cpuidle_idle_call
                       |          |          |          arch_cpu_idle
                       |          |          |          cpu_startup_entry
                       |          |          |          |
                       |          |          |          |--80.34%--
start_secondary
                       |          |          |          |
                       |          |          |           --19.66%-- rest_init
                       |          |          |                     start_kernel
                       |          |          |
x86_64_start_reservations
                       |          |          |
x86_64_start_kernel
                       |          |          |
                       |          |          |--8.83%-- cpuidle_enter_state
                       |          |          |          cpuidle_idle_call
                       |          |          |          arch_cpu_idle
                       |          |          |          cpu_startup_entry
                       |          |          |          |
                       |          |          |          |--76.66%--
start_secondary
                       |          |          |          |
                       |          |          |           --23.34%-- rest_init
                       |          |          |                     start_kernel
                       |          |          |
x86_64_start_reservations
                       |          |          |
x86_64_start_kernel
                       |          |          |
                       |          |          |--3.54%-- arch_cpu_idle
                       |          |          |          cpu_startup_entry
                       |          |          |          |
                       |          |          |          |--55.28%--
start_secondary
                       |          |          |          |
                       |          |          |           --44.72%-- rest_init
                       |          |          |                     start_kernel
                       |          |          |
x86_64_start_reservations
                       |          |          |
x86_64_start_kernel
                       |          |          |
                       |          |          |--2.10%-- start_secondary
                       |          |          |
                       |          |          |--2.02%-- __schedule
                       |          |          |          schedule
                       |          |          |
schedule_preempt_disabled
                       |          |          |          cpu_startup_entry
                       |          |          |          |
                       |          |          |          |--75.10%--
start_secondary
                       |          |          |          |
                       |          |          |           --24.90%-- rest_init
                       |          |          |                     start_kernel
                       |          |          |
x86_64_start_reservations
                       |          |          |
x86_64_start_kernel
                       |          |          |
                       |          |          |--0.92%-- rest_init
                       |          |          |          start_kernel
                       |          |          |
x86_64_start_reservations
                       |          |          |          x86_64_start_kernel
                       |          |          |
                       |          |          |--0.55%-- ns_to_timeval
                       |          |          |          cpuidle_enter_state
                       |          |          |          cpuidle_idle_call
                       |          |          |          arch_cpu_idle
                       |          |          |          cpu_startup_entry
                       |          |          |          rest_init
                       |          |          |          start_kernel
                       |          |          |
x86_64_start_reservations
                       |          |          |          x86_64_start_kernel
                       |          |           --0.43%-- [...]
                       |           --0.01%-- [...]
                       |
                       |--5.76%-- sch_direct_xmit
                       |          __qdisc_run
                       |          |
                       |          |--99.95%-- dev_queue_xmit
                       |          |          ip_finish_output
                       |          |          ip_output
                       |          |          ip_forward_finish
                       |          |          ip_forward
                       |          |          ip_rcv_finish
                       |          |          ip_rcv
                       |          |          __netif_receive_skb_core
                       |          |          __netif_receive_skb
                       |          |          netif_receive_skb
                       |          |          napi_gro_receive
                       |          |          ixgbe_poll
                       |          |          net_rx_action
                       |          |          __do_softirq
                       |          |          call_softirq
                       |          |          do_softirq
                       |          |          irq_exit
                       |          |          |
                       |          |          |--99.10%-- do_IRQ
                       |          |          |          common_interrupt
                       |          |          |          |
                       |          |          |          |--86.84%--
cpuidle_idle_call
                       |          |          |          |          arch_cpu_idle
                       |          |          |          |
cpu_startup_entry
                       |          |          |          |          |
                       |          |          |          |
|--79.93%-- start_secondary
                       |          |          |          |          |
                       |          |          |          |
--20.07%-- rest_init
                       |          |          |          |
       start_kernel
                       |          |          |          |
       x86_64_start_reservations
                       |          |          |          |
       x86_64_start_kernel
                       |          |          |          |
                       |          |          |          |--12.81%--
cpuidle_enter_state
                       |          |          |          |
cpuidle_idle_call
                       |          |          |          |          arch_cpu_idle
                       |          |          |          |
cpu_startup_entry
                       |          |          |          |          |
                       |          |          |          |
|--78.16%-- start_secondary
                       |          |          |          |          |
                       |          |          |          |
--21.84%-- rest_init
                       |          |          |          |
       start_kernel
                       |          |          |          |
       x86_64_start_reservations
                       |          |          |          |
       x86_64_start_kernel
                       |          |          |           --0.34%-- [...]
                       |          |          |
                       |          |           --0.90%-- smp_apic_timer_interrupt
                       |          |                     apic_timer_interrupt
                       |          |                     |
                       |          |                     |--49.13%--
cpuidle_idle_call
                       |          |                     |          arch_cpu_idle
                       |          |                     |
cpu_startup_entry
                       |          |                     |          |
                       |          |                     |
|--67.34%-- start_secondary
                       |          |                     |          |
                       |          |                     |
--32.66%-- rest_init
                       |          |                     |
       start_kernel
                       |          |                     |
       x86_64_start_reservations
                       |          |                     |
       x86_64_start_kernel
                       |          |                     |
                       |          |                     |--28.97%--
cpu_startup_entry
                       |          |                     |          |
                       |          |                     |
|--55.35%-- rest_init
                       |          |                     |          |
       start_kernel
                       |          |                     |          |
       x86_64_start_reservations
                       |          |                     |          |
       x86_64_start_kernel
                       |          |                     |          |
                       |          |                     |
--44.65%-- start_secondary
                       |          |                     |
                       |          |                     |--5.56%--
cpuidle_enter_state
                       |          |                     |
cpuidle_idle_call
                       |          |                     |          arch_cpu_idle
                       |          |                     |
cpu_startup_entry
                       |          |                     |
start_secondary
                       |          |                     |
                       |          |                     |--5.54%-- __schedule
                       |          |                     |          schedule
                       |          |                     |
schedule_preempt_disabled
                       |          |                     |
cpu_startup_entry
                       |          |                     |
start_secondary
                       |          |                     |
                       |          |                     |--5.45%--
start_secondary
                       |          |                     |
                       |          |                      --5.35%-- arch_cpu_idle
                       |          |
cpu_startup_entry
                       |          |
start_secondary
                       |           --0.05%-- [...]
                       |
                       |--0.70%-- __hrtimer_start_range_ns
                       |          hrtimer_start
                       |          htb_dequeue
                       |          0xffffffffa02e5089
                       |          __qdisc_run
                       |          dev_queue_xmit
                       |          ip_finish_output
                       |          ip_output
                       |          ip_forward_finish
                       |          ip_forward
                       |          ip_rcv_finish
                       |          ip_rcv
                       |          __netif_receive_skb_core
                       |          __netif_receive_skb
                       |          netif_receive_skb
                       |          napi_gro_receive
                       |          ixgbe_poll
                       |          net_rx_action
                       |          __do_softirq
                       |          call_softirq
                       |          do_softirq
                       |          irq_exit
                       |          |
                       |          |--98.36%-- do_IRQ
                       |          |          common_interrupt
                       |          |          |
                       |          |          |--83.48%-- cpuidle_idle_call
                       |          |          |          arch_cpu_idle
                       |          |          |          cpu_startup_entry
                       |          |          |          |
                       |          |          |          |--79.48%--
start_secondary
                       |          |          |          |
                       |          |          |           --20.52%-- rest_init
                       |          |          |                     start_kernel
                       |          |          |
x86_64_start_reservations
                       |          |          |
x86_64_start_kernel
                       |          |          |
                       |          |          |--15.24%-- cpuidle_enter_state
                       |          |          |          cpuidle_idle_call
                       |          |          |          arch_cpu_idle
                       |          |          |          cpu_startup_entry
                       |          |          |          |
                       |          |          |          |--91.68%--
start_secondary
                       |          |          |          |
                       |          |          |           --8.32%-- rest_init
                       |          |          |                     start_kernel
                       |          |          |
x86_64_start_reservations
                       |          |          |
x86_64_start_kernel
                       |          |           --1.28%-- [...]
                       |          |
                       |           --1.64%-- smp_apic_timer_interrupt
                       |                     apic_timer_interrupt
                       |                     |
                       |                     |--75.50%-- cpuidle_idle_call
                       |                     |          arch_cpu_idle
                       |                     |          cpu_startup_entry
                       |                     |          start_secondary
                       |                     |
                       |                      --24.50%-- cpu_startup_entry
                       |                                rest_init
                       |                                start_kernel



> And possibly it would be nice if you send your tc script so that we can
> check ;)
>
>

#!/sbin/tc -b
 #generated by script

 #internal networks iface (customers) - eth0
 #external iface - eth1

 qdisc add dev eth0 root handle 10: multiq

 #htb qdisc with root and default classes per hw-queue

 qdisc add dev eth0 parent 10:1 handle 11: htb default 2
 class add dev eth0 parent 11: classid 11:1 htb rate 1250Mbit
 class add dev eth0 parent 11:1 classid 11:2 htb rate 125Mbit ceil 1250Mbit
 qdisc add dev eth0 parent 10:2 handle 12: htb default 2
 class add dev eth0 parent 12: classid 12:1 htb rate 1250Mbit
 class add dev eth0 parent 12:1 classid 12:2 htb rate 125Mbit ceil 1250Mbit
 qdisc add dev eth0 parent 10:3 handle 13: htb default 2
 class add dev eth0 parent 13: classid 13:1 htb rate 1250Mbit
 class add dev eth0 parent 13:1 classid 13:2 htb rate 125Mbit ceil 1250Mbit
 qdisc add dev eth0 parent 10:4 handle 14: htb default 2
 class add dev eth0 parent 14: classid 14:1 htb rate 1250Mbit
 class add dev eth0 parent 14:1 classid 14:2 htb rate 125Mbit ceil 1250Mbit
 qdisc add dev eth0 parent 10:5 handle 15: htb default 2
 class add dev eth0 parent 15: classid 15:1 htb rate 1250Mbit
 class add dev eth0 parent 15:1 classid 15:2 htb rate 125Mbit ceil 1250Mbit
 qdisc add dev eth0 parent 10:6 handle 16: htb default 2
 class add dev eth0 parent 16: classid 16:1 htb rate 1250Mbit
 class add dev eth0 parent 16:1 classid 16:2 htb rate 125Mbit ceil 1250Mbit
 qdisc add dev eth0 parent 10:7 handle 17: htb default 2
 class add dev eth0 parent 17: classid 17:1 htb rate 1250Mbit
 class add dev eth0 parent 17:1 classid 17:2 htb rate 125Mbit ceil 1250Mbit
 qdisc add dev eth0 parent 10:8 handle 18: htb default 2
 class add dev eth0 parent 18: classid 18:1 htb rate 1250Mbit
 class add dev eth0 parent 18:1 classid 18:2 htb rate 125Mbit ceil 1250Mbit

 qdisc add dev eth1 root handle 10: multiq
 qdisc add dev eth1 parent 10:1 handle 11: htb default 2
 class add dev eth1 parent 11: classid 11:1 htb rate 1250Mbit
 class add dev eth1 parent 11:1 classid 11:2 htb rate 125Mbit ceil 1250Mbit
 qdisc add dev eth1 parent 10:2 handle 12: htb default 2
 class add dev eth1 parent 12: classid 12:1 htb rate 1250Mbit
 class add dev eth1 parent 12:1 classid 12:2 htb rate 125Mbit ceil 1250Mbit
 qdisc add dev eth1 parent 10:3 handle 13: htb default 2
 class add dev eth1 parent 13: classid 13:1 htb rate 1250Mbit
 class add dev eth1 parent 13:1 classid 13:2 htb rate 125Mbit ceil 1250Mbit
 qdisc add dev eth1 parent 10:4 handle 14: htb default 2
 class add dev eth1 parent 14: classid 14:1 htb rate 1250Mbit
 class add dev eth1 parent 14:1 classid 14:2 htb rate 125Mbit ceil 1250Mbit
 qdisc add dev eth1 parent 10:5 handle 15: htb default 2
 class add dev eth1 parent 15: classid 15:1 htb rate 1250Mbit
 class add dev eth1 parent 15:1 classid 15:2 htb rate 125Mbit ceil 1250Mbit
 qdisc add dev eth1 parent 10:6 handle 16: htb default 2
 class add dev eth1 parent 16: classid 16:1 htb rate 1250Mbit
 class add dev eth1 parent 16:1 classid 16:2 htb rate 125Mbit ceil 1250Mbit
 qdisc add dev eth1 parent 10:7 handle 17: htb default 2
 class add dev eth1 parent 17: classid 17:1 htb rate 1250Mbit
 class add dev eth1 parent 17:1 classid 17:2 htb rate 125Mbit ceil 1250Mbit
 qdisc add dev eth1 parent 10:8 handle 18: htb default 2
 class add dev eth1 parent 18: classid 18:1 htb rate 1250Mbit
 class add dev eth1 parent 18:1 classid 18:2 htb rate 125Mbit ceil 1250Mbit

 #one leaf class with pfifo qdisc per customer
 class add dev eth0 parent 16:1 classid 16:1237 htb rate 1024kbit
 qdisc add dev eth0 parent 16:1237 handle 1237 pfifo limit 50
 class add dev eth1 parent 16:1 classid 16:1237 htb rate 1024kbit
 qdisc add dev eth1 parent 16:1237 handle 1237 pfifo limit 50
 class add dev eth0 parent 15:1 classid 15:1244 htb rate 512kbit
 qdisc add dev eth0 parent 15:1244 handle 1244 pfifo limit 50
 class add dev eth1 parent 15:1 classid 15:1244 htb rate 512kbit
 qdisc add dev eth1 parent 15:1244 handle 1244 pfifo limit 50
 class add dev eth0 parent 18:1 classid 18:1191 htb rate 4096kbit
 qdisc add dev eth0 parent 18:1191 handle 1191 pfifo limit 50
 class add dev eth1 parent 18:1 classid 18:1191 htb rate 4096kbit
 qdisc add dev eth1 parent 18:1191 handle 1191 pfifo limit 50
 class add dev eth0 parent 12:1 classid 12:1193 htb rate 40960kbit
 qdisc add dev eth0 parent 12:1193 handle 1193 pfifo limit 50
 class add dev eth1 parent 12:1 classid 12:1193 htb rate 40960kbit
 qdisc add dev eth1 parent 12:1193 handle 1193 pfifo limit 50
 class add dev eth0 parent 13:1 classid 13:1194 htb rate 2048kbit
 qdisc add dev eth0 parent 13:1194 handle 1194 pfifo limit 50
 ...skip several hundreds line...

#classifier on u32 filter with hashing.

#my own network
 filter add dev eth0 protocol ip prio 5 parent 10:0 handle ::1 u32
match ip src 87.244.0.0/24 classid 11:3 action skbedit queue_mapping 1
priority 11:2
 filter add dev eth1 protocol ip prio 5 parent 10:0 handle ::1 u32
match ip dst 87.244.0.0/24 classid 11:3 action skbedit queue_mapping 1
priority 11:2

#hash table per subnet
# 217
 filter add dev eth0 protocol ip prio 5 parent 10:0 handle 100: u32 divisor 256
 filter add dev eth1 protocol ip prio 5 parent 10:0 handle 100: u32 divisor 256
# 10.
 filter add dev eth0 protocol ip prio 5 parent 10:0 handle 200: u32 divisor 256
 filter add dev eth1 protocol ip prio 5 parent 10:0 handle 200: u32 divisor 256
# 87.244
 filter add dev eth0 protocol ip prio 5 parent 10:0 handle 400: u32 divisor 256
 filter add dev eth1 protocol ip prio 5 parent 10:0 handle 400: u32 divisor 256
# 195.208.174
 filter add dev eth0 protocol ip prio 5 parent 10:0 handle 500: u32 divisor 256
 filter add dev eth1 protocol ip prio 5 parent 10:0 handle 500: u32 divisor 256

 filter add dev eth0 protocol ip prio 5 parent 10:0 u32 ht 800:: match
ip dst 217.170.112.0/20 hashkey mask 0x0000ff00 at 16 link 100:
 filter add dev eth1 protocol ip prio 5 parent 10:0 u32 ht 800:: match
ip src 217.170.112.0/20 hashkey mask 0x0000ff00 at 12 link 100:
 filter add dev eth0 protocol ip prio 5 parent 10:0 u32 ht 800:: match
ip dst 87.244.0.0/18 hashkey mask 0x0000ff00 at 16 link 400:
 filter add dev eth1 protocol ip prio 5 parent 10:0 u32 ht 800:: match
ip src 87.244.0.0/18 hashkey mask 0x0000ff00 at 12 link 400:
 filter add dev eth0 protocol ip prio 5 parent 10:0 u32 ht 800:: match
ip dst 10.245.0.0/22 hashkey mask 0x0000ff00 at 16 link 200:
 filter add dev eth1 protocol ip prio 5 parent 10:0 u32 ht 800:: match
ip src 10.245.0.0/22 hashkey mask 0x0000ff00 at 12 link 200:
 filter add dev eth0 protocol ip prio 5 parent 10:0 u32 ht 800:: match
ip dst 195.208.174.0/24 hashkey mask 0x0000ff00 at 16 link 500:
 filter add dev eth1 protocol ip prio 5 parent 10:0 u32 ht 800:: match
ip src 195.208.174.0/24 hashkey mask 0x0000ff00 at 12 link 500:

 filter add dev eth0 protocol ip prio 5 parent 10:0 handle 1: u32 divisor 256
 filter add dev eth1 protocol ip prio 5 parent 10:0 handle 1: u32 divisor 256
 filter add dev eth0 protocol ip prio 5 parent 10:0 u32 ht 400:0:
match ip dst 87.244.0.0/24 hashkey mask 0x000000ff at 16 link 1:
 filter add dev eth1 protocol ip prio 5 parent 10:0 u32 ht 400:0:
match ip src 87.244.0.0/24 hashkey mask 0x000000ff at 12 link 1:
 filter add dev eth0 protocol ip prio 5 parent 10:0 handle 2: u32 divisor 256
 filter add dev eth1 protocol ip prio 5 parent 10:0 handle 2: u32 divisor 256
 filter add dev eth0 protocol ip prio 5 parent 10:0 u32 ht 400:1:
match ip dst 87.244.1.0/24 hashkey mask 0x000000ff at 16 link 2:
 filter add dev eth1 protocol ip prio 5 parent 10:0 u32 ht 400:1:
match ip src 87.244.1.0/24 hashkey mask 0x000000ff at 12 link 2:

#fill the list of filters. one filter per ip (need to optimize! should
be filter per customer's subnet!)
#set priority! otherwise classifying is lost on enter to HTB qdisc!
 filter add dev eth0 protocol ip prio 5 parent 10:0 u32 ht 2:4: match
ip dst 87.244.1.4 classid 18:2911 action skbedit queue_mapping 7
priority 18:2911
 filter add dev eth1 protocol ip prio 5 parent 10:0 u32 ht 2:4: match
ip src 87.244.1.4 classid 18:2911 action skbedit queue_mapping 7
priority 18:2911
 filter add dev eth0 protocol ip prio 5 parent 10:0 u32 ht 2:5: match
ip dst 87.244.1.5 classid 18:2911 action skbedit queue_mapping 7
priority 18:2911
 filter add dev eth1 protocol ip prio 5 parent 10:0 u32 ht 2:5: match
ip src 87.244.1.5 classid 18:2911 action skbedit queue_mapping 7
priority 18:2911
 filter add dev eth0 protocol ip prio 5 parent 10:0 u32 ht 2:6: match
ip dst 87.244.1.6 classid 18:2911 action skbedit queue_mapping 7
priority 18:2911
 filter add dev eth1 protocol ip prio 5 parent 10:0 u32 ht 2:6: match
ip src 87.244.1.6 classid 18:2911 action skbedit queue_mapping 7
priority 18:2911
 filter add dev eth0 protocol ip prio 5 parent 10:0 u32 ht 2:7: match
ip dst 87.244.1.7 classid 18:2911 action skbedit queue_mapping 7
priority 18:2911
 filter add dev eth1 protocol ip prio 5 parent 10:0 u32 ht 2:7: match
ip src 87.244.1.7 classid 18:2911 action skbedit queue_mapping 7
priority 18:2911
 filter add dev eth0 protocol ip prio 5 parent 10:0 u32 ht 2:c: match
ip dst 87.244.1.12 classid 13:3306 action skbedit queue_mapping 2
priority 13:3306
 filter add dev eth1 protocol ip prio 5 parent 10:0 u32 ht 2:c: match
ip src 87.244.1.12 classid 13:3306 action skbedit queue_mapping 2
priority 13:3306
 filter add dev eth0 protocol ip prio 5 parent 10:0 u32 ht 2:d: match
ip dst 87.244.1.13 classid 13:3306 action skbedit queue_mapping 2
priority 13:3306
 filter add dev eth1 protocol ip prio 5 parent 10:0 u32 ht 2:d: match
ip src 87.244.1.13 classid 13:3306 action skbedit queue_mapping 2
priority 13:3306
 filter add dev eth0 protocol ip prio 5 parent 10:0 u32 ht 2:e: match
ip dst 87.244.1.14 classid 13:3306 action skbedit queue_mapping 2
priority 13:3306
...skip...


--
Anton.


-- 
Anton.
