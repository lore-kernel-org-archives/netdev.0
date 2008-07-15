From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RFC 07/10] mlx4_en: Rx flow
Date: Tue, 15 Jul 2008 15:27:24 +0100
Message-ID: <20080715142722.GX19302@solarflare.com>
References: <487B65BE.6000100@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>, tziporet@mellanox.co.il,
	Roland Dreier <rdreier@cisco.com>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.mbr-roch.zen.net.uk ([212.23.3.141]:57657 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754152AbYGOO1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 10:27:32 -0400
Content-Disposition: inline
In-Reply-To: <487B65BE.6000100@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yevgeny Petrilin wrote:
[...]
> +int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int budget)
> +{
[...]
> +		if (likely(priv->rx_csum)) {
> +			if ((cqe->flags_h & MLX4_EN_BIT_IPOK) &&
> +			    (cqe->chksum == 0xffff)) {
> +				/* This packet is eligible for LRO if it is:
> +				 * - DIX Ethernet (type interpretation)
> +				 * - TCP/IP (v4)
> +				 * - without IP options
> +				 * - not an IP fragment */
> +				if ((*((__be32 *) &cqe->flags_h) &
> +				     cpu_to_be32(TCPIP_MASK_32)) ==
> +				     cpu_to_be32(LRO_MASK_32)) {
[...]

So far as I can see, your netdevs will neither advertise LRO nor provide any
way to control it.  You need to implement ethtool get_flags/set_flags ops.
If you use the standard implementations then you can just test
priv->dev->features & NETIF_F_LRO here.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
