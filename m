From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2 PATCH 06/11] xfrm: Move child route linkage into
 xfrm_dst.
Date: Tue, 31 Oct 2017 11:42:13 -0700
Message-ID: <1509475333.3828.33.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171031141054.9954-1-davem@davemloft.net>
         <20171031141054.9954-7-davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:53881 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932423AbdJaSmP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:42:15 -0400
Received: by mail-pg0-f68.google.com with SMTP id s2so15393299pge.10
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:42:15 -0700 (PDT)
In-Reply-To: <20171031141054.9954-7-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-31 at 23:10 +0900, David S. Miller wrote:
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
> ---


Reviewed-by: Eric Dumazet <edumazet@google.com>
