From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Mon, 10 Feb 2014 20:50:49 +0800
Message-ID: <20140210125049.GB28752@gondor.apana.org.au>
References: <1390810971-23959-1-git-send-email-fw@strlen.de>
 <1390810971-23959-2-git-send-email-fw@strlen.de>
 <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140128085706.GB30123@breakpoint.cc>
 <1390926883.28432.12.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140209025504.GB17395@gondor.apana.org.au>
 <20140210122331.GA25153@breakpoint.cc>
 <20140210123124.GA28752@gondor.apana.org.au>
 <20140210124346.GA6329@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:34508 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740AbaBJMuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 07:50:52 -0500
Content-Disposition: inline
In-Reply-To: <20140210124346.GA6329@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 10, 2014 at 01:43:46PM +0100, Florian Westphal wrote:
>
> Eric suggested to shrink gso_size instead to avoid segmentation+fragments.
> I think its nice idea, but skb_gso_segment makes certain assumptions about
> nr_frags and gso_size (it can't handle frag size > desired mss).

This breaks the most important assumption behind GRO which is
to preserve end-to-end connectivity.  Resegmenting packets as
suggested on a router/bridge is just wrong.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
