From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ver2] Avoid enqueuing skb for default qdiscs
Date: Thu, 06 Aug 2009 13:41:26 -0700 (PDT)
Message-ID: <20090806.134126.58668200.davem@davemloft.net>
References: <20090806114421.19208.39374.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, kaber@trash.net
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53057
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753343AbZHFUlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 16:41:17 -0400
In-Reply-To: <20090806114421.19208.39374.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Thu, 06 Aug 2009 17:14:21 +0530

> -
>  static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
>  {
>  	q->gso_skb = skb;
>  	q->qstats.requeues++;
> +	q->q.qlen++;	/* it's still part of the queue */
>  	__netif_schedule(q);
>  
>  	return 0;

I'm dubious about this new qlen accounting scheme, does it handle
the non-bypass case properly?  Can you explain how it works
exactly?
