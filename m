From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: WARNING: CPU: 21 PID: 116 at net/sched/sch_generic.c:320
 dev_watchdog+0xc5/0x122
Date: Sun, 10 Sep 2017 15:09:31 +0200
Message-ID: <9b7d081a-79e7-ad8d-6d5a-88425fc9c817@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp16.iq.pl ([86.111.242.222]:53703 "EHLO smtp16.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751469AbdIJNLY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 10 Sep 2017 09:11:24 -0400
Received: from [192.168.2.200] (unknown [185.78.72.19])
        (Authenticated sender: pstaszewski@itcare.pl)
        by smtp.iq.pl (Postfix) with ESMTPSA id 3xqrzZ30lXz3xBG
        for <netdev@vger.kernel.org>; Sun, 10 Sep 2017 15:11:22 +0200 (CEST)
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With latest 4.13.0+ kernel



Hardware(Tested HOST where traces catched:
Intel E5-2670
Network controllers
2x 10G Intel 82599
1x 100G Mellanox Connectx-5

Test scenario:
Packet generator -> (RX traffix on Mellanox 100G / 12Mpps UDP random 
destination ip / random port ) Tested HOST (TX traffix from Intel 82599 
on 20 vlans attached to ethernet) -> Sink

[  115.676048] NETDEV WATCHDOG: enp6s0f0 (ixgbe): transmit queue 21 
timed out
[  115.676061] ------------[ cut here ]------------
[  115.676067] WARNING: CPU: 21 PID: 116 at net/sched/sch_generic.c:320 
dev_watchdog+0xc5/0x122
[  115.676067] Modules linked in: ipmi_si x86_pkg_temp_thermal
[  115.676072] CPU: 21 PID: 116 Comm: ksoftirqd/21 Not tainted 4.13.0+ #3
[  115.676073] task: ffff88046d40e800 task.stack: ffffc90003640000
[  115.676074] RIP: 0010:dev_watchdog+0xc5/0x122
[  115.676075] RSP: 0018:ffffc90003643da0 EFLAGS: 00010286
[  115.676076] RAX: 000000000000003e RBX: ffff88086d010000 RCX: 
0000000000000000
[  115.676077] RDX: ffff88046fd53310 RSI: ffff88046fd4ca98 RDI: 
ffff88046fd4ca98
[  115.676078] RBP: ffffc90003643db0 R08: 0000000000000000 R09: 
0000000000000000
[  115.676079] R10: ffffc90003643e38 R11: ffffffff81e27ddc R12: 
0000000000000015
[  115.676079] R13: ffffffff8164fdfa R14: ffff88086d010438 R15: 
ffff88086d010000
[  115.676081] FS:  0000000000000000(0000) GS:ffff88046fd40000(0000) 
knlGS:0000000000000000
[  115.676081] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  115.676082] CR2: 00007f225204e8c8 CR3: 000000086a6ff004 CR4: 
00000000000606e0
[  115.676083] Call Trace:
[  115.676087]  call_timer_fn+0x5b/0x123
[  115.676089]  run_timer_softirq+0x13b/0x15e
[  115.676091]  ? pick_next_task_fair+0x1ad/0x2f6
[  115.676095]  __do_softirq+0xe4/0x23a
[  115.676097]  ? sort_range+0x1d/0x1d
[  115.676101]  run_ksoftirqd+0x15/0x2a
[  115.676102]  smpboot_thread_fn+0x128/0x13f
[  115.676104]  kthread+0xf7/0xfc
[  115.676106]  ? __init_completion+0x24/0x24
[  115.676109]  ret_from_fork+0x22/0x30
[  115.676109] Code: 0f a8 69 00 00 75 38 48 89 df c6 05 03 a8 69 00 01 
e8 cb f5 fd ff 44 89 e1 48 89 de 48 c7 c7 0a 9e ae 81 48 89 c2 e8 7a 16 
a2 ff <0f> ff eb 10 41 ff c4 48 05 40 01 00 00 41 39 f4 75 9a eb 0d 48
[  115.676128] ---[ end trace 4d5f38095306e2dd ]---


[  115.676131] ixgbe 0000:06:00.0 enp6s0f0: initiating reset due to tx 
timeout
[  115.676212] ixgbe 0000:06:00.0 enp6s0f0: Reset adapter
[  116.068428] ixgbe 0000:06:00.0 enp6s0f0: detected SFP+: 3
[  116.217023] ixgbe 0000:06:00.0 enp6s0f0: NIC Link is Up 10 Gbps, Flow 
Control: RX/TX
[  120.444122] ixgbe 0000:06:00.0 enp6s0f0: Detected Tx Unit Hang
                  Tx Queue             <20>
                  TDH, TDT             <d7>, <39>
                  next_to_use          <39>
                  next_to_clean        <d7>
                tx_buffer_info[next_to_clean]
                  time_stamp           <ffff4ca7>
                  jiffies              <ffff50a8>
[  120.444127] ixgbe 0000:06:00.0 enp6s0f0: tx hang 5 detected on queue 
20, resetting adapter
[  120.444128] ixgbe 0000:06:00.0 enp6s0f0: initiating reset due to tx 
timeout
[  120.444135] ixgbe 0000:06:00.0 enp6s0f0: Reset adapter


[ 2929.465026] ------------[ cut here ]------------
[ 2929.465035] WARNING: CPU: 5 PID: 35 at kernel/rcu/tree.c:2715 
rcu_process_callbacks+0x327/0x36f
[ 2929.465035] Modules linked in: ipmi_si x86_pkg_temp_thermal
[ 2929.465040] CPU: 5 PID: 35 Comm: ksoftirqd/5 Tainted: G W       
4.13.0+ #3
[ 2929.465042] task: ffff88046dadb400 task.stack: ffffc900033b8000
[ 2929.465044] RIP: 0010:rcu_process_callbacks+0x327/0x36f
[ 2929.465045] RSP: 0018:ffffc900033bbe00 EFLAGS: 00010002
[ 2929.465047] RAX: 0000000000000246 RBX: ffff88046fb59840 RCX: 
ffffffffffffd801
[ 2929.465048] RDX: 0000000000000000 RSI: ffffc900033bbe18 RDI: 
ffff88046fb59878
[ 2929.465049] RBP: ffffc900033bbe60 R08: 0000000000000001 R09: 
ffffffff81633d20
[ 2929.465050] R10: ffffc900033bbda8 R11: ffffea0011852c80 R12: 
ffffffff81c41b00
[ 2929.465051] R13: ffffc900033bbe18 R14: ffff88046fb59878 R15: 
ffff88046dadb400
[ 2929.465053] FS:  0000000000000000(0000) GS:ffff88046fb40000(0000) 
knlGS:0000000000000000
[ 2929.465054] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 2929.465055] CR2: 00007fca94a07349 CR3: 000000086a6ff000 CR4: 
00000000000606e0
[ 2929.465056] Call Trace:
[ 2929.465060]  ? net_rx_action+0x21e/0x22d
[ 2929.465064]  __do_softirq+0xe4/0x23a
[ 2929.465066]  ? sort_range+0x1d/0x1d
[ 2929.465070]  run_ksoftirqd+0x15/0x2a
[ 2929.465071]  smpboot_thread_fn+0x128/0x13f
[ 2929.465074]  kthread+0xf7/0xfc
[ 2929.465075]  ? __init_completion+0x24/0x24
[ 2929.465078]  ret_from_fork+0x22/0x30
[ 2929.465079] Code: 8b 8b 90 00 00 00 48 2b 0d b7 54 bc 00 48 39 ca 7d 
07 48 89 93 90 00 00 00 48 83 7b 38 00 0f 94 c1 48 85 d2 0f 94 c2 38 d1 
74 02 <0f> ff 50 9d 4c 89 f7 e8 7e 22 00 00 84 c0 74 09 e8 06 f1 ff ff
[ 2929.465107] ---[ end trace 4d5f38095306e2de ]---
[ 2929.509019] ixgbe 0000:06:00.0 enp6s0f0: NIC Link is Up 10 Gbps, Flow 
Control: RX/TX
[ 2929.512261] BUG: Bad page state in process ksoftirqd/21 pfn:45c020
[ 2929.512264] page:ffffea0011700800 count:-1 mapcount:0 
mapping:          (null) index:0x0
[ 2929.512947] flags: 0x2000000000000000()
[ 2929.513202] raw: 2000000000000000 0000000000000000 0000000000000000 
ffffffffffffffff
[ 2929.513204] raw: dead000000000100 dead000000000200 0000000000000000 
0000000000000000
[ 2929.513205] page dumped because: nonzero _count
[ 2929.513205] Modules linked in: ipmi_si x86_pkg_temp_thermal
[ 2929.513210] CPU: 21 PID: 116 Comm: ksoftirqd/21 Tainted: G        
W       4.13.0+ #3
[ 2929.513210] Call Trace:
[ 2929.513215]  dump_stack+0x4d/0x63
[ 2929.513218]  bad_page+0xf3/0x10f
[ 2929.513220]  check_new_page_bad+0x73/0x75
[ 2929.513222]  get_page_from_freelist+0x419/0x63f
[ 2929.513225]  __alloc_pages_nodemask+0xef/0x182
[ 2929.513227]  page_frag_alloc+0x38/0x10c
[ 2929.513230]  __napi_alloc_skb+0x6a/0xbd
[ 2929.513234]  mlx5e_handle_rx_cqe_mpwrq+0x91/0x388
[ 2929.513236]  mlx5e_poll_rx_cq+0x113/0x171
[ 2929.513238]  mlx5e_napi_poll+0x81/0x149
[ 2929.513240]  net_rx_action+0xd3/0x22d
[ 2929.513242]  __do_softirq+0xe4/0x23a
[ 2929.513244]  ? sort_range+0x1d/0x1d
[ 2929.513247]  run_ksoftirqd+0x15/0x2a
[ 2929.513248]  smpboot_thread_fn+0x128/0x13f
[ 2929.513250]  kthread+0xf7/0xfc
[ 2929.513252]  ? __init_completion+0x24/0x24
[ 2929.513254]  ret_from_fork+0x22/0x30
[ 2929.513255] Disabling lock debugging due to kernel taint
[ 2929.514165] BUG: Bad page state in process ksoftirqd/16 pfn:45d020
[ 2929.514168] page:ffffea0011740800 count:-1 mapcount:0 
mapping:          (null) index:0x0
[ 2929.514640] flags: 0x2000000000000000()
[ 2929.514898] raw: 2000000000000000 0000000000000000 0000000000000000 
ffffffffffffffff
[ 2929.514900] raw: dead000000000100 dead000000000200 0000000000000000 
0000000000000000
[ 2929.514901] page dumped because: nonzero _count
[ 2929.514901] Modules linked in: ipmi_si x86_pkg_temp_thermal
[ 2929.514905] CPU: 16 PID: 91 Comm: ksoftirqd/16 Tainted: G B   W       
4.13.0+ #3
[ 2929.514906] Call Trace:
[ 2929.514910]  dump_stack+0x4d/0x63
[ 2929.514913]  bad_page+0xf3/0x10f
[ 2929.514915]  check_new_page_bad+0x73/0x75
[ 2929.514917]  get_page_from_freelist+0x419/0x63f
[ 2929.514919]  __alloc_pages_nodemask+0xef/0x182
[ 2929.514922]  page_frag_alloc+0x38/0x10c
[ 2929.514924]  __napi_alloc_skb+0x6a/0xbd
[ 2929.514927]  mlx5e_handle_rx_cqe_mpwrq+0x91/0x388
[ 2929.514930]  mlx5e_poll_rx_cq+0x113/0x171
[ 2929.514932]  mlx5e_napi_poll+0x81/0x149
[ 2929.514934]  net_rx_action+0xd3/0x22d
[ 2929.514936]  __do_softirq+0xe4/0x23a
[ 2929.514938]  ? sort_range+0x1d/0x1d
[ 2929.514941]  run_ksoftirqd+0x15/0x2a
[ 2929.514942]  smpboot_thread_fn+0x128/0x13f
[ 2929.514944]  kthread+0xf7/0xfc
[ 2929.514946]  ? __init_completion+0x24/0x24
[ 2929.514948]  ret_from_fork+0x22/0x30
[ 2929.517505] BUG: Bad page state in process ksoftirqd/17 pfn:46a320
[ 2929.517508] page:ffffea0011a8c800 count:-1 mapcount:0 
mapping:          (null) index:0x0
[ 2929.517985] flags: 0x2000000000000000()
[ 2929.518247] raw: 2000000000000000 0000000000000000 0000000000000000 
ffffffffffffffff
[ 2929.518248] raw: dead000000000100 dead000000000200 0000000000000000 
0000000000000000
[ 2929.518249] page dumped because: nonzero _count
[ 2929.518250] Modules linked in: ipmi_si x86_pkg_temp_thermal
[ 2929.518254] CPU: 17 PID: 96 Comm: ksoftirqd/17 Tainted: G B   W       
4.13.0+ #3
[ 2929.518255] Call Trace:
[ 2929.518258]  dump_stack+0x4d/0x63
[ 2929.518261]  bad_page+0xf3/0x10f
[ 2929.518263]  check_new_page_bad+0x73/0x75
[ 2929.518265]  get_page_from_freelist+0x419/0x63f
[ 2929.518267]  __alloc_pages_nodemask+0xef/0x182
[ 2929.518269]  page_frag_alloc+0x38/0x10c
[ 2929.518272]  __napi_alloc_skb+0x6a/0xbd
[ 2929.518274]  mlx5e_handle_rx_cqe_mpwrq+0x91/0x388
[ 2929.518276]  ? skb_release_all+0x1f/0x22
[ 2929.518278]  mlx5e_poll_rx_cq+0x113/0x171
[ 2929.518280]  mlx5e_napi_poll+0x81/0x149
[ 2929.518282]  net_rx_action+0xd3/0x22d
[ 2929.518284]  __do_softirq+0xe4/0x23a
[ 2929.518286]  ? sort_range+0x1d/0x1d
[ 2929.518289]  run_ksoftirqd+0x15/0x2a
[ 2929.518290]  smpboot_thread_fn+0x128/0x13f
[ 2929.518292]  kthread+0xf7/0xfc
[ 2929.518293]  ? __init_completion+0x24/0x24
[ 2929.518295]  ret_from_fork+0x22/0x30







Other information about configuration:
ip l
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode 
DEFAULT group default qlen 1000
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp2s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state 
UP mode DEFAULT group default qlen 1000
     link/ether 00:25:90:98:2f:42 brd ff:ff:ff:ff:ff:ff
3: enp2s0f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state 
UP mode DEFAULT group default qlen 1000
     link/ether 00:25:90:98:2f:43 brd ff:ff:ff:ff:ff:ff
4: enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state 
UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
5: enp6s0f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state 
UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:89 brd ff:ff:ff:ff:ff:ff
6: enp130s0f0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT group default qlen 1000
     link/ether ac:1f:6b:2c:18:88 brd ff:ff:ff:ff:ff:ff
7: enp130s0f1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode 
DEFAULT group default qlen 1000
     link/ether ac:1f:6b:2c:18:89 brd ff:ff:ff:ff:ff:ff
8: enp132s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state 
UP mode DEFAULT group default
     link/ether ec:0d:9a:48:71:f6 brd ff:ff:ff:ff:ff:ff
9: vlan1000@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
10: vlan1001@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
11: vlan1002@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
12: vlan1003@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
13: vlan1004@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
14: vlan1005@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
15: vlan1006@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
16: vlan1007@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
17: vlan1008@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
18: vlan1009@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
19: vlan1010@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
20: vlan1011@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
21: vlan1012@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
22: vlan1013@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
23: vlan1014@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
24: vlan1015@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
25: vlan1016@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
26: vlan1017@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
27: vlan1018@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
28: vlan1019@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
29: vlan1020@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP mode DEFAULT group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff

  ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
group default qlen 1000
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
     inet 127.0.0.1/8 brd 127.255.255.255 scope host lo
        valid_lft forever preferred_lft forever
     inet6 ::1/128 scope host
        valid_lft forever preferred_lft forever
2: enp2s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state 
UP group default qlen 1000
     link/ether 00:25:90:98:2f:42 brd ff:ff:ff:ff:ff:ff
     inet 192.168.2.241/24 scope global enp2s0f0
        valid_lft forever preferred_lft forever
     inet6 fe80::225:90ff:fe98:2f42/64 scope link
        valid_lft forever preferred_lft forever
3: enp2s0f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state 
UP group default qlen 1000
     link/ether 00:25:90:98:2f:43 brd ff:ff:ff:ff:ff:ff
     inet 192.168.3.1/24 scope global enp2s0f1
        valid_lft forever preferred_lft forever
     inet6 fe80::225:90ff:fe98:2f43/64 scope link
        valid_lft forever preferred_lft forever
4: enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state 
UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 192.168.5.1/30 scope global enp6s0f0
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
5: enp6s0f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state 
UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:89 brd ff:ff:ff:ff:ff:ff
     inet6 fe80::ec4:7aff:febb:1189/64 scope link
        valid_lft forever preferred_lft forever
6: enp130s0f0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN 
group default qlen 1000
     link/ether ac:1f:6b:2c:18:88 brd ff:ff:ff:ff:ff:ff
7: enp130s0f1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN 
group default qlen 1000
     link/ether ac:1f:6b:2c:18:89 brd ff:ff:ff:ff:ff:ff
8: enp132s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state 
UP group default
     link/ether ec:0d:9a:48:71:f6 brd ff:ff:ff:ff:ff:ff
     inet 10.0.0.2/30 scope global enp132s0
        valid_lft forever preferred_lft forever
     inet6 fe80::ee0d:9aff:fe48:71f6/64 scope link
        valid_lft forever preferred_lft forever
9: vlan1000@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.0.1/30 scope global vlan1000
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
10: vlan1001@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.1.1/30 scope global vlan1001
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
11: vlan1002@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.2.1/30 scope global vlan1002
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
12: vlan1003@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.3.1/30 scope global vlan1003
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
13: vlan1004@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.4.1/30 scope global vlan1004
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
14: vlan1005@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.5.1/30 scope global vlan1005
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
15: vlan1006@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.6.1/30 scope global vlan1006
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
16: vlan1007@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.7.1/30 scope global vlan1007
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
17: vlan1008@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.8.1/30 scope global vlan1008
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
18: vlan1009@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.9.1/30 scope global vlan1009
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
19: vlan1010@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.10.1/30 scope global vlan1010
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
20: vlan1011@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.11.1/30 scope global vlan1011
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
21: vlan1012@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.12.1/30 scope global vlan1012
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
22: vlan1013@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.13.1/30 scope global vlan1013
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
23: vlan1014@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.14.1/30 scope global vlan1014
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
24: vlan1015@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.15.1/30 scope global vlan1015
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
25: vlan1016@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.16.1/30 scope global vlan1016
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
26: vlan1017@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.17.1/30 scope global vlan1017
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
27: vlan1018@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.18.1/30 scope global vlan1018
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
28: vlan1019@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.19.1/30 scope global vlan1019
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever
29: vlan1020@enp6s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP group default qlen 1000
     link/ether 0c:c4:7a:bb:11:88 brd ff:ff:ff:ff:ff:ff
     inet 10.10.20.1/30 scope global vlan1020
        valid_lft forever preferred_lft forever
     inet6 fe80::ec4:7aff:febb:1188/64 scope link
        valid_lft forever preferred_lft forever

tc -s -d qdisc show
qdisc noqueue 0: dev lo root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc mq 0: dev enp2s0f0 root
  Sent 272836 bytes 428 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc fq 0: dev enp2s0f0 parent :8 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 3234 bytes 49 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   3 flows (3 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp2s0f0 parent :7 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 54 bytes 1 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   1 flows (1 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp2s0f0 parent :6 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 474 bytes 7 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   2 flows (2 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp2s0f0 parent :5 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 162 bytes 3 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   1 flows (1 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp2s0f0 parent :4 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 2572 bytes 12 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   1 flows (1 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp2s0f0 parent :3 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 900 bytes 10 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 10 highprio, 0 throttled
qdisc fq 0: dev enp2s0f0 parent :2 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 265300 bytes 344 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   3 flows (3 inactive, 0 throttled)
   0 gc, 0 highprio, 8 throttled
qdisc fq 0: dev enp2s0f0 parent :1 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 140 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   1 flows (1 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc mq 0: dev enp2s0f1 root
  Sent 9664 bytes 88 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc fq 0: dev enp2s0f1 parent :8 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 336 bytes 8 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   1 flows (1 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp2s0f1 parent :7 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp2s0f1 parent :6 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 86 bytes 1 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   1 flows (1 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp2s0f1 parent :5 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp2s0f1 parent :4 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp2s0f1 parent :3 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 522 bytes 3 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   1 flows (1 inactive, 0 throttled)
   0 gc, 2 highprio, 0 throttled
qdisc fq 0: dev enp2s0f1 parent :2 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 700 bytes 10 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   1 flows (1 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp2s0f1 parent :1 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 8020 bytes 66 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   1 flows (1 inactive, 0 throttled)
   0 gc, 2 highprio, 0 throttled
qdisc mq 0: dev enp6s0f0 root
  Sent 2367511859910 bytes 2164463101 pkt (dropped 3496189669, 
overlimits 0 requeues 1824881)
  backlog 1065112b 18364p requeues 1824881
qdisc fq 0: dev enp6s0f0 parent :20 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 73985309492 bytes 1275608728 pkt (dropped 109204845, overlimits 0 
requeues 59714)
  backlog 30624b 527p requeues 59714
   15 flows (7 inactive, 0 throttled)
   0 gc, 224 highprio, 0 throttled, 109204845 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :1f limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74294693608 bytes 1280943004 pkt (dropped 103868838, overlimits 0 
requeues 48945)
  backlog 36308b 626p requeues 48945
   15 flows (7 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled, 103868838 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :1e limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74196009508 bytes 1279241506 pkt (dropped 105591074, overlimits 0 
requeues 58799)
  backlog 32596b 562p requeues 58799
   11 flows (3 inactive, 0 throttled)
   0 gc, 128 highprio, 0 throttled, 105591074 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :1d limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74289745674 bytes 1280857685 pkt (dropped 103968042, overlimits 0 
requeues 40176)
  backlog 34162b 589p requeues 40176
   15 flows (7 inactive, 0 throttled)
   0 gc, 8 highprio, 0 throttled, 103968042 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :1c limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74241263700 bytes 1280021786 pkt (dropped 104855569, overlimits 0 
requeues 40883)
  backlog 36308b 625p requeues 40883
   15 flows (7 inactive, 0 throttled)
   0 gc, 44 highprio, 0 throttled, 104855569 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :1b limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 73894372822 bytes 1274040855 pkt (dropped 110774637, overlimits 0 
requeues 34788)
  backlog 26332b 454p requeues 34788
   16 flows (8 inactive, 0 throttled)
   0 gc, 176 highprio, 0 throttled, 110774637 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :1a limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74291190788 bytes 1280882582 pkt (dropped 103996357, overlimits 0 
requeues 99005)
  backlog 34452b 594p requeues 99005
   17 flows (9 inactive, 0 throttled)
   0 gc, 24 highprio, 0 throttled, 103996357 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :19 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74240383906 bytes 1280006605 pkt (dropped 104827829, overlimits 0 
requeues 45063)
  backlog 35322b 609p requeues 45063
   13 flows (5 inactive, 0 throttled)
   0 gc, 44 highprio, 0 throttled, 104827829 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :18 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74068475782 bytes 1277042607 pkt (dropped 107865924, overlimits 0 
requeues 47584)
  backlog 30102b 519p requeues 47584
   11 flows (3 inactive, 0 throttled)
   0 gc, 220 highprio, 0 throttled, 107865924 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :17 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74108686736 bytes 1277735928 pkt (dropped 107143576, overlimits 0 
requeues 65061)
  backlog 30218b 521p requeues 65061
   11 flows (3 inactive, 0 throttled)
   0 gc, 176 highprio, 0 throttled, 107143576 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :16 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 73987683040 bytes 1275649660 pkt (dropped 109211947, overlimits 0 
requeues 34464)
  backlog 31378b 541p requeues 34464
   13 flows (5 inactive, 0 throttled)
   0 gc, 180 highprio, 0 throttled, 109211947 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :15 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74024925276 bytes 1276291726 pkt (dropped 108624697, overlimits 0 
requeues 61577)
  backlog 29348b 519p requeues 61577
   13 flows (5 inactive, 0 throttled)
   0 gc, 264 highprio, 0 throttled, 108624697 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :14 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74237079950 bytes 1279949627 pkt (dropped 104943297, overlimits 0 
requeues 35649)
  backlog 31958b 586p requeues 35649
   9 flows (1 inactive, 0 throttled)
   0 gc, 88 highprio, 0 throttled, 104943297 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :13 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 73910586246 bytes 1274320375 pkt (dropped 110512404, overlimits 0 
requeues 66803)
  backlog 33060b 570p requeues 66803
   15 flows (7 inactive, 0 throttled)
   0 gc, 308 highprio, 0 throttled, 110512404 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :12 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74017655194 bytes 1276166401 pkt (dropped 108707713, overlimits 0 
requeues 44176)
  backlog 33118b 571p requeues 44176
   12 flows (4 inactive, 0 throttled)
   0 gc, 220 highprio, 0 throttled, 108707713 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :11 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 73912894532 bytes 1274360138 pkt (dropped 110472869, overlimits 0 
requeues 86617)
  backlog 34800b 600p requeues 86617
   13 flows (5 inactive, 0 throttled)
   0 gc, 352 highprio, 0 throttled, 110472869 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :10 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74231798866 bytes 1279858573 pkt (dropped 104939137, overlimits 0 
requeues 71265)
  backlog 34916b 602p requeues 71265
   13 flows (5 inactive, 0 throttled)
   0 gc, 88 highprio, 0 throttled, 104939137 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :f limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74157055860 bytes 1278569914 pkt (dropped 106298021, overlimits 0 
requeues 39002)
  backlog 31958b 551p requeues 39002
   14 flows (6 inactive, 0 throttled)
   0 gc, 88 highprio, 0 throttled, 106298021 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :e limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74195739574 bytes 1279236873 pkt (dropped 105591322, overlimits 0 
requeues 37559)
  backlog 33988b 586p requeues 37559
   15 flows (7 inactive, 0 throttled)
   0 gc, 92 highprio, 0 throttled, 105591322 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :d limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74193059464 bytes 1279190660 pkt (dropped 105605608, overlimits 0 
requeues 53154)
  backlog 27318b 471p requeues 53154
   12 flows (4 inactive, 0 throttled)
   0 gc, 92 highprio, 0 throttled, 105605608 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :c limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74288052080 bytes 1280828472 pkt (dropped 104013919, overlimits 0 
requeues 40123)
  backlog 37062b 639p requeues 40123
   13 flows (5 inactive, 0 throttled)
   0 gc, 44 highprio, 0 throttled, 104013919 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :b limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74290311630 bytes 1280867449 pkt (dropped 103944983, overlimits 0 
requeues 48055)
  backlog 35090b 605p requeues 48055
   10 flows (2 inactive, 0 throttled)
   0 gc, 4 highprio, 0 throttled, 103944983 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :a limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 72445723110 bytes 1249064151 pkt (dropped 135742937, overlimits 0 
requeues 43702)
  backlog 32132b 554p requeues 43702
   13 flows (5 inactive, 0 throttled)
   0 gc, 148 highprio, 0 throttled, 135742937 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :9 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74293028762 bytes 1280914297 pkt (dropped 103917827, overlimits 0 
requeues 45858)
  backlog 35612b 614p requeues 45858
   12 flows (4 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled, 103917827 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :8 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 74111780880 bytes 1277789254 pkt (dropped 107086303, overlimits 0 
requeues 71937)
  backlog 31726b 547p requeues 71937
   11 flows (3 inactive, 0 throttled)
   0 gc, 180 highprio, 0 throttled, 107086303 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :7 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 73950504826 bytes 1275008609 pkt (dropped 109836713, overlimits 0 
requeues 68498)
  backlog 30624b 552p requeues 68498
   11 flows (3 inactive, 0 throttled)
   0 gc, 264 highprio, 0 throttled, 109836713 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :6 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 73963811772 bytes 1275238070 pkt (dropped 109624357, overlimits 0 
requeues 34496)
  backlog 32886b 567p requeues 34496
   12 flows (4 inactive, 0 throttled)
   0 gc, 264 highprio, 0 throttled, 109624357 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :5 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 73836527718 bytes 1273043497 pkt (dropped 111815406, overlimits 0 
requeues 44572)
  backlog 33988b 586p requeues 44572
   11 flows (3 inactive, 0 throttled)
   0 gc, 276 highprio, 0 throttled, 111815406 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :4 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 73863703836 bytes 1273512022 pkt (dropped 111275153, overlimits 0 
requeues 54611)
  backlog 32538b 561p requeues 54611
   15 flows (7 inactive, 0 throttled)
   0 gc, 396 highprio, 0 throttled, 111275153 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :3 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 73868998162 bytes 1273603341 pkt (dropped 111156286, overlimits 0 
requeues 22904)
  backlog 36888b 636p requeues 22904
   13 flows (5 inactive, 0 throttled)
   0 gc, 308 highprio, 0 throttled, 111156286 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :2 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 73273532764 bytes 1263336714 pkt (dropped 121553778, overlimits 0 
requeues 37237)
  backlog 36076b 622p requeues 37237
   14 flows (6 inactive, 0 throttled)
   0 gc, 136 highprio, 0 throttled, 121553778 flows_plimit
qdisc fq 0: dev enp6s0f0 parent :1 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 72847319070 bytes 1255988427 pkt (dropped 129218329, overlimits 0 
requeues 242604)
  backlog 32190b 555p requeues 242604
   1024 flows (1016 inactive, 0 throttled)
   0 gc, 352 highprio, 0 throttled, 129218329 flows_plimit
qdisc mq 0: dev enp6s0f1 root
  Sent 1318 bytes 17 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc fq 0: dev enp6s0f1 parent :20 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :1f limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :1e limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :1d limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :1c limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :1b limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :1a limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :19 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :18 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :17 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :16 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :15 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :14 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :13 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :12 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :11 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :10 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :f limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :e limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :d limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :c limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :b limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :a limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :9 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 172 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   1 flows (1 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :8 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :7 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :6 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :5 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :4 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 1146 bytes 15 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   1 flows (1 inactive, 0 throttled)
   0 gc, 4 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :3 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :2 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp6s0f1 parent :1 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc mq 0: dev enp132s0 root
  Sent 1416 bytes 18 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc fq 0: dev enp132s0 parent :20 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :1f limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :1e limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :1d limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :1c limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :1b limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :1a limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :19 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :18 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :17 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :16 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :15 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :14 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :13 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :12 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :11 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :10 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :f limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :e limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :d limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :c limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 180 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 2 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :b limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :a limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :9 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :8 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :7 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :6 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :5 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :4 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :3 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 0 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :2 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 1146 bytes 15 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   1 flows (1 inactive, 0 throttled)
   0 gc, 4 highprio, 0 throttled
qdisc fq 0: dev enp132s0 parent :1 limit 10000p flow_limit 100p buckets 
1024 orphan_mask 1023 quantum 3028 initial_quantum 15140 refill_delay 40.0ms
  Sent 90 bytes 1 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
   0 flows (0 inactive, 0 throttled)
   0 gc, 1 highprio, 0 throttled
qdisc noqueue 0: dev vlan1000 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1001 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1002 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1003 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1004 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1005 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1006 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1007 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1008 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1009 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1010 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1011 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1012 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1013 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1014 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1015 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1016 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1017 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1018 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1019 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc noqueue 0: dev vlan1020 root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
