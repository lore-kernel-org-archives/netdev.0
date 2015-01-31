From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 7/9] netfilter: nft_hash: add support for timeouts
Date: Sat, 31 Jan 2015 15:29:20 +1100
Message-ID: <20150131042920.GA27480@gondor.apana.org.au>
References: <1422603994-5836-1-git-send-email-kaber@trash.net>
 <1422603994-5836-8-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, davem@davemloft.net, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:45135 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430AbbAaE34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 23:29:56 -0500
Content-Disposition: inline
In-Reply-To: <1422603994-5836-8-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2015 at 07:46:32AM +0000, Patrick McHardy wrote:
>
> +	mutex_lock(&priv->ht.mutex);
> +	tbl = rht_dereference(priv->ht.tbl, &priv->ht);
> +	for (i = 0; i < tbl->size; i++) {
> +		rht_for_each_entry_safe(he, pos, next, tbl, i, node) {
> +			if (!nft_set_ext_exists(&he->ext, NFT_SET_EXT_TIMEOUT))
> +				continue;
> +			timeout = *nft_set_ext_timeout(&he->ext);
> +			if (time_before(jiffies, timeout))
> +				continue;
> +
> +			rhashtable_remove(&priv->ht, &he->node);
> +			nft_hash_elem_destroy(set, he);
> +		}
> +	}
> +	mutex_unlock(&priv->ht.mutex);

What if somebody is currently walking over the table? Shouldn't
you do an RCU free here instead of immediately destroying the
element?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
