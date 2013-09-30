From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/7] net: introduce new macro
 net_get_random_once
Date: Mon, 30 Sep 2013 15:43:26 -0400 (EDT)
Message-ID: <20130930.154326.1864735743256219379.davem@davemloft.net>
References: <1380236199-3726-1-git-send-email-hannes@stressinduktion.org>
	<1380236199-3726-4-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755755Ab3I3Tn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 15:43:28 -0400
In-Reply-To: <1380236199-3726-4-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 27 Sep 2013 00:56:35 +0200

> +/* BE CAREFUL: this function is not interrupt safe */
> +#define net_get_random_once(buf, nbytes)				\
> +	({								\
> +		static bool ___done = false;				\
> +		bool ___ret = false;					\
> +		if (unlikely(!___done))					\
> +			___ret = __net_get_random_once(buf,		\
> +						       nbytes,		\
> +						       &___done);	\
> +		___ret;							\
> +	})

I don't want to see this happening in every fast path, it's silly to test
this every time after the first iteration.

Maybe... _maybe_ I can be convinced if you use a static branch for this so
that it _really_ costs next to nothing.

But as-is I am not going to apply this series, sorry.
