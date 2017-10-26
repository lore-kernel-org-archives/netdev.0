From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH 07/12] xfrm: Move child route linkage into xfrm_dst.
Date: Thu, 26 Oct 2017 09:03:11 +0200
Message-ID: <20171026070311.GS3323@secunet.com>
References: <20171025.230359.995821396512483745.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:41888 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750997AbdJZHDN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 03:03:13 -0400
Content-Disposition: inline
In-Reply-To: <20171025.230359.995821396512483745.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 11:03:59PM +0900, David Miller wrote:
> 
> XFRM bundle child chains look like this:
> 
> 	xdst1 --> xdst2 --> xdst3 --> path_dst
> 
> All of xdstN are xfrm_dst objects and xdst->u.dst.xfrm is non-NULL.
> The final child pointer in the chain, here called 'path_dst', is some
> other kind of route such as an ipv4 or ipv6 one.
> 
> The xfrm output path pops routes, one at a time, via the child
> pointer, until we hit one which has a dst->xfrm pointer which
> is NULL.
> 
> We can easily preserve the above mechanisms with child sitting
> only in the xfrm_dst structure.  All children in the chain
> before we break out of the xfrm_output() loop have dst->xfrm
> non-NULL and are therefore xfrm_dst objects.
> 
> Since we break out of the loop when we find dst->xfrm NULL, we
> will not try to dereference 'dst' as if it were an xfrm_dst.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

This one seems to be somewhat screwed up, it does not apply.
Looks like your mail contains two patches, both have some overlap.

You have:

> ---
>  include/net/dst.h  | 12 +-----------
>  include/net/xfrm.h | 14 ++++++++++++--
>  net/core/dst.c     |  2 +-
>  net/core/pktgen.c  | 12 ++++++------
>  4 files changed, 20 insertions(+), 20 deletions(-)
> 

And:

> ---
>  include/net/dst.h         |  3 +--
>  include/net/xfrm.h        | 13 +++++++++----
>  net/core/dst.c            |  9 ++++++---
>  net/core/pktgen.c         | 12 ++++++------
>  net/netfilter/xt_policy.c |  3 ++-
>  net/xfrm/xfrm_device.c    |  2 +-
>  6 files changed, 25 insertions(+), 17 deletions(-)
> 
