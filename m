From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Fri, 11 Jan 2008 09:30:10 +0100
Message-ID: <20080111083010.GA2183@ff.dom.local>
References: <20080109113727.50eae500.dada1@cosmosbay.com> <20080110231042.GA3199@ami.dom.local> <20080111000020.GB22040@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	davem@davemloft.net, dipankar@in.ibm.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:42011 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848AbYAKIX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 03:23:59 -0500
Received: by ug-out-1314.google.com with SMTP id z38so435307ugc.16
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 00:23:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080111000020.GB22040@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2008 at 11:00:20AM +1100, Herbert Xu wrote:
> On Fri, Jan 11, 2008 at 12:10:42AM +0100, Jarek Poplawski wrote:
> >
> > It seems this optimization could've a side effect: if during such a
> > loop updates are done, and r is seen !NULL during while() check, but
> > NULL after rcu_dereference(), the listing/counting could stop too
> > soon. So, IMHO, probably the first version of this patch is more
> > reliable. (Or alternatively additional check is needed before return.)
> 
> No, while the value of r->u.dst.rt_next can change between two readings,
> the value of r cannot.

...Then, of course, it's O.K.!

It looks like I'm really too lazy and/or these selfdocumenting features
of RCU are a bit overrated: one can never be sure which pointer is
really RCU protected without checking a few places?! So, after looking
at this rt_cache_get_next() and this patch only, it's looks like the
third candidate after seq->private and rtable...

Thanks for explanation and sorry for disturbing!
Jarek P.
