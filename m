From: Patrick McHardy <kaber@trash.net>
Subject: Re: [v1 PATCH 2/7] rhashtable: Allow hash/comparison functions to be
 inlined
Date: Fri, 20 Mar 2015 11:20:42 +0000
Message-ID: <20150320112041.GF28736@acer.localdomain>
References: <20150320105421.GA18148@gondor.apana.org.au>
 <E1YYubs-0004l5-Dt@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35754 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbbCTLUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 07:20:47 -0400
Content-Disposition: inline
In-Reply-To: <E1YYubs-0004l5-Dt@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.03, Herbert Xu wrote:
> This patch deals with the complaint that we make indirect function
> calls on the fast paths unnecessarily in rhashtable.  We resolve
> it by moving the fast paths into inline functions that take struct
> rhashtable_param (which obviously must be the same set of parameters
> supplied to rhashtable_init) as an argument.

I haven't checked in detail yet whether this still satisfies what
we need in nftables, just a minor comment below:

> +struct rhashtable_compare_arg {
> +	struct rhashtable *ht;
> +	const void *key;
> +};

I found it a bit odd in the old interface that elementary data
such as the key for comparision is encapsulated into a structure
instead of passed as a function argument. Is there a reason
for not passing both as arguments so we can at least avoid the
encapsulation for the common case?
