From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/7] fou: Support for foo-over-udp RX path
Date: Sat, 13 Sep 2014 13:09:31 -0400 (EDT)
Message-ID: <20140913.130931.328536126350755386.davem@davemloft.net>
References: <1410466056-30239-1-git-send-email-therbert@google.com>
	<1410466056-30239-3-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748AbaIMRJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 13:09:33 -0400
In-Reply-To: <1410466056-30239-3-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 11 Sep 2014 13:07:31 -0700

> +#if defined(CONFIG_NET_FOU) || defined(CONFIG_NET_FOU_MODULE)

"IS_ENABLED(NET_FOU)"

> +int fou_create(struct net *net, struct fou_cfg *cfg,
> +	       struct socket **sockp);
> +int fou_destroy(struct net *net, struct fou_cfg *cfg);
> +
> +#else
> +static inline int fou_create(struct net *net, struct fou_cfg *cfg,
> +			     struct socket **sockp)
> +{
> +	return 0;
> +}
> +
> +static inline int fou_destroy(struct net *net, struct fou_cfg *cfg)
> +{
> +	return 0;
> +}
> +
> +#endif

I see no uses of fou_{create,destroy}() outside of net/ipv4/fou.c which
is only built when NET_FOU is enabled.

Yet you have NOP helpers (which probably should be returning an error
instead of 0) and export the symbol, both of which seem unnecessary.
