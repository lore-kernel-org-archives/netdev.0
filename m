From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Some traffic stress testing with 4.13.0-rc4-next-20170808 and
 BUG: [61183.212237] BUG: Bad page state in process ksoftirqd/52 pfn:855f2f
Date: Wed, 9 Aug 2017 16:27:38 -0700
Message-ID: <CAM_iQpW908ri7ecz4ThD+fFESQoTvZLu-2Pu6wEtgHwGuca_1w@mail.gmail.com>
References: <9c49b487-2307-27ab-78cd-ed9ad8edbb65@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f179.google.com ([209.85.217.179]:32989 "EHLO
        mail-ua0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752120AbdHIX2A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 19:28:00 -0400
Received: by mail-ua0-f179.google.com with SMTP id 80so34837599uas.0
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 16:27:59 -0700 (PDT)
In-Reply-To: <9c49b487-2307-27ab-78cd-ed9ad8edbb65@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 9, 2017 at 8:50 AM, Pawe=C5=82 Staszewski <pstaszewski@itcare.p=
l> wrote:
>
>
>
> [60961.112120] BUG: Bad page state in process ksoftirqd/44 pfn:855f2f
> [60961.112123] page:ffffea002157cbc0 count:51910 mapcount:0 mapping:
> (null) index:0x0
> [60961.112259] flags: 0x600000000000000()
> [60961.112375] raw: 0600000000000000 0000000000000000 0000000000000000
> 0000cac6ffffffff
> [60961.112376] raw: dead000000000100 dead000000000200 0000000000000000
> 0000000000000000
> [60961.112377] page dumped because: nonzero _count
> [60961.112377] Modules linked in: sch_fq x86_pkg_temp_thermal ipmi_si
> [60961.112381] CPU: 44 PID: 232 Comm: ksoftirqd/44 Tainted: G B   W
> 4.13.0-rc4-next-20170808 #1
> [60961.112382] Call Trace:
> [60961.112390]  dump_stack+0x4d/0x63
> [60961.112394]  bad_page+0xf3/0x10f
> [60961.112396]  check_new_page_bad+0x73/0x75
> [60961.112397]  get_page_from_freelist+0x2a9/0x63f
> [60961.112398]  __alloc_pages_nodemask+0xf2/0x187
> [60961.112403]  alloc_pages_current+0x85/0x8c
> [60961.112405]  new_slab+0xc2/0x2f7
> [60961.112407]  ___slab_alloc+0x350/0x3cd
> [60961.112409]  ? fq_enqueue+0x24e/0x3e3 [sch_fq]
> [60961.112411]  __slab_alloc+0x12/0x17
> [60961.112412]  ? __slab_alloc+0x12/0x17
> [60961.112413]  kmem_cache_alloc+0x50/0x112
> [60961.112414]  fq_enqueue+0x24e/0x3e3 [sch_fq]
> [60961.112419]  ? ixgbe_select_queue+0x15/0x17
> [60961.112422]  __dev_queue_xmit+0x2a5/0x4b9
> [60961.112423]  dev_queue_xmit+0xb/0xd


Is this the first stack trace in your dmesg?

It doesn't look like a bug in sch_fq, but like we have
a bad mm page somewhere else, perhaps ixgbe driver.



> [60961.112423]  ? dev_queue_xmit+0xb/0xd
> [60961.112425]  vlan_dev_hard_start_xmit+0x81/0xaa
> [60961.112426]  dev_hard_start_xmit+0xc3/0x197
> [60961.112427]  __dev_queue_xmit+0x38d/0x4b9
> [60961.112429]  ? eth_header+0x27/0xab
> [60961.112429]  dev_queue_xmit+0xb/0xd
> [60961.112430]  ? dev_queue_xmit+0xb/0xd
> [60961.112432]  neigh_connected_output+0x9b/0xb2
> [60961.112436]  ip_finish_output2+0x24e/0x292
> [60961.112437]  ip_finish_output+0x11f/0x12b
> [60961.112438]  ip_output+0x56/0xa7
> [60961.112441]  ? ip_route_input_rcu+0x489/0x7d3
> [60961.112442]  ip_forward_finish+0x53/0x58
> [60961.112443]  ip_forward+0x2ff/0x350
> [60961.112443]  ? ip_frag_mem+0x1e/0x1e
> [60961.112444]  ip_rcv_finish+0x27f/0x28a
> [60961.112445]  ip_rcv+0x2c0/0x30d
> [60961.112448]  __netif_receive_skb_core+0x325/0x4c0
> [60961.112449]  __netif_receive_skb+0x18/0x5a
> [60961.112450]  ? dev_gro_receive+0x2a9/0x3b4
> [60961.112451]  ? __netif_receive_skb+0x18/0x5a
> [60961.112452]  netif_receive_skb_internal+0x4b/0x96
> [60961.112453]  napi_gro_receive+0x75/0xcc
> [60961.112455]  ixgbe_poll+0xed8/0xeef
> [60961.112459]  ? __printk_ratelimit+0x8/0x15
> [60961.112460]  net_rx_action+0xd3/0x22d
> [60961.112462]  __do_softirq+0xe4/0x23a
> [60961.112465]  ? sort_range+0x1d/0x1d
> [60961.112466]  run_ksoftirqd+0x15/0x2a
> [60961.112467]  smpboot_thread_fn+0x128/0x13f
> [60961.112470]  kthread+0xf7/0xfc
> [60961.112471]  ? init_completion+0x24/0x24
> [60961.112475]  ret_from_fork+0x22/0x30
> [60983.541418] capability: warning: `turbostat' uses 32-bit capabilities
> (legacy support in use)
> [61179.159683] ixgbe 0000:d8:00.1 enp216s0f1: detected SFP+: 4
> [61179.503705] ixgbe 0000:d8:00.1 enp216s0f1: NIC Link is Up 10 Gbps, Flo=
w
> Control: None
> [61183.212237] BUG: Bad page state in process ksoftirqd/52 pfn:855f2f
> [61183.212240] page:ffffea002157cbc0 count:-1 mapcount:0 mapping:
> (null) index:0x0
> [61183.212375] flags: 0x600000000000000()
> [61183.212492] raw: 0600000000000000 0000000000000000 0000000000000000
> ffffffffffffffff
> [61183.212493] raw: dead000000000100 dead000000000200 0000000000000000
> 0000000000000000
> [61183.212493] page dumped because: nonzero _count
> [61183.212494] Modules linked in: sch_fq x86_pkg_temp_thermal ipmi_si
> [61183.212498] CPU: 52 PID: 272 Comm: ksoftirqd/52 Tainted: G B   W
> 4.13.0-rc4-next-20170808 #1
> [61183.212500] Call Trace:
> [61183.212507]  dump_stack+0x4d/0x63
> [61183.212512]  bad_page+0xf3/0x10f
> [61183.212514]  check_new_page_bad+0x73/0x75
> [61183.212515]  get_page_from_freelist+0x2a9/0x63f
> [61183.212517]  __alloc_pages_nodemask+0xf2/0x187
> [61183.212523]  ixgbe_alloc_rx_buffers+0x77/0x1bb
> [61183.212524]  ixgbe_poll+0x421/0xeef
> [61183.212529]  ? cfs_rq_util_change+0x1e/0x20
> [61183.212532]  net_rx_action+0xd3/0x22d
> [61183.212534]  __do_softirq+0xe4/0x23a
> [61183.212536]  ? sort_range+0x1d/0x1d
> [61183.212537]  run_ksoftirqd+0x15/0x2a
> [61183.212538]  smpboot_thread_fn+0x128/0x13f
> [61183.212540]  kthread+0xf7/0xfc
> [61183.212541]  ? init_completion+0x24/0x24
> [61183.212546]  ret_from_fork+0x22/0x30
> [61183.283732] ixgbe 0000:d8:00.0 enp216s0f0: detected SFP+: 3
> [61183.527747] ixgbe 0000:d8:00.0 enp216s0f0: NIC Link is Up 10 Gbps, Flo=
w
> Control: None
> [61223.651684] ixgbe 0000:d8:00.1 enp216s0f1: detected SFP+: 4
> [61223.891712] ixgbe 0000:d8:00.1 enp216s0f1: NIC Link is Up 10 Gbps, Flo=
w
> Control: None
> [61228.651748] ixgbe 0000:d8:00.0 enp216s0f0: detected SFP+: 3
> [61228.891759] ixgbe 0000:d8:00.0 enp216s0f0: NIC Link is Up 10 Gbps, Flo=
w
> Control: None
> [61408.583698] ixgbe 0000:d8:00.1 enp216s0f1: detected SFP+: 4
> [61408.831720] ixgbe 0000:d8:00.1 enp216s0f1: NIC Link is Up 10 Gbps, Flo=
w
> Control: None
> [61414.003718] ixgbe 0000:d8:00.0 enp216s0f0: detected SFP+: 3
> [61414.247764] ixgbe 0000:d8:00.0 enp216s0f0: NIC Link is Up 10 Gbps, Flo=
w
> Control: None
> [63318.496105] igb 0000:18:00.3 enp24s0f3: Reset adapter
> [63321.828156] igb 0000:18:00.3 enp24s0f3: igb: enp24s0f3 NIC Link is Up
> 1000 Mbps Full Duplex, Flow Control: RX
>
>
>
>
>
> If matters configuration below:
>
>  tc -s -d qdisc show
> qdisc noqueue 0: dev lo root refcnt 2
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> qdisc mq 0: dev enp24s0f3 root
>  Sent 10595979 bytes 44275 pkt (dropped 0, overlimits 0 requeues 7)
>  backlog 0b 0p requeues 7
> qdisc pfifo_fast 0: dev enp24s0f3 parent :8 bands 3 priomap  1 2 2 2 1 2 =
0 0
> 1 1 1 1 1 1 1 1
>  Sent 2562064 bytes 7304 pkt (dropped 0, overlimits 0 requeues 1)
>  backlog 0b 0p requeues 1
> qdisc pfifo_fast 0: dev enp24s0f3 parent :7 bands 3 priomap  1 2 2 2 1 2 =
0 0
> 1 1 1 1 1 1 1 1
>  Sent 152292 bytes 3589 pkt (dropped 0, overlimits 0 requeues 2)
>  backlog 0b 0p requeues 2
> qdisc pfifo_fast 0: dev enp24s0f3 parent :6 bands 3 priomap  1 2 2 2 1 2 =
0 0
> 1 1 1 1 1 1 1 1
>  Sent 7298 bytes 15 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> qdisc pfifo_fast 0: dev enp24s0f3 parent :5 bands 3 priomap  1 2 2 2 1 2 =
0 0
> 1 1 1 1 1 1 1 1
>  Sent 5042 bytes 5 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> qdisc pfifo_fast 0: dev enp24s0f3 parent :4 bands 3 priomap  1 2 2 2 1 2 =
0 0
> 1 1 1 1 1 1 1 1
>  Sent 3194 bytes 4 pkt (dropped 0, overlimits 0 requeues 1)
>  backlog 0b 0p requeues 1
> qdisc pfifo_fast 0: dev enp24s0f3 parent :3 bands 3 priomap  1 2 2 2 1 2 =
0 0
> 1 1 1 1 1 1 1 1
>  Sent 5386576 bytes 13206 pkt (dropped 0, overlimits 0 requeues 1)
>  backlog 0b 0p requeues 1
> qdisc pfifo_fast 0: dev enp24s0f3 parent :2 bands 3 priomap  1 2 2 2 1 2 =
0 0
> 1 1 1 1 1 1 1 1
>  Sent 6286 bytes 24 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> qdisc pfifo_fast 0: dev enp24s0f3 parent :1 bands 3 priomap  1 2 2 2 1 2 =
0 0
> 1 1 1 1 1 1 1 1
>  Sent 2473227 bytes 20128 pkt (dropped 0, overlimits 0 requeues 2)
>  backlog 0b 0p requeues 2
> qdisc mq 1: dev enp216s0f0 root
>  Sent 140 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> qdisc fq 831c: dev enp216s0f0 parent 1:a limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   0 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 0 throttled
> qdisc fq 8320: dev enp216s0f0 parent 1:e limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   0 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 0 throttled
> qdisc fq 831e: dev enp216s0f0 parent 1:c limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   0 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 0 throttled
> qdisc fq 8322: dev enp216s0f0 parent 1:10 limit 8192p flow_limit 100p
> buckets 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate
> 10Gbit refill_delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   0 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 0 throttled
> qdisc fq 8313: dev enp216s0f0 parent 1:1 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   0 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 0 throttled
> qdisc fq 8315: dev enp216s0f0 parent 1:3 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   0 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 0 throttled
> qdisc fq 8317: dev enp216s0f0 parent 1:5 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   0 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 0 throttled
> qdisc fq 831b: dev enp216s0f0 parent 1:9 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   0 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 0 throttled
> qdisc fq 8319: dev enp216s0f0 parent 1:7 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 140 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   1 flows (1 inactive, 0 throttled)
>   0 gc, 0 highprio, 0 throttled
> qdisc fq 831d: dev enp216s0f0 parent 1:b limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   0 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 0 throttled
> qdisc fq 831f: dev enp216s0f0 parent 1:d limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   0 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 0 throttled
> qdisc fq 8321: dev enp216s0f0 parent 1:f limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   0 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 0 throttled
> qdisc fq 8316: dev enp216s0f0 parent 1:4 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   0 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 0 throttled
> qdisc fq 8314: dev enp216s0f0 parent 1:2 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   0 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 0 throttled
> qdisc fq 8318: dev enp216s0f0 parent 1:6 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   0 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 0 throttled
> qdisc fq 831a: dev enp216s0f0 parent 1:8 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   0 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 0 throttled
> qdisc mq 1: dev enp216s0f1 root
>  Sent 5724464060294 bytes 3017574303 pkt (dropped 261703917, overlimits 0
> requeues 1588)
>  backlog 19340684b 68101p requeues 1588
> qdisc fq 8331: dev enp216s0f1 parent 1:f limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 357754034478 bytes 1261904590 pkt (dropped 16345926, overlimits 0
> requeues 99)
>  backlog 1190528b 4198p requeues 99
>   64 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 15 throttled, 2238 ns latency, 16345926 flows_plimit
> qdisc fq 8324: dev enp216s0f1 parent 1:2 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 357941986556 bytes 1265190082 pkt (dropped 16334441, overlimits 0
> requeues 114)
>  backlog 1203308b 4237p requeues 114
>   64 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 56 throttled, 1988 ns latency, 16334441 flows_plimit
> qdisc fq 8326: dev enp216s0f1 parent 1:4 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 357756741808 bytes 1261951272 pkt (dropped 16352852, overlimits 0
> requeues 108)
>  backlog 1195356b 4210p requeues 108
>   64 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 10 throttled, 1652 ns latency, 16352852 flows_plimit
> qdisc fq 832a: dev enp216s0f1 parent 1:8 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 357754168172 bytes 1261906634 pkt (dropped 16375523, overlimits 0
> requeues 93)
>  backlog 1191664b 4196p requeues 93
>   64 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 4 throttled, 1722 ns latency, 16375523 flows_plimit
> qdisc fq 8328: dev enp216s0f1 parent 1:6 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 357755800928 bytes 1261934832 pkt (dropped 16297692, overlimits 0
> requeues 89)
>  backlog 1206432b 4248p requeues 89
>   65 flows (1 inactive, 0 throttled)
>   0 gc, 0 highprio, 4 throttled, 1520 ns latency, 16297692 flows_plimit
> qdisc fq 832c: dev enp216s0f1 parent 1:a limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 357757943172 bytes 1261969807 pkt (dropped 16393936, overlimits 0
> requeues 97)
>  backlog 1185984b 4176p requeues 97
>   64 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 4 throttled, 1257 ns latency, 16393936 flows_plimit
> qdisc fq 832e: dev enp216s0f1 parent 1:c limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 357754956814 bytes 1261920403 pkt (dropped 16373257, overlimits 0
> requeues 111)
>  backlog 1184848b 4172p requeues 111
>   65 flows (1 inactive, 0 throttled)
>   0 gc, 0 highprio, 11 throttled, 2070 ns latency, 16373257 flows_plimit
> qdisc fq 8332: dev enp216s0f1 parent 1:10 limit 8192p flow_limit 100p
> buckets 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate
> 10Gbit refill_delay 40.0ms
>  Sent 357754779582 bytes 1261916755 pkt (dropped 16306559, overlimits 0
> requeues 80)
>  backlog 1151336b 4054p requeues 80
>   65 flows (1 inactive, 0 throttled)
>   0 gc, 0 highprio, 3 throttled, 1530 ns latency, 16306559 flows_plimit
> qdisc fq 8330: dev enp216s0f1 parent 1:e limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 357754801422 bytes 1261919138 pkt (dropped 16360298, overlimits 0
> requeues 68)
>  backlog 1266072b 4457p requeues 68
>   64 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 7 throttled, 1114 ns latency, 16360298 flows_plimit
> qdisc fq 8325: dev enp216s0f1 parent 1:3 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 357756968400 bytes 1261953663 pkt (dropped 16377069, overlimits 0
> requeues 84)
>  backlog 1267492b 4463p requeues 84
>   64 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 6 throttled, 2470 ns latency, 16377069 flows_plimit
> qdisc fq 8323: dev enp216s0f1 parent 1:1 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 357944308424 bytes 1265224502 pkt (dropped 16351766, overlimits 0
> requeues 125)
>  backlog 1227164b 4321p requeues 125
>   65 flows (1 inactive, 0 throttled)
>   0 gc, 0 highprio, 58 throttled, 2143 ns latency, 16351766 flows_plimit
> qdisc fq 8327: dev enp216s0f1 parent 1:5 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 357756634544 bytes 1261949446 pkt (dropped 16354220, overlimits 0
> requeues 114)
>  backlog 1176896b 4143p requeues 114
>   64 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 5 throttled, 2274 ns latency, 16354220 flows_plimit
> qdisc fq 8329: dev enp216s0f1 parent 1:7 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 357755020876 bytes 1261921756 pkt (dropped 16366535, overlimits 0
> requeues 108)
>  backlog 1171216b 4124p requeues 108
>   65 flows (1 inactive, 0 throttled)
>   0 gc, 0 highprio, 3 throttled, 932 ns latency, 16366535 flows_plimit
> qdisc fq 832d: dev enp216s0f1 parent 1:b limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 357755470474 bytes 1261930198 pkt (dropped 16347462, overlimits 0
> requeues 99)
>  backlog 1255848b 4422p requeues 99
>   64 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 5 throttled, 1699 ns latency, 16347462 flows_plimit
> qdisc fq 832b: dev enp216s0f1 parent 1:9 limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 357754977102 bytes 1261920885 pkt (dropped 16407954, overlimits 0
> requeues 92)
>  backlog 1260108b 4437p requeues 92
>   64 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 5 throttled, 1638 ns latency, 16407954 flows_plimit
> qdisc fq 832f: dev enp216s0f1 parent 1:d limit 8192p flow_limit 100p buck=
ets
> 1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 maxrate 10Gbit
> refill_delay 40.0ms
>  Sent 357755499918 bytes 1261929638 pkt (dropped 16358427, overlimits 0
> requeues 107)
>  backlog 1194220b 4205p requeues 107
>   64 flows (0 inactive, 0 throttled)
>   0 gc, 0 highprio, 8 throttled, 2257 ns latency, 16358427 flows_plimit
> qdisc noqueue 0: dev vlan1000 root refcnt 2
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>
>  ethtool -k enp216s0f1
> Features for enp216s0f1:
> Cannot get device udp-fragmentation-offload settings: Operation not
> supported
> rx-checksumming: on
> tx-checksumming: on
>         tx-checksum-ipv4: off [fixed]
>         tx-checksum-ip-generic: on
>         tx-checksum-ipv6: off [fixed]
>         tx-checksum-fcoe-crc: off [fixed]
>         tx-checksum-sctp: on
> scatter-gather: on
>         tx-scatter-gather: on
>         tx-scatter-gather-fraglist: off [fixed]
> tcp-segmentation-offload: on
>         tx-tcp-segmentation: on
>         tx-tcp-ecn-segmentation: off [fixed]
>         tx-tcp-mangleid-segmentation: on
>         tx-tcp6-segmentation: on
> udp-fragmentation-offload: off
> generic-segmentation-offload: off
> generic-receive-offload: on
> large-receive-offload: off
> rx-vlan-offload: on
> tx-vlan-offload: on
> ntuple-filters: on
> receive-hashing: on
> highdma: on [fixed]
> rx-vlan-filter: on
> vlan-challenged: off [fixed]
> tx-lockless: off [fixed]
> netns-local: off [fixed]
> tx-gso-robust: off [fixed]
> tx-fcoe-segmentation: off [fixed]
> tx-gre-segmentation: on
> tx-gre-csum-segmentation: on
> tx-ipxip4-segmentation: on
> tx-ipxip6-segmentation: on
> tx-udp_tnl-segmentation: on
> tx-udp_tnl-csum-segmentation: on
> tx-gso-partial: on
> tx-sctp-segmentation: off [fixed]
> tx-esp-segmentation: off [fixed]
> fcoe-mtu: off [fixed]
> tx-nocache-copy: on
> loopback: off [fixed]
> rx-fcs: off [fixed]
> rx-all: off
> tx-vlan-stag-hw-insert: off [fixed]
> rx-vlan-stag-hw-parse: off [fixed]
> rx-vlan-stag-filter: off [fixed]
> l2-fwd-offload: off
> hw-tc-offload: on
> esp-hw-offload: off [fixed]
> esp-tx-csum-hw-offload: off [fixed]
> rx-udp_tunnel-port-offload: on
>
>  ethtool -k enp216s0f0
> Features for enp216s0f0:
> Cannot get device udp-fragmentation-offload settings: Operation not
> supported
> rx-checksumming: on
> tx-checksumming: on
>         tx-checksum-ipv4: off [fixed]
>         tx-checksum-ip-generic: on
>         tx-checksum-ipv6: off [fixed]
>         tx-checksum-fcoe-crc: off [fixed]
>         tx-checksum-sctp: on
> scatter-gather: on
>         tx-scatter-gather: on
>         tx-scatter-gather-fraglist: off [fixed]
> tcp-segmentation-offload: on
>         tx-tcp-segmentation: on
>         tx-tcp-ecn-segmentation: off [fixed]
>         tx-tcp-mangleid-segmentation: on
>         tx-tcp6-segmentation: on
> udp-fragmentation-offload: off
> generic-segmentation-offload: off
> generic-receive-offload: on
> large-receive-offload: off
> rx-vlan-offload: on
> tx-vlan-offload: on
> ntuple-filters: on
> receive-hashing: on
> highdma: on [fixed]
> rx-vlan-filter: on
> vlan-challenged: off [fixed]
> tx-lockless: off [fixed]
> netns-local: off [fixed]
> tx-gso-robust: off [fixed]
> tx-fcoe-segmentation: off [fixed]
> tx-gre-segmentation: on
> tx-gre-csum-segmentation: on
> tx-ipxip4-segmentation: on
> tx-ipxip6-segmentation: on
> tx-udp_tnl-segmentation: on
> tx-udp_tnl-csum-segmentation: on
> tx-gso-partial: on
> tx-sctp-segmentation: off [fixed]
> tx-esp-segmentation: off [fixed]
> fcoe-mtu: off [fixed]
> tx-nocache-copy: on
> loopback: off [fixed]
> rx-fcs: off [fixed]
> rx-all: off
> tx-vlan-stag-hw-insert: off [fixed]
> rx-vlan-stag-hw-parse: off [fixed]
> rx-vlan-stag-filter: off [fixed]
> l2-fwd-offload: off
> hw-tc-offload: off
> esp-hw-offload: off [fixed]
> esp-tx-csum-hw-offload: off [fixed]
> rx-udp_tunnel-port-offload: on
>
>
