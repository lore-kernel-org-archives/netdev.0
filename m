From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] IP: do not modify ingress packet IP option in
 ip_options_echo()
Date: Mon, 24 Jul 2017 14:12:53 -0700 (PDT)
Message-ID: <20170724.141253.769254590231937263.davem@davemloft.net>
References: <f5758b6b7199d2d2a218b0ad36f1e5ef108eac43.1500642854.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
        hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43164 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932718AbdGXVMy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 17:12:54 -0400
In-Reply-To: <f5758b6b7199d2d2a218b0ad36f1e5ef108eac43.1500642854.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Fri, 21 Jul 2017 15:55:18 +0200

> diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
> index 93157f2..fdda973 100644
> --- a/net/ipv4/ip_options.c
> +++ b/net/ipv4/ip_options.c
> @@ -174,9 +174,6 @@ int __ip_options_echo(struct ip_options *dopt, struct sk_buff *skb,
>  				doffset -= 4;
>  		}
>  		if (doffset > 3) {
> -			__be32 daddr = fib_compute_spec_dst(skb);
> -
> -			memcpy(&start[doffset-1], &daddr, 4);
>  			dopt->faddr = faddr;

This transformation is required, but in the destination not the source.

The red flag is that we are indexing 'start' with 'doffset' instead of
'soffset'.
