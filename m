From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RFC 07/10] mlx4_en: Rx flow
Date: Tue, 15 Jul 2008 14:40:05 +0100
Message-ID: <20080715134003.GV19302@solarflare.com>
References: <487B65BE.6000100@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>, tziporet@mellanox.co.il,
	Roland Dreier <rdreier@cisco.com>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.mbr-roch.zen.net.uk ([212.23.3.142]:50632 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756225AbYGONkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 09:40:18 -0400
Content-Disposition: inline
In-Reply-To: <487B65BE.6000100@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yevgeny Petrilin wrote:
[...]
> +static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
> +				   struct mlx4_en_rx_ring *ring, int index)
> +{
> +	struct mlx4_en_rx_desc *rx_desc = ring->buf + (index * ring->stride);
> +	struct skb_frag_struct *skb_frags = ring->rx_info +
> +					    (index << priv->log_rx_info);
> +	int i;
> +
> +	PREFETCH((void *) rx_desc + L1_CACHE_BYTES);
> +	PREFETCH((void *) skb_frags + L1_CACHE_BYTES);
[...]

You should use the standard prefetch() macro, not your own.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
