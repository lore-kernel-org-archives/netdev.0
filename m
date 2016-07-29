From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec] xfrm: Ignore socket policies when rebuilding hash
 tables
Date: Fri, 29 Jul 2016 12:40:17 +0200
Message-ID: <20160729104017.GA5710@gauss.secunet.com>
References: <8e6b1395-6f17-66ce-e257-6b6073ca7103@strongswan.org>
 <20160729081911.GC11307@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tobias Brunner <tobias@strongswan.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Christophe Gouault <christophe.gouault@6wind.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:56514 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751433AbcG2KkW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 06:40:22 -0400
Content-Disposition: inline
In-Reply-To: <20160729081911.GC11307@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 29, 2016 at 04:19:11PM +0800, Herbert Xu wrote:
> On Fri, Jul 29, 2016 at 09:57:32AM +0200, Tobias Brunner wrote:
> > Whenever thresholds are changed the hash tables are rebuilt.  This is
> > done by enumerating all policies and hashing and inserting them into
> > the right table according to the thresholds and direction.
> > 
> > Because socket policies are also contained in net->xfrm.policy_all but
> > no hash tables are defined for their direction (dir + XFRM_POLICY_MAX)
> > this causes a NULL or invalid pointer dereference after returning from
> > policy_hash_bysel() if the rebuild is done while any socket policies
> > are installed.
> > 
> > Since the rebuild after changing thresholds is scheduled this crash
> > could even occur if the userland sets thresholds seemingly before
> > installing any socket policies.
> > 
> > Fixes: 53c2e285f970 ("xfrm: Do not hash socket policies")
> > Signed-off-by: Tobias Brunner <tobias@strongswan.org>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to the ipsec tree, thanks a lot Tobias!
