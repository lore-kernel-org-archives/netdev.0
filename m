From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 2/3] gianfar: Use mpc85xx support for errata detection
Date: Wed, 9 Oct 2013 15:14:13 -0500
Message-ID: <1381349653.7979.366.camel@snotra.buserror.net>
References: <1381339242-32030-1-git-send-email-claudiu.manoil@freescale.com>
	 <1381339242-32030-2-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	<linuxppc-dev@lists.ozlabs.org>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe003.messaging.microsoft.com ([213.199.154.206]:18715
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754428Ab3JIUOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 16:14:22 -0400
In-Reply-To: <1381339242-32030-2-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-09 at 20:20 +0300, Claudiu Manoil wrote:
> +static void gfar_detect_errata(struct gfar_private *priv)
> +{
> +	struct device *dev = &priv->ofdev->dev;
> +
> +	/* no plans to fix */
> +	priv->errata |= GFAR_ERRATA_A002;
> +
> +	if (pvr_version_is(PVR_VER_E500V1) || pvr_version_is(PVR_VER_E500V2))
> +		__gfar_detect_errata_85xx(priv);
> +	else /* non-mpc85xx parts, i.e. e300 core based */
> +		__gfar_detect_errata_83xx(priv);

It would be better to use CONFIG_E500 here (note that we do not support
building e500 and 83xx/86xx in the same kernel), on the off chance that
we put a gianfar in a chip with a newer e500 derivative.  I suppose it's
harmless as long as the 83xx version checks the full PVR, until such a
chip exists and has an erratum workaround (other than A002) added for
it.

What about 86xx?  Are there any gianfar errata there besides A002?

-Scott
