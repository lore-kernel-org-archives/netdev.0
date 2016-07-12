From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] chcr: Support for Chelsio's Crypto Hardware
Date: Tue, 12 Jul 2016 16:35:52 +0800
Message-ID: <20160712083552.GA29994@gondor.apana.org.au>
References: <1468261688-24525-1-git-send-email-yeshaswi@chelsio.com>
 <1468261688-24525-3-git-send-email-yeshaswi@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	linux-crypto@vger.kernel.org, jlulla@chelsio.com,
	atul.gupta@chelsio.com, harsh@chelsio.com
To: Yeshaswi M R Gowda <yeshaswi@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1468261688-24525-3-git-send-email-yeshaswi@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 11, 2016 at 11:28:07AM -0700, Yeshaswi M R Gowda wrote:
>
> +	u_ctx = ULD_CTX(ctx);
> +	if (cxgb4_is_crypto_q_full(u_ctx->lldi.ports[0], ctx->tx_channel_id))
> +		return -EBUSY;

You cannot just return -EBUSY.  If the request has the MAY_BACKLOG
bit set, it must be queued regardless, but you should return -EBUSY
in order to throttle the user and then call the completion function
with -EINPROGRESS once the queue can accept more requests from the
user.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
