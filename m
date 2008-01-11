From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Fri, 11 Jan 2008 10:11:40 +0100
Message-ID: <20080111091140.GB2183@ff.dom.local>
References: <20080109113727.50eae500.dada1@cosmosbay.com> <20080110231042.GA3199@ami.dom.local> <20080111000020.GB22040@gondor.apana.org.au> <20080111083010.GA2183@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	davem@davemloft.net, dipankar@in.ibm.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.234]:41226 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759554AbYAKJFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 04:05:34 -0500
Received: by hu-out-0506.google.com with SMTP id 19so397483hue.21
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 01:05:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080111083010.GA2183@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2008 at 09:30:10AM +0100, Jarek Poplawski wrote:
> On Fri, Jan 11, 2008 at 11:00:20AM +1100, Herbert Xu wrote:
> > On Fri, Jan 11, 2008 at 12:10:42AM +0100, Jarek Poplawski wrote:
> > >
> > > It seems this optimization could've a side effect: if during such a
> > > loop updates are done, and r is seen !NULL during while() check, but
> > > NULL after rcu_dereference(), the listing/counting could stop too
> > > soon. So, IMHO, probably the first version of this patch is more
> > > reliable. (Or alternatively additional check is needed before return.)
> > 
> > No, while the value of r->u.dst.rt_next can change between two readings,
> > the value of r cannot.
> 
> ...Then, of course, it's O.K.!
> 
> It looks like I'm really too lazy and/or these selfdocumenting features
> of RCU are a bit overrated: one can never be sure which pointer is
> really RCU protected without checking a few places?! So, after looking
> at this rt_cache_get_next() and this patch only, it's looks like the
> third candidate after seq->private and rtable...

OOPS! ...it seems we are talking about the same, properly documented
(second) poiner yet...

So, IOW: strictly speaking you are right, r can't change here, but I
meant r vs. the returned value! Before the patch the returned value
couldn't be NULL unless all elements of the list were looped. After
this patch it seems possible...

Jarek P.
