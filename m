From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 08:41:48 +0000
Message-ID: <20080819084147.GH4376@ff.dom.local>
References: <20080819080557.GA17977@gondor.apana.org.au> <20080819081713.GF4376@ff.dom.local> <20080819082355.GA28869@gondor.apana.org.au> <20080819.013205.72459707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:45288 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753053AbYHSIlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 04:41:55 -0400
Received: by wx-out-0506.google.com with SMTP id h29so2648023wxd.4
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 01:41:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080819.013205.72459707.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 01:32:05AM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Tue, 19 Aug 2008 18:23:55 +1000
> 
> > On Tue, Aug 19, 2008 at 08:17:13AM +0000, Jarek Poplawski wrote:
> > >
> > > As I've written before I'm mainly concerned with things like
> > > tcf_destroy_chain(), especially wrt. cls_u32, but I can be wrong with
> > > this. So, if you don't have such concerns, let's forget it for now,
> > > and after I look at this more maybe we'll get back to this discussion.
> > 
> > Well I can't vouch for every single qdisc in the tree.  However,
> > what I can say is that as long as they respect the rules I outlined
> > earlier with regards to holding the root qdisc lock when deleting
> > or using children, then they'll work as expected.
> > 
> > You're definitely welcome to audit the qdiscs to make sure that
> > they are obeying the rules.
> 
> Jarek may have a point about the u32 classifier.  So we
> should think about it.
> 
> The hash tables and tp_u_common objects are shared, and
> it does non-atomic refcounting during destruction, see
> u32_destroy().
> 
> However, this all might be OK because all of this management
> is performed only under the RTNL semaphore.

Sure, this all should be write protected. I'm concerned only about
the read side here.

Jarek P.
