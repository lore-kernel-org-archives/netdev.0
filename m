From: Wei Gu <wei.gu@ericsson.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Sat, 9 Apr 2011 11:51:23 +0800
Message-ID: <D12839161ADD3A4B8DA63D1A134D084026E48BA6B0@ESGSCCMS0001.eapac.ericsson.se>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	<1302153412.2701.64.camel@edumazet-laptop>
	<1302157012.2701.73.camel@edumazet-laptop>
	<D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>
	<1302163650.3357.8.camel@edumazet-laptop>
	<D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>
	<1302167168.3357.12.camel@edumazet-laptop>
	<D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se>
	<1302176811.3357.15.camel@edumazet-laptop>	<4D9DDF43.9080302@intel.com>
	<1302192218.3357.47.camel@edumazet-laptop>	<4D9DE465.1080008@intel.com>
	<D12839161ADD3A4B8DA63D1A134D084026E48BA58D@ESGSCCMS0001.eapac.ericsson.se>
	<1302253651.4409.2.camel@edumazet-laptop>
	<D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>
	<1302267400.4409.22.camel@edumazet-laptop>
	<D12839161ADD3A4B8DA63D1A134D084026E48BA682@ESGSCCMS0001.eapac.ericsson.se>
 <20110408074902.2bd10e6b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:47546 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759Ab1DIDv2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 23:51:28 -0400
In-Reply-To: <20110408074902.2bd10e6b@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,
Thanks for you reply,
I do awared that local Bus, local CPU socket would gain +20% performanc=
e, that why I put the eth10 on core 24-31 (sock 3) and NUMA Node 2/3.

Thanks
WeiGu

-----Original Message-----
=46rom: Stephen Hemminger [mailto:shemminger@vyatta.com]
Sent: Friday, April 08, 2011 10:49 PM
To: Wei Gu
Cc: Eric Dumazet; Alexander Duyck; netdev; Kirsher, Jeffrey T
Subject: Re: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel

On Fri, 8 Apr 2011 22:10:50 +0800
Wei Gu <wei.gu@ericsson.com> wrote:

> Hi,
> Got you mean.
> But as I decribed before, I start the eth10 with 8 rx queues and 8 tx
> queues, and then I binding these 8 tx&rx queue each to CPU core 24-32
> (NUMA3), which I think could gain the best performance in my case
> (It's true on Linux 2.6.32) single queue ->single CPU Then I can
> descibe a little bit with packet generator, I config the IXIA to
> continues increase the dest ip address towards the test server, so th=
e
> packet was evenly distributed to each receving queues of the eth10.
> And according the IXIA tools the transmit sharp was really good, no
> too much peaks
>
> What I observed on Linux 2.6.38 during the test, there is no softqd
> was stressed (< 03% on SI for each core(24-31)) while the packet lost
> happens, so we are not really stress the CPU:), It looks like we are
> limited  on some memory bandwidth (DMA) on this release
>
> And with same test case on 2.6.32, no such problem at all. It running
> pretty stable > 2Mpps without rx_missing_error. There is no HW
> limitation on this DL580
>
>
> BTW what is these "swapper"
> +      0.80%          swapper  [ixgbe]                    [k] ixgbe_p=
oll
> +      0.79%             perf  [ixgbe]                    [k] ixgbe_p=
oll
> Why the ixgbe_poll was on swapper/perf?
>
> Thanks
> WeiGu
>
> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> Sent: Friday, April 08, 2011 8:57 PM
> To: Wei Gu
> Cc: Alexander Duyck; netdev; Kirsher, Jeffrey T
> Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
>
> Le vendredi 08 avril 2011 =E0 20:19 +0800, Wei Gu a =E9crit :
> > Hi again,
> > I tried more testing with by disable this CONFIG_DMAR with shipped
> > 2.6.38 ixgbe and Intel released 3.2.10/3.1.15.
> > All these test looks we can get >1Mpps 400bype packtes but not
> > stable at all, there will huge number missing errors with 100% CPU =
IDLE:
> > ethtool -S eth10 |grep rx_missed_errors
> >
> >         rx_missed_errors: 76832040
> >
> > SUM: 1102212 ETH8: 0  ETH10: 1102212 ETH6: 0 ETH4: 0
> > SUM: 521841 ETH8: 0  ETH10: 521841 ETH6: 0 ETH4: 0
> > SUM: 426776 ETH8: 0  ETH10: 426776 ETH6: 0 ETH4: 0
> > SUM: 927520 ETH8: 0  ETH10: 927520 ETH6: 0 ETH4: 0
> > SUM: 1171995 ETH8: 0  ETH10: 1171995 ETH6: 0 ETH4: 0
> > SUM: 855980 ETH8: 0  ETH10: 855980 ETH6: 0 ETH4: 0
> >
> >
> > Do you know if there is other options in the kernel will cause high
> > rate rx_missed_errors with low CPU usage. (No problem on 2.6.32 wit=
h
> > same test case)
> >
> > perf  record:
> > +     69.74%          swapper  [kernel.kallsyms]          [k] poll_=
idle
> > +     11.62%          swapper  [kernel.kallsyms]          [k] intel=
_idle
> > +      0.80%          swapper  [ixgbe]                    [k] ixgbe=
_poll
> > +      0.79%             perf  [ixgbe]                    [k] ixgbe=
_poll
> > +      0.77%             perf  [kernel.kallsyms]          [k] skb_c=
opy_bits
> > +      0.64%          swapper  [kernel.kallsyms]          [k] skb_c=
opy_bits
> > +      0.48%             perf  [kernel.kallsyms]          [k] __kma=
lloc_node_track_caller
> > +      0.44%          swapper  [kernel.kallsyms]          [k] __kma=
lloc_node_track_caller
> > +      0.36%          swapper  [kernel.kallsyms]          [k] kmem_=
cache_alloc_node
> > +      0.35%          swapper  [kernel.kallsyms]          [k] kfree
> > +      0.35%             perf  [kernel.kallsyms]          [k] kmem_=
cache_alloc_node
> >
>
>
> Make sure enough cpus serves interrupts, _before_ even starting your =
stress test.
>
> Then, make sure trafic is distributed to many different queues.
> If a single flow is used, it probably uses a single queue ->single CP=
U.
>
> Say you have irq affinities set to fffffffffffff  (all cpus able to
> serve IRQ X,Y,Z,T,...)
>
> Then you have a network burst (because you start your packet generato=
r at full rate), spreaded on many queues.
>
> CPU0 takes hard interrupt for queue 0, eth8, and queues NAPI mode.
> CPU0 takes hard interrupt for queue 0, eth10, and queues NAPI mode.
> CPU0 takes hard interrupt for queue 1, eth8, and queues NAPI mode.
> CPU0 takes hard interrupt for queue 1, eth10, and queues NAPI mode.
> CPU0 takes hard interrupt for queue 2, eth8, and queues NAPI mode.
> CPU0 takes hard interrupt for queue 2, eth10, and queues NAPI mode.
> ...
> CPU0 takes hard interrupt for queue X, eth8, and queues NAPI mode.
> ...
>
> Then softirq can start, and only CPU0 is able to handle NAPI for all =
the queued devices. You are stuck, with CPU0 never leaving ksoftirqd.
>
> NAPI handling is always performed on the CPU that received the hardwa=
re interrupt, until we exit NAPI (and rearm interrupt delivery).
> It cannot migrate to an "idle cpu"

=46or performance, you need to assign each network interrupt to a singl=
e CPU. There is no load balancing effect in the IRQ controller.

If you have a multi-socket system, then it is a good idea to make the I=
RQ's for the NIC's be on the same socket as the bus interface. Multi so=
cket systems are really NUMA and putting IRQ on non-local CPU has measu=
rable impact.



--
