From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: IPv6 xfrm GSO fragmentation bug
Date: Mon, 7 Sep 2015 12:00:45 +0200
Message-ID: <20150907100044.GH25499@secunet.com>
References: <20150830082432.GA25588@gondor.apana.org.au>
 <20150831071916.GG25499@secunet.com>
 <20150831073526.GA31958@gondor.apana.org.au>
 <20150904052106.GA5689@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47819 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750816AbbIGKAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Sep 2015 06:00:50 -0400
Content-Disposition: inline
In-Reply-To: <20150904052106.GA5689@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 04, 2015 at 01:21:06PM +0800, Herbert Xu wrote:
> On Mon, Aug 31, 2015 at 03:35:26PM +0800, Herbert Xu wrote:
> > 
> > I see where the bug came from.  Indeed IPv6 does do fragmentation
> > but only for tunnel mode.  While your patch added a check that also
> > affected transport mode.  So in addition to the GSO fix we should
> > also make the MTU check conditional to tunnel mode.
> 
> Here is the patch:
> 
> ---8<---
> ipv6: Fix IPsec pre-encap fragmentation check
> 
> The IPv6 IPsec pre-encap path performs fragmentation for tunnel-mode
> packets.  That is, we perform fragmentation pre-encap rather than
> post-encap.
> 
> A check was added later to ensure that proper MTU information is
> passed back for locally generated traffic.  Unfortunately this
> check was performed on all IPsec packets, including transport-mode
> packets.
> 
> What's more, the check failed to take GSO into account.
> 
> The end result is that transport-mode GSO packets get dropped at
> the check.
> 
> This patch fixes it by moving the tunnel mode check forward as well
> as adding the GSO check.
> 
> Fixes: dd767856a36e ("xfrm6: Don't call icmpv6_send on local error")
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to the ipsec tree, thanks Herbert!
