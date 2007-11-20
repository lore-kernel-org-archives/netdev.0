From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH, take2] netfilter : struct xt_table_info diet
Date: Tue, 20 Nov 2007 15:02:43 +0800
Message-ID: <E1IuN87-0003r5-00@gondolin.me.apana.org.au>
References: <20071120063225.GA18035@verge.net.au>
Cc: dada1@cosmosbay.com, kaber@trash.net, davem@davemloft.net,
	netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
To: horms@verge.net.au (Simon Horman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3629 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759568AbXKTHDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 02:03:30 -0500
In-Reply-To: <20071120063225.GA18035@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Horman <horms@verge.net.au> wrote:
>
> @@ -269,9 +269,12 @@ struct xt_table_info
>        unsigned int underflow[NF_INET_NUMHOOKS];
> 
>        /* ipt_entry tables: one per CPU */
> -       char *entries[NR_CPUS];
> +       /* Note : this field MUST be the last one, see XT_TABLE_INFO_SZ */
> +       char *entries[1];

Just do

	char *entries[];

Not only is it ISO C99, but the compiler will die if it's not at
the end.

Actually I haven't read the rest of the patch, so scratch this
comment if you really need to have one entry there for some reason :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
