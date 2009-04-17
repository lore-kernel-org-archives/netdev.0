From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: htb parallelism on multi-core platforms
Date: Fri, 17 Apr 2009 15:33:36 +0400
Message-ID: <49E86910.7020804@bigtelecom.ru>
References: <1239964844.21569.57.camel@blade.ines.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:60993 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756636AbZDQLok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 07:44:40 -0400
In-Reply-To: <1239964844.21569.57.camel@blade.ines.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello

100% SI on ksoftirqd on one CPU because PC can't forward such packets
(napi off if i understand). 2 cpu xeon 2.4 ghz can forward about 400-500
mbs full duplex with about 20-30k htb rules. If we try do more - we get
100% SI. Its our example.

We now use multiple pc for this and will try to by intel 10G with A/IO
that can use Multiqueue.

Anyone can say:
How match CPU we must have for about 5-7G in/out with 2 x intel 10G +
A/IO (1x10g to lan + 1x10g to wan) ?
Any statistic or formula to calculate? pps or mbs?
tc + iptables (+ipset) now use 10-30%. All other cpu now use e1000e driver.

Thanks

> Hi,
>
> I'm using htb on a dedicated shaping machine. Under heavy traffic (high
> packet rate) all htb work is done on a single cpu - only one ksoftirqd
> is consuming cpu power.
>
> I have limited network stack knowledge, but I guess all htb work for a
> particular interface is done on the same softirq context. Of course this
> does not scale with multiple cpus, since only one of them would be used.
>
> Is there any (simple) approach to distribute htb work (for one
> interface) on multiple cpus?
>
> Thanks,
>
> Radu Rendec
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   

