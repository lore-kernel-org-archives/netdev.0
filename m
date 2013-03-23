From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] udp: don't rereference dst_entry dev pointer on rcv
Date: Sat, 23 Mar 2013 08:09:37 -0700
Message-ID: <1364051377.4431.85.camel@edumazet-glaptop>
References: <1362695800-8633-1-git-send-email-tparkin@katalix.com>
	 <1362695800-8633-2-git-send-email-tparkin@katalix.com>
	 <1362696444.15793.220.camel@edumazet-glaptop>
	 <20130307.181527.390191009324148471.davem@davemloft.net>
	 <20130313232743.GA3686@raven> <1363223884.29475.0.camel@edumazet-glaptop>
	 <20130314144550.GB2512@raven> <1363273531.29475.21.camel@edumazet-glaptop>
	 <1363274946.29475.24.camel@edumazet-glaptop> <20130314161436.GC2512@raven>
	 <20130323103139.GA4190@brouette>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Parkin <tparkin@katalix.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Damien Wyart <damien.wyart@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:60905 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050Ab3CWPJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 11:09:40 -0400
Received: by mail-pd0-f179.google.com with SMTP id x10so1990345pdj.38
        for <netdev@vger.kernel.org>; Sat, 23 Mar 2013 08:09:40 -0700 (PDT)
In-Reply-To: <20130323103139.GA4190@brouette>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-03-23 at 11:31 +0100, Damien Wyart wrote:
> Hi Eric,
> 
> * Tom Parkin <tparkin@katalix.com> [2013-03-14 16:14]:
> > On Thu, Mar 14, 2013 at 04:29:06PM +0100, Eric Dumazet wrote:
> > > OK, I tested the following one instead, please test it so that I can send an official patch.
> 
> > > Thanks
> 
> > > diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> > > index b6d30ac..2d23830 100644
> > > --- a/net/ipv4/ip_fragment.c
> > > +++ b/net/ipv4/ip_fragment.c
> > > @@ -529,6 +529,7 @@ found:
> > >  	    qp->q.meat == qp->q.len)
> > >  		return ip_frag_reasm(qp, prev, dev);
> 
> > > +	skb_dst_drop(skb);
> > >  	inet_frag_lru_move(&qp->q);
> > >  	return -EINPROGRESS;
> 
> > Thanks again, Eric.
> 
> > Sadly, with this patch the oops is back :-(  It falls over quite
> > quickly for me.
> 
> Just a quick check: do you plan to have another look at this in the
> coming days/weeks? You said you had a huge backlog, but in the meantime,
> you sent many patches on many topics, so just wanted to check if this
> one had not be forgotten for ever.

Hi Damien. This one is part of my backlog, I will send a patch soon.

Thanks
