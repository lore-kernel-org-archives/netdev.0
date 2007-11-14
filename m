From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/24] [IPSEC]: Move x->outer_mode->output out of
 locked section
Date: Tue, 13 Nov 2007 21:47:21 -0800 (PST)
Message-ID: <20071113.214721.175353911.davem@davemloft.net>
References: <20071108003903.GA11963@gondor.apana.org.au>
	<20071113.033348.13935138.davem@davemloft.net>
	<20071113115119.GA1086@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@axxeo.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39589
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750759AbXKNFrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:47:22 -0500
In-Reply-To: <20071113115119.GA1086@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 13 Nov 2007 19:51:19 +0800

> On Tue, Nov 13, 2007 at 03:33:48AM -0800, David Miller wrote:
> >
> > Make 'lastused' an 'unsigned long' (that's all that get_seconds()
> > gives to us anyways), fix up the nla_total_size(x->lastused) thing in
> > net/xfrm/xfrm_user.c, and then you can remove this lock acquisition
> > completely because the store into x->lastused will now be atomic and
> > therefore locks aren't protecting anything.
> 
> Brilliant, make that patch 25/25 :)
> 
> [IPSEC]: Make x->lastused an unsigned long
> 
> Currently x->lastused is u64 which means that it cannot be read/written
> atomically on all architectures.  David Miller observed that the value
> stored in it is only an unsigned long which is always atomic.
> 
> So based on his suggestion this patch changes the internal representation
> from u64 to unsigned long while the user-interface still refers to it as
> u64.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25 :)
