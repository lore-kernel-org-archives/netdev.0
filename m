From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] ipv6: Don't depend on per socket memory for neighbour discovery messages
Date: Tue, 3 Sep 2013 13:56:36 +0200
Message-ID: <20130903115635.GA21729@order.stressinduktion.org>
References: <e4600dac657e1160da7a5e7758dcb973b616a10e.1378207925.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Fabio Estevam <festevam@gmail.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34369 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932710Ab3ICL4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 07:56:37 -0400
Content-Disposition: inline
In-Reply-To: <e4600dac657e1160da7a5e7758dcb973b616a10e.1378207925.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Tue, Sep 03, 2013 at 01:37:01PM +0200, Thomas Graf wrote:
> @@ -389,6 +386,11 @@ static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
>  	skb_reserve(skb, hlen + sizeof(struct ipv6hdr));
>  	skb_reset_transport_header(skb);
>  
> +	/* Manually assign socket ownership as we avoid calling
> +	 * sock_alloc_send_pskb() to bypass wmem buffer limits
> +	 */
> +	skb_set_owner_w(skb, sk);
> +
>  	return skb;
>  }

Do you know why this is needed? From the report it seemed to me that we might
have a deadlock on idev->lock and I couldn't find the culprit.

When I tested your change on x86_64 I did not experience this.

Maybe someone with arm could try this patch with CONFIG_PROVE_LOCKING?

Thanks,

  Hannes
