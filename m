From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Thu, 07 Apr 2011 13:46:51 +0200
Message-ID: <1302176811.3357.15.camel@edumazet-laptop>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302152327.2701.50.camel@edumazet-laptop>
	 <1302153412.2701.64.camel@edumazet-laptop>
	 <1302157012.2701.73.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>
	 <1302163650.3357.8.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>
	 <1302167168.3357.12.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Wei Gu <wei.gu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:37807 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754541Ab1DGLqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 07:46:55 -0400
Received: by wwk4 with SMTP id 4so4982790wwk.1
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2011 04:46:54 -0700 (PDT)
In-Reply-To: <D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 avril 2011 =C3=A0 19:15 +0800, Wei Gu a =C3=A9crit :
> Hi,
> I compile the ixgbe driver into the kernel and run the test again and=
 also change the copy to clone in the fw hook
> This is the perf report while I was forwarding 150Kpps with
> The attached file include the basic info about my test system. Please=
 let me know if I did some thing wrong.
>=20
> +     71.91%          swapper  [kernel.kallsyms]            [k] poll_=
idle
> +     10.43%          swapper  [kernel.kallsyms]            [k] intel=
_idle
> -      8.00%     ksoftirqd/24  [kernel.kallsyms]            [k] _raw_=
spin_unlock_irqrestore
> \u2592   - _raw_spin_unlock_irqrestore
> \u2592      - 42.25% alloc_iova
> \u2592           intel_alloc_iova
> \u2592           __intel_map_single
> \u2592           intel_map_page
> \u2592         - dma_map_single_attrs.clone.3
> \u2592            + 59.89% ixgbe_alloc_rx_buffers
> \u2592            - 40.11% ixgbe_xmit_frame_ring
> \u2592                 ixgbe_xmit_frame
> \u2592                 dev_hard_start_xmit
> \u2592                 sch_direct_xmit
> \u2592                 dev_queue_xmit
> \u2592                 vlan_dev_hard_start_xmit
> \u2592                 hook_func
> \u2592                 nf_iterate
> \u2592                 nf_hook_slow
> \u2592                 NF_HOOK.clone.1
> \u2592                 ip_rcv
> \u2592                 __netif_receive_skb
> \u2592                 __netif_receive_skb
> \u2592                 netif_receive_skb
> \u2592                 napi_skb_finish
> \u2592                 napi_gro_receive
> \u2592                 ixgbe_clean_rx_irq
> \u2592                 ixgbe_clean_rxtx_many
> \u2592                 net_rx_action
> \u2592                 __do_softirq
> \u2592               + call_softirq
> \u2592      + 36.30% find_iova
> \u2592      + 20.89% add_unmap
> \u2592+      1.60%     kworker/24:1  [kernel.kallsyms]            [k]=
 _raw_spin_unlock_irqrestore
> \u2592+      0.80%          swapper  [kernel.kallsyms]            [k]=
 _raw_spin_unlock_irqrestore
> \u2592+      0.66%            snmpd  [kernel.kallsyms]            [k]=
 snmp_fold_field
> \u2592+      0.53%     ksoftirqd/24  [kernel.kallsyms]            [k]=
 clflush_cache_range
>=20
>=20
> If I zoom out to this ksoftirqd/24
> +     80.38%  ksoftirqd/24  [kernel.kallsyms]  [k] _raw_spin_unlock_i=
rqrestore
> +      5.35%  ksoftirqd/24  [kernel.kallsyms]  [k] clflush_cache_rang=
e
> +      1.49%  ksoftirqd/24  [kernel.kallsyms]  [k] __domain_mapping
> +      0.84%  ksoftirqd/24  [kernel.kallsyms]  [k] kmem_cache_alloc
> +      0.55%  ksoftirqd/24  [kernel.kallsyms]  [k] _raw_spin_lock
> +      0.54%  ksoftirqd/24  [kernel.kallsyms]  [k] ixgbe_xmit_frame_r=
ing
> +      0.52%  ksoftirqd/24  [kernel.kallsyms]  [k] ixgbe_clean_rx_irq
> +      0.50%  ksoftirqd/24  [kernel.kallsyms]  [k] domain_get_iommu
> +      0.49%  ksoftirqd/24  [kernel.kallsyms]  [k] dma_map_single_att=
rs.clone.3
> +      0.48%  ksoftirqd/24  [kernel.kallsyms]  [k] kmem_cache_free
>=20
> Perf top
>=20
> ---------------------------------------------------------------------=
-----------------------------------------------------------------------=
-------------------------------------------------------------------
>    PerfTop:   10615 irqs/sec  kernel:99.7%  exact:  0.0% [1000Hz cpu-=
clock-msecs],  (all, 64 CPUs)
> ---------------------------------------------------------------------=
-----------------------------------------------------------------------=
-------------------------------------------------------------------
>=20
>              samples  pcnt function                        DSO
>              _______ _____ _______________________________ __________=
________________________________________________________________
>=20
>             11786.00 54.9% intel_idle                      [kernel.ka=
llsyms]
>              7180.00 33.4% _raw_spin_unlock_irqrestore     [kernel.ka=
llsyms]
>               469.00  2.2% clflush_cache_range             [kernel.ka=
llsyms]
>               138.00  0.6% __domain_mapping                [kernel.ka=
llsyms]
>                81.00  0.4% dso__find_symbol                /root/rpmb=
uild/BUILD/kernel-2.6.38.el6/linux-2.6.38.x86_64/tools/perf/perf
>                73.00  0.3% _raw_spin_lock                  [kernel.ka=
llsyms]
>                72.00  0.3% dso__load_sym.clone.0           /root/rpmb=
uild/BUILD/kernel-2.6.38.el6/linux-2.6.38.x86_64/tools/perf/perf
>                68.00  0.3% kmem_cache_alloc                [kernel.ka=
llsyms]
>                53.00  0.2% symbol_filter                   /root/rpmb=
uild/BUILD/kernel-2.6.38.el6/linux-2.6.38.x86_64/tools/perf/perf
>                51.00  0.2% domain_get_iommu                [kernel.ka=
llsyms]
>                44.00  0.2% ixgbe_clean_rx_irq              [kernel.ka=
llsyms]
>                42.00  0.2% kmem_cache_free                 [kernel.ka=
llsyms]
>                42.00  0.2% ixgbe_xmit_frame_ring           [kernel.ka=
llsyms]
>                41.00  0.2% ixgbe_clean_tx_irq              [kernel.ka=
llsyms]
>                40.00  0.2% dma_map_single_attrs.clone.3    [kernel.ka=
llsyms]
>=20
>=20
> Top:
>=20
> Tasks: 425 total,   2 running, 423 sleeping,   0 stopped,   0 zombie
> Cpu(s):  0.0%us,  0.0%sy,  0.0%ni, 96.0%id,  0.0%wa,  0.0%hi,  3.9%si=
,  0.0%st
> Mem:  264733684k total,  6374016k used, 258359668k free,    43720k bu=
ffers
> Swap:  4194300k total,        0k used,  4194300k free,   137308k cach=
ed
>=20
>   PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+   P COMMA=
ND
>    79 root      20   0     0    0    0 R 38.8  0.0  29:22.85 24 ksoft=
irqd/24
>   233 root      20   0     0    0    0 S  7.6  0.0   4:06.60 24 kwork=
er/24:1
>  1538 root      20   0     0    0    0 S  0.3  0.0   0:00.78 33 kwork=
er/33:3
>  2271 root      20   0  200m 5564 1460 S  0.3  0.0   0:03.31  2 snmpd
>=20
>=20
> Thanks
> WeiGu

OK, please send your .config file



