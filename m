From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Wed, 27 Aug 2008 20:35:18 -0700
Message-ID: <20080827203518.7f6075a0@extreme>
References: <200808220457.40892.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:42070 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753660AbYH1DfU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 23:35:20 -0400
In-Reply-To: <200808220457.40892.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Aug 2008 04:57:40 +0300
Denys Fedoryshchenko <denys@visp.net.lb> wrote:

> I have loaded router (~650 Mbps In+Out), based on 2xAMD Opteron 248, Sun Fire 
> X4100. HPET timer available (TSC seems not available on this platform).
> Network interfaces is onboard, connected over PCI-X.
> 
> Right now i am using only one processor, cause using only one interface and 
> interrupts stick to it. Other is almost not used.
> At peak time i notice in mpstat, that this processor is almost "dead", and if 
> i run minor application consuming resources - ping over this router will be 
> terrible. For me it is clear - system overloaded. I did oprofile, and here is 
> result (at low load time, but at peak time it is very similar).
> 
> CPU: AMD64 processors, speed 2193.74 MHz (estimated)
> Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a unit 
> mask of 0x00 (No unit mask) count 100000
> CPU_CLK_UNHALT...|
>   samples|      %|
> ------------------
>   2679376 71.9851 vmlinux
>    287212  7.7163 e1000
>    278674  7.4870 ip_tables
>    259923  6.9832 nf_conntrack
>     29699  0.7979 iptable_nat
>     26752  0.7187 nf_nat
>     26093  0.7010 nf_conntrack_ipv4
>     16525  0.4440 iptable_mangle
>     14988  0.4027 oprofiled
> 
> 
> CPU: AMD64 processors, speed 2193.74 MHz (estimated)
> Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a unit 
> mask of 0x00 (No unit mask) count 100000
> samples  %        symbol name
> 1031727  37.1736  getnstimeofday
> 230457    8.3035  __napi_schedule
> 122154    4.4013  __do_softirq
> 110036    3.9647  dev_queue_xmit
> 88800     3.1995  net_rx_action
> 71163     2.5640  ip_route_input
> 52232     1.8819  local_bh_enable
> 43804     1.5783  get_next_timer_interrupt
> 43387     1.5633  ip_forward
> 35501     1.2791  nf_iterate
> 35212     1.2687  __slab_alloc
> 34652     1.2485  default_idle
> 32375     1.1665  kfree
> 28127     1.0134  kmem_cache_alloc
> 
> What is bothering me, why getnstimeofday called so much? Even i remove HTB 
> shaper, it still takes 30-40% of whole vmlinux time. From other 
> applications - only zebra is running.
> Any ideas?

What kernel version is this?  There was a fix to AF_PACKET about a year ago
to reduce this.
