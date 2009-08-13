From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] Speed-up pfifo_fast lookup using a bitmap
Date: Thu, 13 Aug 2009 16:11:57 +0530
Message-ID: <OFD762AF41.E7A6EE8D-ON65257611.00389F3C-65257611.003AC5BB@in.ibm.com>
References: <20090813072818.7541.77365.sendpatchset@localhost.localdomain> <20090813100826.GA6042@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, kaber@trash.net,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([59.145.155.7]:36228 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701AbZHMKmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 06:42:05 -0400
In-Reply-To: <20090813100826.GA6042@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Jarek Poplawski <jarkao2@gmail.com>
>
> > but the test numbers came a little less, since it takes a few more
> > memory references on enqueue/dequeue.
>
> If it's exactly "a little less" I'd consider keeping it private yet...

Sounds reasonable. To quantify that, I will test again for a longer
run and report the difference.

> Btw, I wonder how much gain of your previous (_CAN_BYPASS) patch is
> saved after this change...

The tests are on the latest tree which contains CAN_BYPASS. So a
single netperf process running this change will get no advantage
since this enqueue/dequeue never happens unless the NIC is slow.
But for multiple processes, it should help.

>  - * Convert a bitmap to the first band number where an skb is queue'd,
where:
>  + * Convert a bitmap to the first band number where an skb is queued,
where:
>
> > + *    bitmap=0 means there are no skbs for any bands
> > + *    bitmap=1 means there is a skb on band 0
>
>  - *    bitmap=1 means there is a skb on band 0
>  + *    bitmap=1 means there is an skb on band 0
>
> > + *   bitmap=7 means there are skbs on all 3 bands, etc.
> > + */
> > +static const int bitmap2band[] =
> > +   {-1, 0, 1, 0, 2, 0, 1, 0};
>
> Why wrapped?

cut-n-paste of prio2band, I will fix this and the above comments.

>
> ...
>  ... pfifo_fast_reset(...)
>  {
>    ...
> +   qdisc->bitmap = 0; ?
>  }

Correct. Thanks for pointing this out.

Regards,

- KK

