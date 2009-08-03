From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] [PATCH] Avoid enqueuing skb for default qdiscs
Date: Mon, 3 Aug 2009 22:22:24 +0200
Message-ID: <20090803202224.GB3471@ami.dom.local>
References: <OF1689973C.61968A07-ON65257607.003168D7-65257607.0033083B@in.ibm.com> <20090803193847.GA3471@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, kaber@trash.net,
	netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:38474 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753475AbZHCUWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 16:22:44 -0400
Received: by fxm17 with SMTP id 17so2867241fxm.37
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2009 13:22:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090803193847.GA3471@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 03, 2009 at 09:38:47PM +0200, Jarek Poplawski wrote:
> Krishna Kumar2 wrote, On 08/03/2009 11:17 AM:
> > Krishna Kumar2/India/IBM@IBMIN wrote on 08/03/2009 01:40:16 PM:
> > 
> >> Krishna Kumar2/India/IBM@IBMIN
> >> 08/03/2009 01:40 PM
...
> >> [RFC] [PATCH] Avoid enqueuing skb for default qdiscs
> >>
> >> From: Krishna Kumar <krkumar2@in.ibm.com>
...
> >> @@ -547,8 +561,11 @@ void qdisc_reset(struct Qdisc *qdisc)
> >>     if (ops->reset)
> >>        ops->reset(qdisc);
> >>
> >> -   kfree_skb(qdisc->gso_skb);
> >> -   qdisc->gso_skb = NULL;
> >> +   if (qdisc->gso_skb) {
> >> +      kfree_skb(qdisc->gso_skb);
> >> +      qdisc->gso_skb = NULL;
> >> +      qdisc->q.qlen--;
> 
> You don't need this here: qdiscs should zero it in ops->reset().

Actually, there're some exceptions, so until it's fixed maybe you
should better zero it here too.

Jarek P.

> 
> >> +   }
> >>  }
> >>  EXPORT_SYMBOL(qdisc_reset);
