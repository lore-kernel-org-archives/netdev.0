From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 03/13] net: ethernet: aquantia: Add ring support code
Date: Mon, 9 Jan 2017 22:34:41 -0800
Message-ID: <20170109223441.4cbca16a@xeon-e3>
References: <cover.1483999588.git.vomlehn@texas.net>
        <6dfadde2e1fe39b46d814c83fb7460566e860095.1483999588.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34012 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750772AbdAJGet (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 01:34:49 -0500
Received: by mail-pf0-f182.google.com with SMTP id 127so41871922pfg.1
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 22:34:49 -0800 (PST)
In-Reply-To: <6dfadde2e1fe39b46d814c83fb7460566e860095.1483999588.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  9 Jan 2017 14:16:01 -0800
Alexander Loktionov <Alexander.Loktionov@aquantia.com> wrote:

> 		++self->stats.rx_packets;
> +		++ndev->stats.rx_packets;
> +		ndev->stats.rx_bytes += buff->len;

Why keep two sets of statistics (self->stats and ndev->stats); seems redundant.
Could also use per-cpu network stats pcpu_sw_netstats

You could also optimize by doing only one addition of ndev->stats after processing
several packets.

> +		skb = netdev_alloc_skb(ndev, ETH_HLEN);
> +		skb_put(skb, ETH_HLEN);
> +		memcpy(skb->data, page_address(buff->page), ETH_HLEN);

Why not use build_skb() here?
