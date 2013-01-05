From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] drivers/net/wireless/ipw2x00: use strlcpy instead of
 strncpy
Date: Sat, 05 Jan 2013 06:42:46 -0800
Message-ID: <1357396966.21156.4.camel@joe-AO722>
References: <50E82D7D.4090107@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: stas.yakovlev@gmail.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:42675 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755574Ab3AEOmq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2013 09:42:46 -0500
In-Reply-To: <50E82D7D.4090107@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-01-05 at 21:41 +0800, Chen Gang wrote:
>   The fields must be null-terminated, or IPW_DEBUG_ASSOC will cause issue.
[]
> diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
[]
> @@ -5558,7 +5558,7 @@ static int ipw_find_adhoc_network(struct ipw_priv *priv,
>  			    min(network->ssid_len, priv->essid_len)))) {
>  			char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
>  
> -			strncpy(escaped,
> +			strlcpy(escaped,
>  				print_ssid(ssid, network->ssid,
>  					   network->ssid_len),
>  				sizeof(escaped));
> @@ -5771,7 +5771,7 @@ static int ipw_best_network(struct ipw_priv *priv,
>  		     memcmp(network->ssid, priv->essid,
>  			    min(network->ssid_len, priv->essid_len)))) {
>  			char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
> -			strncpy(escaped,
> +			strlcpy(escaped,
>  				print_ssid(ssid, network->ssid,
>  					   network->ssid_len),
>  				sizeof(escaped));
> @@ -5788,7 +5788,7 @@ static int ipw_best_network(struct ipw_priv *priv,
>  	 * testing everything else. */
>  	if (match->network && match->network->stats.rssi > network->stats.rssi) {
>  		char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
> -		strncpy(escaped,
> +		strlcpy(escaped,
>  			print_ssid(ssid, network->ssid, network->ssid_len),
>  			sizeof(escaped));
>  		IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded because "

This happens because escaped is declared the wrong size.

It'd be better to change
	char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
to
	DECLARE_SSID_BUF(escaped);
and use
	print_ssid(escaped, network->ssid, network->ssid_len)
in the debug.
