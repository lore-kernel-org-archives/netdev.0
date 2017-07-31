From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 net-next] net: systemport: Support 64bit statistics
Date: Mon, 31 Jul 2017 02:37:56 -0700
Message-ID: <1501493876.1876.6.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1501459275-7635-1-git-send-email-jqiaoulk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, davem@davemloft.net, netdev@vger.kernel.org
To: "Jianming.qiao" <jqiaoulk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:37392 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750923AbdGaJiA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 05:38:00 -0400
Received: by mail-wm0-f67.google.com with SMTP id t138so16004699wmt.4
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 02:37:59 -0700 (PDT)
In-Reply-To: <1501459275-7635-1-git-send-email-jqiaoulk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-07-31 at 01:01 +0100, Jianming.qiao wrote:
...

> +	for (q = 0; q < dev->num_tx_queues; q++) {
> +		ring = &priv->tx_rings[q];
> +		do {
> +			start = u64_stats_fetch_begin_irq(&stats64->syncp);
> +			tx_bytes += ring->bytes;
> +			tx_packets += ring->packets;
> +		} while (u64_stats_fetch_retry_irq(&stats64->syncp, start));
> +	}


This is broken.

If the retry loop is ever done, tx_bytes and tx_packets get wrong value.
