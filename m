From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH ipsec v3] xfrm: prevent ipcomp scratch buffer race
 condition
Date: Thu, 17 Oct 2013 21:39:59 +0800
Message-ID: <20131017133958.GA22197@gondor.apana.org.au>
References: <20131017095502.GD7660@secunet.com>
 <20131017130740.D8741E8A5E@unicorn.suse.cz>
 <1382017117.2045.146.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Kubecek <mkubecek@suse.cz>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:40968 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754579Ab3JQNkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 09:40:09 -0400
Content-Disposition: inline
In-Reply-To: <1382017117.2045.146.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 17, 2013 at 06:38:37AM -0700, Eric Dumazet wrote:
> On Thu, 2013-10-17 at 15:07 +0200, Michal Kubecek wrote:
> > In ipcomp_compress(), sortirq is enabled too early, allowing the
> > per-cpu scratch buffer to be rewritten by ipcomp_decompress()
> > (called on the same CPU in softirq context) between populating
> > the buffer and copying the compressed data to the skb.
> > 
> > v2: as pointed out by Steffen Klassert, if we also move the
> > local_bh_disable() before reading the per-cpu pointers, we can
> > get rid of get_cpu()/put_cpu().
> > 
> > v3: removed ipcomp_decompress part (as explained by Herbert Xu,
> > it cannot be called from process context), get rid of cpu
> > variable (thanks to Eric Dumazet)
> > 
> > Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> > ---
> 
> Reviewed-by: Eric Dumazet <edumazet@google.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
