From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Wed, 4 Dec 2013 00:15:00 +0200
Message-ID: <CAJZOPZLb4-UxbTEa+tMFyLWbNk8s+1LhjeSstYNr9t2eiLvuWQ@mail.gmail.com>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	<1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
	<20131203.165034.1085515763685633822.davem@davemloft.net>
	<1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:57580 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755351Ab3LCWPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 17:15:01 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so21781528pbc.7
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 14:15:00 -0800 (PST)
In-Reply-To: <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 3, 2013 at 11:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-12-03 at 16:50 -0500, David Miller wrote:
>
>> At this point I would use drop monitor to figure out in what context
>> packets are being dropped on the floor.  There are scripts provided
>> with the perf tool to utilize it.
>
> Most easy way is to do :
>
> perf record -e skb:kfree_skb -a -g sleep 10
>
> perf report

The version of perf I have on these nodes fail to run the 1st command,
anyway, here's some data which was asked by Eric

passive side top + plain perf for two streams

top - 00:08:09 up  7:53,  3 users,  load average: 0.59, 0.43, 0.32
Tasks: 134 total,   1 running, 133 sleeping,   0 stopped,   0 zombie
Cpu0  :  0.0%us,  5.7%sy,  0.0%ni, 92.2%id,  0.0%wa,  0.0%hi,  2.0%si,  0.0%st
Cpu1  :  0.6%us, 17.2%sy,  0.0%ni, 30.6%id,  0.0%wa,  0.0%hi, 51.7%si,  0.0%st
Cpu2  :  0.7%us,  4.3%sy,  0.0%ni, 93.6%id,  0.0%wa,  0.0%hi,  1.3%si,  0.0%st
Cpu3  :  0.0%us,  1.7%sy,  0.0%ni, 98.0%id,  0.0%wa,  0.0%hi,  0.3%si,  0.0%st
Cpu4  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu5  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu6  :  0.0%us, 14.4%sy,  0.0%ni, 50.0%id,  0.0%wa,  0.0%hi, 35.6%si,  0.0%st
Cpu7  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:   8183220k total,  1383012k used,  6800208k free,    10724k buffers
Swap:  2097148k total,        0k used,  2097148k free,   127520k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
 3857 root      20   0  381m  640  468 S 69.2  0.0   6:45.22 iperf
   15 root      20   0     0    0    0 S  7.3  0.0   0:09.92 ksoftirqd/1
   40 root      20   0     0    0    0 S  7.3  0.0   0:12.10 ksoftirqd/6
   20 root      20   0     0    0    0 S  0.3  0.0   0:20.95 ksoftirqd/2
 9229 root      20   0  220m  16m 6168 S  0.3  0.2   0:00.78 perf
 9578 root      20   0 15084 1156  856 R  0.3  0.0   0:00.01 top
    1 root      20   0 23648 1644 1320 S  0.0  0.0   0:00.34 init


Samples: 1K of event 'cpu-clock', Event count (approx.): 283500000
  5.17%  [kernel]            [k] fib_table_lookup
  5.02%  [kernel]            [k] __do_softirq
  3.63%  [kernel]            [k] copy_user_generic_unrolled
  3.55%  perf                [.] 0x000000000004c808
  3.16%  [kernel]            [k] __netif_receive_skb_core
  3.09%  [kernel]            [k] _raw_spin_unlock_irqrestore
  2.93%  [kernel]            [k] enqueue_to_backlog
  2.85%  [kernel]            [k] _raw_spin_lock
  2.08%  [kernel]            [k] __pskb_pull_tail
  1.93%  [kernel]            [k] __udp4_lib_lookup
  1.85%  [kernel]            [k] ip_rcv
  1.77%  [kernel]            [k] __slab_free
  1.62%  [kernel]            [k] _raw_spin_unlock_irq
  1.54%  [kernel]            [k] check_leaf
  1.47%  [kernel]            [k] pvclock_clocksource_read
  1.47%  [kernel]            [k] skb_copy_bits
  1.31%  [kernel]            [k] __rcu_read_unlock
  1.31%  [kernel]            [k] tcp_v4_rcv
  1.23%  [mlx4_en]           [k] mlx4_en_process_rx_cq
  1.00%  [kernel]            [k] skb_try_coalesce
  1.00%  [kernel]            [k] napi_gro_frags
  1.00%  [kernel]            [k] __inet_lookup_established
  0.93%  [mlx4_en]           [k] mlx4_en_xmit


ifconfig -a listing (eth2 is the NIC over which we run, br1 is the
bridge) - no recorded drops

[root@r-dcs47-005 ~]# ifconfig -a
br1       Link encap:Ethernet  HWaddr 1A:10:63:AD:55:4C
          inet addr:192.168.52.147  Bcast:192.168.52.255  Mask:255.255.255.0
          inet6 addr: fe80::f88c:60ff:fe19:6d33/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:32120731 errors:0 dropped:0 overruns:0 frame:0
          TX packets:987550 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:46552789260 (43.3 GiB)  TX bytes:53462960 (50.9 MiB)

eth0      Link encap:Ethernet  HWaddr 00:50:56:25:4A:05
          inet addr:10.212.74.5  Bcast:10.212.255.255  Mask:255.255.0.0
          inet6 addr: fe80::250:56ff:fe25:4a05/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:265478 errors:0 dropped:16 overruns:0 frame:0
          TX packets:14391 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:28861836 (27.5 MiB)  TX bytes:2561303 (2.4 MiB)

eth2      Link encap:Ethernet  HWaddr 00:02:C9:E9:C0:82
          inet addr:192.168.30.147  Bcast:192.168.30.255  Mask:255.255.255.0
          inet6 addr: fe80::2:c900:1e9:c082/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:853813090 errors:0 dropped:0 overruns:0 frame:0
          TX packets:76377493 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1270293325678 (1.1 TiB)  TX bytes:7858334980 (7.3 GiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:48 errors:0 dropped:0 overruns:0 frame:0
          TX packets:48 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:3236 (3.1 KiB)  TX bytes:3236 (3.1 KiB)

veth0     Link encap:Ethernet  HWaddr EA:4F:C9:1C:5D:EE
          inet addr:192.168.62.147  Bcast:192.168.62.255  Mask:255.255.255.0
          inet6 addr: fe80::e84f:c9ff:fe1c:5dee/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:372217768 errors:0 dropped:0 overruns:0 frame:0
          TX packets:60732630 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:544449586684 (507.0 GiB)  TX bytes:3840742148 (3.5 GiB)

veth1     Link encap:Ethernet  HWaddr 1A:10:63:AD:55:4C
          inet6 addr: fe80::1810:63ff:fead:554c/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:60732693 errors:0 dropped:0 overruns:0 frame:0
          TX packets:372217836 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:3840746210 (3.5 GiB)  TX bytes:544449686236 (507.0 GiB)

vxlan42   Link encap:Ethernet  HWaddr FE:EF:4E:C7:0F:06
          inet addr:192.168.42.147  Bcast:192.168.42.255  Mask:255.255.255.0
          inet6 addr: fe80::fcef:4eff:fec7:f06/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:404338687 errors:0 dropped:0 overruns:0 frame:0
          TX packets:61720259 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:585791638636 (545.5 GiB)  TX bytes:4881734478 (4.5 GiB)



active side perf top

Samples: 74K of event 'cpu-clock', Event count (approx.): 12653268255
 14.74%  [kernel]            [k] __copy_user_nocache
  7.91%  [kernel]            [k] csum_partial
  7.51%  [kernel]            [k] _raw_spin_lock
  6.38%  [kernel]            [k] _raw_spin_unlock_irqrestore
  5.57%  [kernel]            [k] __do_softirq
  4.24%  [mlx4_en]           [k] mlx4_en_xmit
  2.40%  [kernel]            [k] __copy_skb_header
  2.10%  [kernel]            [k] _raw_spin_unlock_irq
  2.04%  [kernel]            [k] memcpy
  1.92%  [kernel]            [k] fib_table_lookup
  1.73%  [kernel]            [k] tcp_sendmsg
  1.64%  [kernel]            [k] skb_segment
  1.52%  [kernel]            [k] __slab_free
  1.09%  [kernel]            [k] __alloc_skb
  0.89%  [kernel]            [k] __slab_alloc
  0.85%  [kernel]            [k] tcp_ack
  0.83%  [kernel]            [k] __netif_receive_skb_core
  0.81%  [kernel]            [k] __kmalloc_node_track_caller
  0.75%  [kernel]            [k] ip_send_check
  0.70%  [kernel]            [k] put_compound_page
  0.70%  [kernel]            [k] ksize
  0.67%  [kernel]            [k] pvclock_clocksource_read
  0.65%  [kernel]            [k] dev_hard_start_xmit
  0.61%  [kernel]            [k] kmem_cache_alloc_node
  0.58%  [kernel]            [k] dev_queue_xmit
  0.55%  [kernel]            [k] enqueue_to_backlog
  0.52%  [kernel]            [k] __pskb_pull_tail
  0.49%  [kernel]            [k] __iowrite64_copy
  0.45%  [kernel]            [k] dev_queue_xmit_nit
  0.45%  [kernel]            [k] skb_copy_bits
  0.44%  [kernel]            [k] check_leaf
  0.44%  [kernel]            [k] skb_release_data
  0.44%  [kernel]            [k] get_page_from_freelist
  0.43%  [kernel]            [k] inet_gso_segment
  0.42%  [mlx4_en]           [k] mlx4_en_process_rx_cq
  0.39%  [kernel]            [k] process_backlog
  0.38%  [kernel]            [k] pskb_expand_head

and top


[root@r-dcs44-005 ~]# top
top - 00:13:27 up  7:59,  3 users,  load average: 1.11, 0.76, 0.44
Tasks: 129 total,   1 running, 128 sleeping,   0 stopped,   0 zombie
Cpu0  :  0.0%us, 10.3%sy,  0.0%ni, 87.0%id,  0.0%wa,  0.0%hi,  2.7%si,  0.0%st
Cpu1  :  0.3%us, 11.7%sy,  0.0%ni, 84.3%id,  0.0%wa,  0.0%hi,  3.7%si,  0.0%st
Cpu2  :  0.5%us, 18.4%sy,  0.0%ni, 43.4%id,  0.0%wa,  0.0%hi, 37.8%si,  0.0%st
Cpu3  :  0.0%us,  5.1%sy,  0.0%ni, 94.3%id,  0.0%wa,  0.0%hi,  0.7%si,  0.0%st
Cpu4  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu5  :  0.3%us,  6.0%sy,  0.0%ni, 93.4%id,  0.0%wa,  0.0%hi,  0.3%si,  0.0%st
Cpu6  :  0.3%us,  7.4%sy,  0.0%ni, 92.3%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu7  :  0.0%us, 24.4%sy,  0.0%ni, 42.1%id,  0.0%wa,  0.0%hi, 33.5%si,  0.0%st
Mem:   8183236k total,  1378928k used,  6804308k free,    10436k buffers
Swap:  2097148k total,        0k used,  2097148k free,   128068k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
17220 root      20   0  165m  564  456 S 122.4  0.0   6:14.34 iperf
   20 root      20   0     0    0    0 S  1.3  0.0   0:07.85 ksoftirqd/2
   45 root      20   0     0    0    0 S  1.3  0.0   0:05.65 ksoftirqd/7
18404 root      20   0  220m  16m 6384 S  0.7  0.2   0:00.62 perf
   35 root      20   0     0    0    0 S  0.3  0.0   0:07.73 ksoftirqd/5
    1 root      20   0 23520 1624 1316 S  0.0  0.0   0:00.33 init
    2 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kthreadd



and ifconfig -a (eth6 is the NIC over which we run)

root@r-dcs44-005 ~]# ifconfig -a
br1       Link encap:Ethernet  HWaddr 12:C0:46:32:46:6A
          inet addr:192.168.52.144  Bcast:192.168.52.255  Mask:255.255.255.0
          inet6 addr: fe80::2815:30ff:fe06:b5f9/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:987575 errors:0 dropped:0 overruns:0 frame:0
          TX packets:842756 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:39638896 (37.8 MiB)  TX bytes:45313678898 (42.2 GiB)

eth0      Link encap:Ethernet  HWaddr 00:50:56:25:4B:05
          inet addr:10.212.75.5  Bcast:10.212.255.255  Mask:255.255.0.0
          inet6 addr: fe80::250:56ff:fe25:4b05/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:193220 errors:0 dropped:55 overruns:0 frame:0
          TX packets:17721 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:17006297 (16.2 MiB)  TX bytes:2871741 (2.7 MiB)

eth6      Link encap:Ethernet  HWaddr 00:02:C9:E9:BB:B2
          inet addr:192.168.30.144  Bcast:192.168.30.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:101512678 errors:0 dropped:0 overruns:0 frame:0
          TX packets:995876432 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:10707213944 (9.9 GiB)  TX bytes:1485292875970 (1.3 TiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:36 errors:0 dropped:0 overruns:0 frame:0
          TX packets:36 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:2456 (2.3 KiB)  TX bytes:2456 (2.3 KiB)

veth0     Link encap:Ethernet  HWaddr 32:7D:34:FA:3A:A1
          inet addr:192.168.62.144  Bcast:192.168.62.255  Mask:255.255.255.0
          inet6 addr: fe80::307d:34ff:fefa:3aa1/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:85847361 errors:0 dropped:0 overruns:0 frame:0
          TX packets:72371900 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:5431514098 (5.0 GiB)  TX bytes:728410479216 (678.3 GiB)

veth1     Link encap:Ethernet  HWaddr 12:C0:46:32:46:6A
          inet6 addr: fe80::10c0:46ff:fe32:466a/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:72371915 errors:0 dropped:0 overruns:0 frame:0
          TX packets:85847368 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:728410821246 (678.3 GiB)  TX bytes:5431514476 (5.0 GiB)

vxlan42   Link encap:Ethernet  HWaddr B2:F9:D2:68:A3:11
          inet addr:192.168.42.144  Bcast:192.168.42.255  Mask:255.255.255.0
          inet6 addr: fe80::b0f9:d2ff:fe68:a311/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:86834927 errors:0 dropped:0 overruns:0 frame:0
          TX packets:73214688 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:4269288656 (3.9 GiB)  TX bytes:774896089976 (721.6 GiB)

no drops
