From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net 3/6] pch_gbe: Validate hwtstamp_config completely
 before applying it
Date: Thu, 14 Nov 2013 08:21:37 +0100
Message-ID: <20131114072011.GA4908@netboy>
References: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
 <1384389770.29151.9.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:38213 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757Ab3KNHVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 02:21:48 -0500
Received: by mail-wi0-f169.google.com with SMTP id hi5so312872wib.2
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 23:21:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1384389770.29151.9.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 14, 2013 at 12:42:50AM +0000, Ben Hutchings wrote:
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> @@ -245,16 +245,8 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
>  	/* Get ieee1588's dev information */
>  	pdev = adapter->ptp_pdev;
>  
> -	switch (cfg.tx_type) {
> -	case HWTSTAMP_TX_OFF:
> -		adapter->hwts_tx_en = 0;
> -		break;
> -	case HWTSTAMP_TX_ON:
> -		adapter->hwts_tx_en = 1;
> -		break;
> -	default:
> +	if (cfg.tx_type != HWTSTAMP_TX_OFF && cfg.tx_type != HWTSTAMP_TX_ON)
>  		return -ERANGE;
> -	}
>  
>  	switch (cfg.rx_filter) {
>  	case HWTSTAMP_FILTER_NONE:
> @@ -284,6 +276,8 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
>  		return -ERANGE;
>  	}
>  
> +	adapter->hwts_tx_en = cfg.tx_type == HWTSTAMP_TX_ON;
> +

But now there is no way to turn transmit time stamping off?

>  	/* Clear out any old time stamps. */
>  	pch_ch_event_write(pdev, TX_SNAPSHOT_LOCKED | RX_SNAPSHOT_LOCKED);

Thanks,
Richard
