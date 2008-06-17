From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Tue, 17 Jun 2008 04:17:22 +0200
Message-ID: <48571EB2.50301@cosmosbay.com>
References: <20080616193501.M64730@visp.net.lb> <4856C3A7.9070703@cosmosbay.com> <20080616202210.M84100@visp.net.lb> <4856CEDC.6010706@intel.com> <20080616204411.M52834@visp.net.lb> <4856D1D6.7040207@intel.com> <20080616211213.M76390@visp.net.lb> <4856DB1D.80503@cosmosbay.com> <20080616213419.M212@visp.net.lb> <4856DE1F.4090001@cosmosbay.com> <4856DEA7.9060506@cosmosbay.com> <20080616220004.M32074@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.152]:14597 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753289AbYFQCR1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 22:17:27 -0400
In-Reply-To: <20080616220004.M32074@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko a e'crit :
> On Mon, 16 Jun 2008 23:44:07 +0200, Eric Dumazet wrote
> 
> opreport -l /mnt/flash/vmlinux |more
> Here is oprofile
> CPU: Core 2, speed 2397.64 MHz (estimated)
> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit
> mask of 0x00 (Unhalted core cycles) count 100000
> samples  %        symbol name
> 25409    15.0068  mwait_idle
> 14330     8.4634  ip_route_input
> 7827      4.6227  irq_entries_start
> 6488      3.8319  dev_queue_xmit
> 5497      3.2466  __qdisc_run
> 5033      2.9725  __slab_free
> 3569      2.1079  native_read_tsc
> 3560      2.1026  ip_rcv
> 3520      2.0789  __alloc_skb
> 3435      2.0287  __kmalloc_track_caller
> 3381      1.9968  kmem_cache_alloc
> 3340      1.9726  ip_forward
> 3289      1.9425  kfree
> 
> MegaRouter-KARAM /lib # opreport
> CPU: Core 2, speed 2397.64 MHz (estimated)
> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit
> mask of 0x00 (Unhalted core cycles) count 100000
> CPU_CLK_UNHALT...|
>   samples|      %|
> ------------------
>    612990 64.5673 vmlinux
>    276274 29.1004 e1000e
>     31470  3.3148 ip_tables

How often is iptables used on your machine ?

>      9676  1.0192 libzebra.so.0.0.0
>      3763  0.3964 oprofiled
> 
> MegaRouter-KARAM ~ # opreport image:/e1000e -l
> CPU: Core 2, speed 2397.64 MHz (estimated)
> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit
> mask of 0x00 (Unhalted core cycles) count 100000
> warning: could not check that the binary file /e1000e has not been modified
> since the profile was taken. Results may be inaccurate.
> samples  %        symbol name
> 144449   25.7521  e1000_irq_enable

I wonder why this one is called so often. If your
interface is really flooded with packets, we should not
exit from NAPI polling...


> 97006    17.2941  e1000_intr_msi
> 95009    16.9380  e1000_clean_rx_irq
> 87833    15.6587  e1000_xmit_frame
> 53723     9.5776  e1000_clean_tx_irq
> 26546     4.7326  e1000_clean
> 19968     3.5599  e1000_alloc_rx_buffers
> 11941     2.1288  e1000_receive_skb
> 6578      1.1727  e1000_update_itr
> 5864      1.0454  e1000_desc_unused
> 4847      0.8641  e1000_maybe_stop_tx
> 3537      0.6306  e1000_put_txbuf
> 3490      0.6222  e1000_rx_checksum
> 107       0.0191  e1000e_update_stats
> 9         0.0016  e1000_acquire_swflag_ich8lan
> 7         0.0012  e1000_release_swflag_ich8lan
> 5        8.9e-04  e1000e_read_phy_reg_mdic
> 1        1.8e-04  e1000_get_settings
> 1        1.8e-04  e1000_ioctl





