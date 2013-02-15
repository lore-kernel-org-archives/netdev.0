From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/3] net: factor out skb_mac_gso_segment() from
 skb_gso_segment()
Date: Thu, 14 Feb 2013 16:32:01 -0800
Message-ID: <1360888321.6884.65.camel@edumazet-glaptop>
References: <1360871095-2053-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com,
	bhutchings@solarflare.com, mirqus@gmail.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:40833 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759729Ab3BOAcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 19:32:04 -0500
Received: by mail-da0-f42.google.com with SMTP id z17so1271753dal.29
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 16:32:03 -0800 (PST)
In-Reply-To: <1360871095-2053-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-14 at 11:44 -0800, Pravin B Shelar wrote:
> This function will be used in next GRE_GSO patch. This patch does
> not change any functionality. It only exports skb_mac_gso_segment()
> function.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
...

> +struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
> +				  netdev_features_t features, bool tx_path)
> +{
> +

...

> +
> +	skb_reset_mac_header(skb);
> +	skb->mac_len = skb->network_header - skb->mac_header;

This could use skb_reset_mac_len() helper, but thats a minor point.

Acked-by: Eric Dumazet <edumazet@google.com>
