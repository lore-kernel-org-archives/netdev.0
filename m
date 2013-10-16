From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH ipsec] xfrm: prevent ipcomp scratch buffer race condition
Date: Wed, 16 Oct 2013 20:32:05 +0800
Message-ID: <20131016123205.GA9982@gondor.apana.org.au>
References: <20131014160334.BCCDDE8A31@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:34136 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934103Ab3JPMcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 08:32:24 -0400
Content-Disposition: inline
In-Reply-To: <20131014160334.BCCDDE8A31@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 14, 2013 at 06:03:34PM +0200, Michal Kubecek wrote:
> In ipcomp_compress(), sortirq is enabled too early, allowing the
> per-cpu scratch buffer to be rewritten by ipcomp_decompress()
> (called on the same CPU in softirq context) between populating
> the buffer and copying the compressed data to the skb.

Good catch.

> Add similar protection into ipcomp_decompress() as it can be
> called from process context as well (even if such scenario seems
> a bit artificial).

I don't think this is possible or otherwise xfrm_input will
dead-lock.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
