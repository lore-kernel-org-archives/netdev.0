From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet6: Fix paramater issue of inet6_csk_xmit
Date: Fri, 01 Aug 2008 02:18:25 -0700 (PDT)
Message-ID: <20080801.021825.51896743.davem@davemloft.net>
References: <48929C5B.5030108@cn.fujitsu.com>
	<E1KOqf7-0004lB-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43374
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750936AbYHAJSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 05:18:25 -0400
In-Reply-To: <E1KOqf7-0004lB-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 01 Aug 2008 17:11:01 +0800

> Wei Yongjun <yjwei@cn.fujitsu.com> wrote:
> >
> > inet6_csk_xmit() just be used by tcp and dccp:
> > 1042 net/dccp/ipv6.c      .queue_xmit       = inet6_csk_xmit
> > 1853 net/ipv6/tcp_ipv6.c     .queue_xmit       = inet6_csk_xmit,
> > 
> > And used always with ipfragok = 0.
> > 139 net/dccp/output.c         err = icsk->icsk_af_ops->queue_xmit(skb, 0);
> > 626 net/ipv4/tcp_output.c     err = icsk->icsk_af_ops->queue_xmit(skb, 0);
> > 
> > I can not find any place used inet6_csk_xmit() with ipfragok = 1.
> > 
> > So I think it is safe to apply this patch. Or maybe this paramater is 
> > useless.
> 
> No we should get rid of the ipfragok argument if noone uses it.

SCTP calls ip_queue_xmit() and ip6_xmit() directly with it's ipfragok
argument, so it is used for these functions.

As a result ->icsk_af_ops->queue_xmit() needs to have arguments
at least matching those function's prototypes.





