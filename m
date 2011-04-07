From: Wei Gu <wei.gu@ericsson.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Thu, 7 Apr 2011 19:15:10 +0800
Message-ID: <D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302152327.2701.50.camel@edumazet-laptop>
	 <1302153412.2701.64.camel@edumazet-laptop>
	 <1302157012.2701.73.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>
	 <1302163650.3357.8.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>
 <1302167168.3357.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_D12839161ADD3A4B8DA63D1A134D084026E48BA027ESGSCCMS0001e_"
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:51015 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab1DGLPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 07:15:18 -0400
In-Reply-To: <1302167168.3357.12.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_D12839161ADD3A4B8DA63D1A134D084026E48BA027ESGSCCMS0001e_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi,
I compile the ixgbe driver into the kernel and run the test again and also =
change the copy to clone in the fw hook
This is the perf report while I was forwarding 150Kpps with
The attached file include the basic info about my test system. Please let m=
e know if I did some thing wrong.

+     71.91%          swapper  [kernel.kallsyms]            [k] poll_idle
+     10.43%          swapper  [kernel.kallsyms]            [k] intel_idle
-      8.00%     ksoftirqd/24  [kernel.kallsyms]            [k] _raw_spin_u=
nlock_irqrestore
\u2592   - _raw_spin_unlock_irqrestore
\u2592      - 42.25% alloc_iova
\u2592           intel_alloc_iova
\u2592           __intel_map_single
\u2592           intel_map_page
\u2592         - dma_map_single_attrs.clone.3
\u2592            + 59.89% ixgbe_alloc_rx_buffers
\u2592            - 40.11% ixgbe_xmit_frame_ring
\u2592                 ixgbe_xmit_frame
\u2592                 dev_hard_start_xmit
\u2592                 sch_direct_xmit
\u2592                 dev_queue_xmit
\u2592                 vlan_dev_hard_start_xmit
\u2592                 hook_func
\u2592                 nf_iterate
\u2592                 nf_hook_slow
\u2592                 NF_HOOK.clone.1
\u2592                 ip_rcv
\u2592                 __netif_receive_skb
\u2592                 __netif_receive_skb
\u2592                 netif_receive_skb
\u2592                 napi_skb_finish
\u2592                 napi_gro_receive
\u2592                 ixgbe_clean_rx_irq
\u2592                 ixgbe_clean_rxtx_many
\u2592                 net_rx_action
\u2592                 __do_softirq
\u2592               + call_softirq
\u2592      + 36.30% find_iova
\u2592      + 20.89% add_unmap
\u2592+      1.60%     kworker/24:1  [kernel.kallsyms]            [k] _raw_=
spin_unlock_irqrestore
\u2592+      0.80%          swapper  [kernel.kallsyms]            [k] _raw_=
spin_unlock_irqrestore
\u2592+      0.66%            snmpd  [kernel.kallsyms]            [k] snmp_=
fold_field
\u2592+      0.53%     ksoftirqd/24  [kernel.kallsyms]            [k] clflu=
sh_cache_range


If I zoom out to this ksoftirqd/24
+     80.38%  ksoftirqd/24  [kernel.kallsyms]  [k] _raw_spin_unlock_irqrest=
ore
+      5.35%  ksoftirqd/24  [kernel.kallsyms]  [k] clflush_cache_range
+      1.49%  ksoftirqd/24  [kernel.kallsyms]  [k] __domain_mapping
+      0.84%  ksoftirqd/24  [kernel.kallsyms]  [k] kmem_cache_alloc
+      0.55%  ksoftirqd/24  [kernel.kallsyms]  [k] _raw_spin_lock
+      0.54%  ksoftirqd/24  [kernel.kallsyms]  [k] ixgbe_xmit_frame_ring
+      0.52%  ksoftirqd/24  [kernel.kallsyms]  [k] ixgbe_clean_rx_irq
+      0.50%  ksoftirqd/24  [kernel.kallsyms]  [k] domain_get_iommu
+      0.49%  ksoftirqd/24  [kernel.kallsyms]  [k] dma_map_single_attrs.clo=
ne.3
+      0.48%  ksoftirqd/24  [kernel.kallsyms]  [k] kmem_cache_free

Perf top

---------------------------------------------------------------------------=
---------------------------------------------------------------------------=
---------------------------------------------------------
   PerfTop:   10615 irqs/sec  kernel:99.7%  exact:  0.0% [1000Hz cpu-clock-=
msecs],  (all, 64 CPUs)
---------------------------------------------------------------------------=
---------------------------------------------------------------------------=
---------------------------------------------------------

             samples  pcnt function                        DSO
             _______ _____ _______________________________ ________________=
__________________________________________________________

            11786.00 54.9% intel_idle                      [kernel.kallsyms=
]
             7180.00 33.4% _raw_spin_unlock_irqrestore     [kernel.kallsyms=
]
              469.00  2.2% clflush_cache_range             [kernel.kallsyms=
]
              138.00  0.6% __domain_mapping                [kernel.kallsyms=
]
               81.00  0.4% dso__find_symbol                /root/rpmbuild/B=
UILD/kernel-2.6.38.el6/linux-2.6.38.x86_64/tools/perf/perf
               73.00  0.3% _raw_spin_lock                  [kernel.kallsyms=
]
               72.00  0.3% dso__load_sym.clone.0           /root/rpmbuild/B=
UILD/kernel-2.6.38.el6/linux-2.6.38.x86_64/tools/perf/perf
               68.00  0.3% kmem_cache_alloc                [kernel.kallsyms=
]
               53.00  0.2% symbol_filter                   /root/rpmbuild/B=
UILD/kernel-2.6.38.el6/linux-2.6.38.x86_64/tools/perf/perf
               51.00  0.2% domain_get_iommu                [kernel.kallsyms=
]
               44.00  0.2% ixgbe_clean_rx_irq              [kernel.kallsyms=
]
               42.00  0.2% kmem_cache_free                 [kernel.kallsyms=
]
               42.00  0.2% ixgbe_xmit_frame_ring           [kernel.kallsyms=
]
               41.00  0.2% ixgbe_clean_tx_irq              [kernel.kallsyms=
]
               40.00  0.2% dma_map_single_attrs.clone.3    [kernel.kallsyms=
]


Top:

Tasks: 425 total,   2 running, 423 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.0%us,  0.0%sy,  0.0%ni, 96.0%id,  0.0%wa,  0.0%hi,  3.9%si,  0.0=
%st
Mem:  264733684k total,  6374016k used, 258359668k free,    43720k buffers
Swap:  4194300k total,        0k used,  4194300k free,   137308k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+   P COMMAND
   79 root      20   0     0    0    0 R 38.8  0.0  29:22.85 24 ksoftirqd/2=
4
  233 root      20   0     0    0    0 S  7.6  0.0   4:06.60 24 kworker/24:=
1
 1538 root      20   0     0    0    0 S  0.3  0.0   0:00.78 33 kworker/33:=
3
 2271 root      20   0  200m 5564 1460 S  0.3  0.0   0:03.31  2 snmpd


Thanks
WeiGu

-----Original Message-----
From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
Sent: Thursday, April 07, 2011 5:06 PM
To: Wei Gu
Cc: netdev; Alexander Duyck; Jeff Kirsher
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel

Le jeudi 07 avril 2011 =E0 16:39 +0800, Wei Gu a =E9crit :
> I'm only insert a prerouting hook to make a copy of the incomming
> packet and swap the L2/L3 header, send it back on the same interface.
>

Small packets or big ones ?

You dont need to copy the packet, its expensive.


> BTW, some times I notices that the perf tool was not mapping the
> symbol correclly, I don't why?
>

You might try to put ixgbe in static kernel, not in a module.

> I will try a fresh install of kernel 2.6.30 and do the test with the
> shipped ixgbe driver again.
>

OK thanks.






--_002_D12839161ADD3A4B8DA63D1A134D084026E48BA027ESGSCCMS0001e_
Content-Type: application/x-gzip; name="2.6.38_clone_fw_tar.gz"
Content-Description: 2.6.38_clone_fw_tar.gz
Content-Disposition: attachment; filename="2.6.38_clone_fw_tar.gz";
	size=36172; creation-date="Thu, 07 Apr 2011 10:48:15 GMT";
	modification-date="Thu, 07 Apr 2011 10:44:02 GMT"
Content-Transfer-Encoding: base64

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

--_002_D12839161ADD3A4B8DA63D1A134D084026E48BA027ESGSCCMS0001e_--
