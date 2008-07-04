From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] ipv[46]: Fix MD5 signatures for non-linear skbs
Date: Fri, 4 Jul 2008 12:24:03 +0400
Message-ID: <20080704082402.GA16259@2ka.mipt.ru>
References: <396556a20805301217k293e5718h6bbf02bfe069000@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Adam Langley <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:58248 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753048AbYGDIa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 04:30:57 -0400
Content-Disposition: inline
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069000@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Thu, Jul 03, 2008 at 05:19:41PM -0700, Adam Langley (agl@imperialviolet.org) wrote:
> +int tcp_md5_hash_key(struct tcp_md5sig_pool *hp, struct tcp_md5sig_key *key)
> +{
> +	struct scatterlist sg;
> +
> +	sg_init_table(&sg, 1);
> +	sg_set_buf(&sg, key->key, key->keylen);
> +	return crypto_hash_update(&hp->md5_desc, &sg, key->keylen);
> +}

A trivial nit: you can use sg_init_one() to initialize single
scatterlist and set data pointer instead of sg_init_table()/sg_set_buf()
in all places where you use single sg.

-- 
	Evgeniy Polyakov
