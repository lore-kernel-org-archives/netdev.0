From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Fri, 28 Aug 2009 12:15:39 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908281211150.7317@gentwo.org>
References: <OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>  <alpine.DEB.1.10.0908251514190.17963@gentwo.org>  <1251239734.3169.65.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908261223210.9933@gentwo.org>
 <1251309040.10599.34.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908261506590.9933@gentwo.org> <1251324666.10599.72.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908271139450.14277@gentwo.org> <alpine.DEB.1.10.0908271621260.28029@gentwo.org>
 <alpine.DEB.1.10.0908280948320.3747@gentwo.org> <4A97F2B4.7030900@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	niv@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:47074 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750778AbZH1QQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 12:16:31 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id AFDFB82C776
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 12:17:43 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QtcfcC5NY60n for <netdev@vger.kernel.org>;
	Fri, 28 Aug 2009 12:17:43 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 710FE82C7C1
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 12:17:14 -0400 (EDT)
In-Reply-To: <4A97F2B4.7030900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Aug 2009, Eric Dumazet wrote:

> "tc -s qdisc show" only displays queue info for tx packets.

Duh. The packet counters and bytes are way out of whack and do not reflect
what was actually sent. This must be some other qdisc.

> >  	sch->qstats.drops++;
> >
> > +	/* device queue statistics */
> > +	sch->dev_queue->tx_dropped++;
> > +
> >  	return NET_XMIT_DROP;
> >  }
>
> locking problem here, tx_dropped can be changed by another cpu.

Who cares. It just was for debugging.

> As David Stevens pointed out, device was not ever called at all when your packet(s) was/were lost.
> Why should we account a non existent drop at device level ?

Because you need drop statistics on a device to figure out when you may
want to increase the TX buffers for a device. If a packet was dropped
because of a lack of TX buffers then we need to know.

> When a process wants a new memory page and hits its own limit, do you want to increment a system global
> counter saying 'memory allocation failed' ?

When a process allocates and locks all of memory then you get an OOM.

> Only change you want is eventually to account for the UDP drop (SndbufErrors).

That is only a counter at the UDP layer. That one does not allow you to
identify which NIC it was nor which application caused it.

But its already a big improvement to see TX drops at all. Could we get
your latest patch merged soon?



