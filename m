From: Damien Wyart <damien.wyart@gmail.com>
Subject: Re: [RFC PATCH] udp: don't rereference dst_entry dev pointer on rcv
Date: Sat, 23 Mar 2013 11:31:39 +0100
Message-ID: <20130323103139.GA4190@brouette>
References: <1362695800-8633-1-git-send-email-tparkin@katalix.com>
 <1362695800-8633-2-git-send-email-tparkin@katalix.com>
 <1362696444.15793.220.camel@edumazet-glaptop>
 <20130307.181527.390191009324148471.davem@davemloft.net>
 <20130313232743.GA3686@raven>
 <1363223884.29475.0.camel@edumazet-glaptop>
 <20130314144550.GB2512@raven>
 <1363273531.29475.21.camel@edumazet-glaptop>
 <1363274946.29475.24.camel@edumazet-glaptop>
 <20130314161436.GC2512@raven>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Parkin <tparkin@katalix.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhost-p3-p2.mangoosta.org ([195.5.209.60]:43119 "EHLO
	smtp-delay1.nerim.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750998Ab3CWKkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 06:40:10 -0400
Received: from mallaury.nerim.net (smtp-106-saturday.noc.nerim.net [178.132.17.106])
	by smtp-delay1.nerim.net (Postfix) with ESMTP id 2024A23407C
	for <netdev@vger.kernel.org>; Sat, 23 Mar 2013 10:57:36 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20130314161436.GC2512@raven>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

* Tom Parkin <tparkin@katalix.com> [2013-03-14 16:14]:
> On Thu, Mar 14, 2013 at 04:29:06PM +0100, Eric Dumazet wrote:
> > OK, I tested the following one instead, please test it so that I can send an official patch.

> > Thanks

> > diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> > index b6d30ac..2d23830 100644
> > --- a/net/ipv4/ip_fragment.c
> > +++ b/net/ipv4/ip_fragment.c
> > @@ -529,6 +529,7 @@ found:
> >  	    qp->q.meat == qp->q.len)
> >  		return ip_frag_reasm(qp, prev, dev);

> > +	skb_dst_drop(skb);
> >  	inet_frag_lru_move(&qp->q);
> >  	return -EINPROGRESS;

> Thanks again, Eric.

> Sadly, with this patch the oops is back :-(  It falls over quite
> quickly for me.

Just a quick check: do you plan to have another look at this in the
coming days/weeks? You said you had a huge backlog, but in the meantime,
you sent many patches on many topics, so just wanted to check if this
one had not be forgotten for ever.

Thanks,
-- 
Damien Wyart
