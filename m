From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 3/4] skge: WOL support
Date: Mon, 5 Feb 2007 14:25:41 +0100
Message-ID: <200702051425.41954.netdev@axxeo.de>
References: <20070202162250.980620000@linux-foundation.org> <20070202162419.257951000@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:57027 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932411AbXBEN0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 08:26:08 -0500
In-Reply-To: <20070202162419.257951000@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

just a nitpick.

Stephen Hemminger schrieb:
> --- skge.orig/drivers/net/skge.c
> +++ skge/drivers/net/skge.c
> @@ -132,18 +132,93 @@ static void skge_get_regs(struct net_dev
>  }
>  
>  /* Wake on Lan only supported on Yukon chips with rev 1 or above */
> -static int wol_supported(const struct skge_hw *hw)
> +static u32 wol_supported(const struct skge_hw *hw)
>  {
> -	return !((hw->chip_id == CHIP_ID_GENESIS ||
> -		  (hw->chip_id == CHIP_ID_YUKON && hw->chip_rev == 0)));
> +	if (hw->chip_id == CHIP_ID_YUKON && hw->chip_rev != 0)
> +		return WAKE_MAGIC | WAKE_PHY;
> +	else
> +		return 0;
> +}

You can delete that comment, if you write exactly, what the comment says:

	if (hw->chip_id == CHIP_ID_YUKON && hw->chip_rev >= 1)
		return WAKE_MAGIC | WAKE_PHY;
	else
		return 0;

Regards

Ingo Oeser
