From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 08:39:09 +0000
Message-ID: <20080819083909.GG4376@ff.dom.local>
References: <20080818.171124.192743795.davem@davemloft.net> <20080818.210701.80578862.davem@davemloft.net> <20080819064609.GA4376@ff.dom.local> <20080819072316.GA4878@gondor.apana.org.au> <20080819073558.GD4376@ff.dom.local> <20080819074606.GA5261@gondor.apana.org.au> <20080819075623.GE4376@ff.dom.local> <20080819080557.GA17977@gondor.apana.org.au> <20080819081713.GF4376@ff.dom.local> <20080819082355.GA28869@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:52812 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770AbYHSIjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 04:39:17 -0400
Received: by an-out-0708.google.com with SMTP id d40so318320and.103
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 01:39:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080819082355.GA28869@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 06:23:55PM +1000, Herbert Xu wrote:
> On Tue, Aug 19, 2008 at 08:17:13AM +0000, Jarek Poplawski wrote:
> >
> > As I've written before I'm mainly concerned with things like
> > tcf_destroy_chain(), especially wrt. cls_u32, but I can be wrong with
> > this. So, if you don't have such concerns, let's forget it for now,
> > and after I look at this more maybe we'll get back to this discussion.
> 
> Well I can't vouch for every single qdisc in the tree.  However,
> what I can say is that as long as they respect the rules I outlined
> earlier with regards to holding the root qdisc lock when deleting
> or using children, then they'll work as expected.
> 
> You're definitely welcome to audit the qdiscs to make sure that
> they are obeying the rules.

That's my point - is there really a reason do this change without such
an audit if we are not forced at the moment? (I'd remind this way of
doing things was entirely legal according to comments.) I doubt, I'm
the right person for auditing this but as I said I'll have a look,
especially when there will be lack of those fascinating oopses and
warnings around.

Cheers,
Jarek P.
