From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Add skb_unclone() helper function.
Date: Thu, 24 Jan 2013 17:13:20 -0800
Message-ID: <1359076400.12374.2813.camel@edumazet-glaptop>
References: <1359065787-1763-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:42394 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753775Ab3AYBNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 20:13:23 -0500
Received: by mail-pb0-f49.google.com with SMTP id xa12so53589pbc.8
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 17:13:23 -0800 (PST)
In-Reply-To: <1359065787-1763-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-24 at 14:16 -0800, Pravin B Shelar wrote:
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>


>  
>  /**
> + *	skb_unclone - creates separate copy if skb is cloned.
> + */

A proper kernel doc comment is not really needed, or must be complete
 * @skb: ...
 * @pri: ...

> +static inline bool skb_unclone(struct sk_buff *skb, gfp_t pri)
> +{
> +	might_sleep_if(pri & __GFP_WAIT);
> +
> +	if (skb_cloned(skb))
> +		return pskb_expand_head(skb, 0, 0, pri);
> +
> +	return 0;

	return false;

> +}
> +
