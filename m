From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: removing gotos considered harmful...
Date: Thu, 04 Jan 2007 11:35:29 +1100
Message-ID: <E1H2GZt-0008HG-00@gondolin.me.apana.org.au>
References: <200701030808.08182@strip-the-willow>
Cc: davem@davemloft.net, netdev@vger.kernel.org, arnaldo.melo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3669 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932213AbXADAfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 19:35:38 -0500
To: gerrit@erg.abdn.ac.uk (Gerrit Renker)
In-Reply-To: <200701030808.08182@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> 
>                        size = 0;
>                        sk_for_each(sk2, node, list)
>                                if (++size >= best_size_so_far)
>                                        goto next;
>                        best_size_so_far = size;
>                        best = result;
>                next:;
> 
>  
> |  and this got converted into:
> |  
> |                       sk_for_each(sk2, node, head)
> |                               if (++size < best_size_so_far) {
> |                                       best_size_so_far = size;
> |                                       best = result;
> |                               }
> |  
> |  Which does something very very different from the original.
> ===> Sorry, I fail to see where the two differ. They have the same postcondition
>     upon loop exit; sk2, node, size, and head are not referenced anywhere in the 
>     code that follows.

They're different because the former only updates best_size_so_far
after termination while the latter does it from the start.  It's
like moving the goal-posts while someone's trying to shoot :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
