From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Question on "net: allocate skbs on local node"
Date: Thu, 07 Apr 2011 06:58:47 +0200
Message-ID: <1302152327.2701.50.camel@edumazet-laptop>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Wei Gu <wei.gu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61453 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801Ab1DGE6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 00:58:53 -0400
Received: by wya21 with SMTP id 21so1888707wya.19
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 21:58:51 -0700 (PDT)
In-Reply-To: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 avril 2011 =C3=A0 10:16 +0800, Wei Gu a =C3=A9crit :
> Hi Eric,
> Testing with ixgbe Linux 2.6.38 driver:
> We have a little better thruput figure with this driver, but it looks
> not scalling at all, I always stressed one CPU core/24.
> And when look the perf report for ksoftirqd/24, the most cost functio=
n
> is still "_raw_spin_unlock_irqstore" and the IRQ/s is huge, it's
> somehow conflicts with desgin of NAPI. On linux 2.6.32 while the CPU
> was stressed the IRQ will descreased while the NAPI will running much
> on the polling mode. I don't know why on 2.6.38 the IRQ was keep
> increasing.


CC netdev and Intel guys, since they said it should not happen (TM)

IF you dont use DCA (make sure ioatdma module is not loaded), how comes
alloc_iova() is called at all ?

IF you use DCA, how comes its called, since the same CPU serves a given
interrupt ?



> =20
> CONFIG_TICK_ONESHOT=3Dy
> CONFIG_NO_HZ=3Dy
> =20
> PerfTop:  512417 irqs/sec  kernel:91.3%  exact:  0.0% [1000Hz cpu-clo=
ck-msecs],  (all, 64 CPUs)
> ---------------------------------------------------------------------=
-----------------------------------------------------------------------=
----------
> -      0.82%     ksoftirqd/24  [kernel.kallsyms]          [k] _raw_sp=
in_unlock_irqrestore                                                   =
                                                                       =
                      =20
> \u2592   - _raw_spin_unlock_irqrestore                               =
                                                                       =
         =20
> \u2592      - 44.27% alloc_iova                                      =
                                         =20
> \u2592           intel_alloc_iova                                    =
                                                                       =
                                                                       =
                            =20
> \u2592           __intel_map_single                                  =
                                          =20
> \u2592           intel_map_page                                      =
                                                                       =
=20
> \u2592         - ixgbe_init_interrupt_scheme                         =
                                                                       =
            =20
> \u2592            - 59.97% ixgbe_alloc_rx_buffers                    =
                                                                       =
                     =20
> \u2592                 ixgbe_clean_rx_irq                            =
                                                                       =
            =20
> \u2592                 0xffffffffa033a5                              =
                                                                =20
> \u2592                 net_rx_action                                 =
                                                                       =
          =20
> u2592                 __do_softirq                                   =
                                                                    =20
> \u2592               + call_softirq                                  =
                                                                       =
    =20
> \u2592            - 40.03% ixgbe_change_mtu                          =
                                                                       =
                                                                       =
                            =20
> \u2592                 ixgbe_change_mtu                              =
                                                                =20
> \u2592                 dev_hard_start_xmit                           =
                           =20
> \u2592                 sch_direct_xmit                               =
                                   =20
> \u2592                 dev_queue_xmit                                =
                                                                =20
> \u2592                 vlan_dev_hard_start_xmit                      =
                                                                       =
                                                                       =
                            =20
> \u2592                 hook_func                                     =
                                                                       =
                                                                       =
                            =20
> \u2592                 nf_iterate                                    =
                                                                       =
                                                                       =
                           =20
> \u2592                nf_hook_slow                                   =
                                                                       =
                                                                       =
                           =20
> \u2592                 NF_HOOK.clone.1                               =
                                                                       =
                                                                       =
                            =20
> \u2592                 ip_rcv                                        =
                                                                       =
                                                                       =
                            =20
> \u2592                 __netif_receive_skb                           =
                                                                       =
                                                                       =
                            =20
> \u2592                 __netif_receive_skb                           =
                                                                       =
                                                                       =
                            =20
> \u2592                 netif_receive_skb                             =
                                                                       =
                                                                       =
                            =20
> \u2592                 napi_skb_finish                               =
                                                                       =
                                                                       =
                            =20
> \u2592                 napi_gro_receive                              =
                                                                       =
                                                                       =
                            =20
> \u2592                 ixgbe_clean_rx_irq                            =
                                                                       =
                                                                       =
                            =20
> \u2592                 0xffffffffa033a5                              =
                                                                       =
                                                                       =
                            =20
> \u2592                 net_rx_action                                 =
                                                                       =
                                                                       =
                            =20
> \u2592                 __do_softirq                                  =
                                                                       =
                                                                       =
                            =20
> \u2592               + call_softirq                                  =
                                                                       =
                                                                       =
                            =20
> \u2592      + 35.85% find_iova                                       =
                                                                       =
                                                                       =
                            =20
> \u2592      + 19.44% add_unmap     =20
> =20
> =20
> Thanks
> WeiGu
> =20


