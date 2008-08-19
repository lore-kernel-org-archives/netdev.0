From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 01:32:05 -0700 (PDT)
Message-ID: <20080819.013205.72459707.davem@davemloft.net>
References: <20080819080557.GA17977@gondor.apana.org.au>
	<20080819081713.GF4376@ff.dom.local>
	<20080819082355.GA28869@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, denys@visp.net.lb
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48977
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750992AbYHSIcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 04:32:06 -0400
In-Reply-To: <20080819082355.GA28869@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 19 Aug 2008 18:23:55 +1000

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

Jarek may have a point about the u32 classifier.  So we
should think about it.

The hash tables and tp_u_common objects are shared, and
it does non-atomic refcounting during destruction, see
u32_destroy().

However, this all might be OK because all of this management
is performed only under the RTNL semaphore.
