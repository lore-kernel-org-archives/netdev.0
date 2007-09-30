From: David Miller <davem@davemloft.net>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Sat, 29 Sep 2007 17:13:39 -0700 (PDT)
Message-ID: <20070929.171339.59681016.davem@davemloft.net>
References: <E1IbT8r-0000Av-00@gondolin.me.apana.org.au>
	<46FE6D73.4000002@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33174
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753613AbXI3ANj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 20:13:39 -0400
In-Reply-To: <46FE6D73.4000002@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 29 Sep 2007 17:21:23 +0200

> Unfortunately gcc doesn't perform tail call optimization when the
> address of a parameter or local variable is passed to an extern
> function before the tail call, which NF_HOOK does for the skb.

To which Herbert later asked why we need the **pskb thing.

The reason is that if we have to COW or resize the SKB it
could result in a realloc of the sk_buff struct which is
why we need the **pskb thing.

But strangely I can't find any skbuff.h interfaces that
require that any longer :-)))  So this might be some artifact
that we can in fact kill off.
