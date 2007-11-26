From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix memory leak in inet_hashtables.h when NUMA is on
Date: Mon, 26 Nov 2007 20:36:09 +0800
Message-ID: <20071126123609.GA27228@gondor.apana.org.au>
References: <4746FC17.9010300@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3028 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752441AbXKZMgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 07:36:11 -0500
Content-Disposition: inline
In-Reply-To: <4746FC17.9010300@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 07:13:11PM +0300, Pavel Emelyanov wrote:
> The inet_ehash_locks_alloc() looks like this:
> 
> #ifdef CONFIG_NUMA
> 	if (size > PAGE_SIZE)
> 		x = vmalloc(...);
> 	else
> #endif
> 		x = kmalloc(...);
> 
> Unlike it, the inet_ehash_locks_alloc() looks like this:
> 
> #ifdef CONFIG_NUMA
> 	if (size > PAGE_SIZE)
> 		vfree(x);
> 	else
> #else
> 		kfree(x);
> #endif
> 
> The error is obvious - if the NUMA is on and the size
> is less than the PAGE_SIZE we leak the pointer (kfree is
> inside the #else branch).
> 
> Compiler doesn't warn us because after the kfree(x) there's
> a "x = NULL" assignment, so here's another (minor?) bug: we 
> don't set x to NULL under certain circumstances.
> 
> Boring explanation, I know... Patch explains it better.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Good catch! Applied to net-2.6.  Thanks.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
