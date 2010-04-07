From: Scott Wood <scottwood@freescale.com>
Subject: Re: [RFC PATCH net-next 2/4] gianfar: Added timer feature for eTSEC
Date: Wed, 7 Apr 2010 11:21:09 -0500
Message-ID: <20100407162109.GA9220@loki.buserror.net>
References: <95DC1AA8EC908B48939B72CF375AA5E311A9F4E0@alice.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'sandeep.kumar@freescale.com'" <sandeep.kumar@freescale.com>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linuxppc-dev@lists.ozlabs.org'" <linuxppc-dev@lists.ozlabs.org>
To: Manfred Rudigier <Manfred.Rudigier@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:65199 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932614Ab0DGQV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 12:21:26 -0400
Content-Disposition: inline
In-Reply-To: <95DC1AA8EC908B48939B72CF375AA5E311A9F4E0@alice.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 07, 2010 at 11:46:24AM +0200, Manfred Rudigier wrote:
>  	switch (config.tx_type) {
>  	case HWTSTAMP_TX_OFF:
> +		priv->hwts_tx_en = 0;
>  		break;
>  	case HWTSTAMP_TX_ON:
> +		if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER))
> +			return -ERANGE;
> +		priv->hwts_tx_en = 1;
>  		return -ERANGE;
>  	default:
>  		return -ERANGE;
> @@ -796,8 +802,12 @@ static int gfar_hwtstamp_ioctl(struct net_device *netdev,
>  
>  	switch (config.rx_filter) {
>  	case HWTSTAMP_FILTER_NONE:
> +		priv->hwts_rx_en = 0;
>  		break;
>  	default:
> +		if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER))
> +			return -ERANGE;
> +		priv->hwts_rx_en = 1;
>  		return -ERANGE;
>  	}

You need to acquire bflock (or avoid using bitfields for this), or you could
race with the setting of wol_en or rx_csum_enable.

-Scott
