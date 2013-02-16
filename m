From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/4] tunneling: Add generic UDP-Tunnel TSO.
Date: Fri, 15 Feb 2013 17:34:40 -0800
Message-ID: <1360978480.19353.36.camel@edumazet-glaptop>
References: <1360976774-1891-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com,
	stephen@networkplumber.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:58854 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074Ab3BPBes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 20:34:48 -0500
Received: by mail-pb0-f54.google.com with SMTP id rr4so825872pbb.13
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 17:34:48 -0800 (PST)
In-Reply-To: <1360976774-1891-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-15 at 17:06 -0800, Pravin B Shelar wrote:

> +	/* segment inner packet. */
> +	segs = skb_mac_gso_segment(skb, skb->dev->hw_enc_features);
> +	if (!segs || IS_ERR(segs))
> +		goto out;
> +

It seems that hw_enc_features is 0 for all devices.

We should at least inherit NETIF_F_SG

(and presumably netdev_fix_features() should not remove NETIF_F_SG if
CSUM is not supported, as we now copy the data _if_ needed in
skb_checksum_help())
