From: Beniamino Galvani <b.galvani@gmail.com>
Subject: Re: [PATCH 2/2] ethernet: arc: Add support for Rockchip SoC glue
 layer device tree bindings
Date: Fri, 8 Aug 2014 22:28:30 +0200
Message-ID: <20140808202830.GA25105@gmail.com>
References: <1407500875-23851-1-git-send-email-romain.perier@gmail.com>
 <1407500875-23851-2-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, heiko@sntech.de, max.schwarz@online.de,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Romain Perier <romain.perier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:53661 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466AbaHHUat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 16:30:49 -0400
Received: by mail-wi0-f176.google.com with SMTP id bs8so1599165wib.15
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2014 13:30:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1407500875-23851-2-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 08, 2014 at 12:27:55PM +0000, Romain Perier wrote:
> This patch defines a platform glue layer for Rockchip SoCs which support
> arc-emac driver. It ensures that regulator for the rmii is on before trying
> to connect to the ethernet controller. It applies right speed and mode changes
> to the grf when ethernet settings changes.
> 
> Signed-off-by: Romain Perier <romain.perier@gmail.com>

(...)

> +struct rockchip_priv_data {
> +	struct regmap *grf;
> +	unsigned int grf_offset;
> +	int interface;
> +	struct regulator *regulator;
> +};
> +
> +static const unsigned int rockchip_emac_soc_grf_offset[] = {
> +	0x154, /* rk3066 */
> +	0x0a4, /* rk3188 */
> +};
> +
> +static const struct of_device_id rockchip_emac_dt_ids[] = {
> +	{ .compatible = "rockchip,rk3066-emac", .data = (void *)rockchip_emac_soc_grf_offset },
> +	{ .compatible = "rockchip,rk3188-emac", .data = (void *)rockchip_emac_soc_grf_offset + 1 },

Hi Romain,

I think you need parenthesis around "rockchip_emac_soc_grf_offset + 1"
because the cast has higher precedence. Anyway, wouldn't it be simpler
to avoid the indirection and pass the offset directly in the data field?

Beniamino
