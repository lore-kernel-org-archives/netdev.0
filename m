From: Chen Gang F T <chen.gang.flying.transformer@gmail.com>
Subject: Re: [PATCH] drivers/net/wireless/ipw2x00: use strlcpy instead of
 strncpy
Date: Mon, 07 Jan 2013 11:42:12 +0800
Message-ID: <50EA4414.6070407@gmail.com>
References: <50E82D7D.4090107@asianux.com>  <1357396966.21156.4.camel@joe-AO722> <50EA37CE.1090901@asianux.com> <1357528746.4940.31.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090907000102010505060005"
Cc: Chen Gang <gang.chen@asianux.com>, stas.yakovlev@gmail.com,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:48428 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413Ab3AGDlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2013 22:41:23 -0500
In-Reply-To: <1357528746.4940.31.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090907000102010505060005
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

于 2013年01月07日 11:19, Joe Perches 写道:
> On Mon, 2013-01-07 at 10:49 +0800, Chen Gang wrote:
>>   but I think the original author intended to use escaped instead of ssid
>>     DECLARE_SSID_BUF(ssid)  (line 5525, 5737)
>>     use ssid to print debug information directly
>>       (such as: line 5530..5535, 5545..5549, 5745..5749, ...)
>>     when need print additional information, use escaped
>>       (line 5559..5569, 5773..5782, 5791..5799)
>>
>>   so, I still suggest:
>>     only fix the bug (use strlcpy instead of strncpy)
>>     and not touch original features which orignal author intended using.
> 
> More likely John Linville just missed the conversions.
> 4+ years ago.
> 

  I wonder why it is not integrated into main branch.
    maybe we miss it.
      if so, I suggest to integrate it (better also add Reported-by gang.chen@asianux.com  :-) )
    maybe original author intended using short length.
      if so, I suggest to integrate my patch (using strlcpy instead of strncpy).

  for me:
    using long size instead of original short size, will change the output format.
    it seems not a good idea to change the original output format.
      (especially, the original output format has existence 4+ years).

  so, at least:
    for only fixing bug, not touching original features
      it is an executable method (is a valuable patch).
      although maybe it is not a best method (is not a very good patch).

 Regards

gchen.

> commit 9387b7caf3049168fc97a8a9111af8fe2143af18
> Author: John W. Linville <linville@tuxdriver.com>
> Date:   Tue Sep 30 20:59:05 2008 -0400
> 
>     wireless: use individual buffers for printing ssid values
>   
>     Also change escape_ssid to print_ssid to match print_mac semantics.
>     
>     Signed-off-by: John W. Linville <linville@tuxdriver.com>
> 
> Maybe these days this should be another vsprintf %p extension
> like %pM when the DECLARE_MAC_BUF/print_mac uses were converted.
> 
> (or maybe extend %ph for ssids with %*phs, length, array)
> 
> But if and until then, I suggest this instead:
> 
>  drivers/net/wireless/ipw2x00/ipw2200.c | 38 ++++++++++++++--------------------
>  1 file changed, 15 insertions(+), 23 deletions(-)
> 
> diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
> index 844f201..3dc6a92 100644
> --- a/drivers/net/wireless/ipw2x00/ipw2200.c
> +++ b/drivers/net/wireless/ipw2x00/ipw2200.c
> @@ -5556,15 +5556,12 @@ static int ipw_find_adhoc_network(struct ipw_priv *priv,
>  		    ((network->ssid_len != priv->essid_len) ||
>  		     memcmp(network->ssid, priv->essid,
>  			    min(network->ssid_len, priv->essid_len)))) {
> -			char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
> +			DECLARE_SSID_BUF(escaped);
>  
> -			strncpy(escaped,
> -				print_ssid(ssid, network->ssid,
> -					   network->ssid_len),
> -				sizeof(escaped));
> -			IPW_DEBUG_MERGE("Network '%s (%pM)' excluded "
> -					"because of ESSID mismatch: '%s'.\n",
> -					escaped, network->bssid,
> +			IPW_DEBUG_MERGE("Network '%s (%pM)' excluded because of ESSID mismatch: '%s'\n",
> +					print_ssid(escaped, network->ssid,
> +						   network->ssid_len),
> +					network->bssid,
>  					print_ssid(ssid, priv->essid,
>  						   priv->essid_len));
>  			return 0;
> @@ -5770,14 +5767,11 @@ static int ipw_best_network(struct ipw_priv *priv,
>  		    ((network->ssid_len != priv->essid_len) ||
>  		     memcmp(network->ssid, priv->essid,
>  			    min(network->ssid_len, priv->essid_len)))) {
> -			char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
> -			strncpy(escaped,
> -				print_ssid(ssid, network->ssid,
> -					   network->ssid_len),
> -				sizeof(escaped));
> -			IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded "
> -					"because of ESSID mismatch: '%s'.\n",
> -					escaped, network->bssid,
> +			DECLARE_SSID_BUF(escaped);
> +			IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded because of ESSID mismatch: '%s'\n",
> +					print_ssid(escaped, network->ssid,
> +						   network->ssid_len),
> +					network->bssid,
>  					print_ssid(ssid, priv->essid,
>  						   priv->essid_len));
>  			return 0;
> @@ -5787,13 +5781,11 @@ static int ipw_best_network(struct ipw_priv *priv,
>  	/* If the old network rate is better than this one, don't bother
>  	 * testing everything else. */
>  	if (match->network && match->network->stats.rssi > network->stats.rssi) {
> -		char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
> -		strncpy(escaped,
> -			print_ssid(ssid, network->ssid, network->ssid_len),
> -			sizeof(escaped));
> -		IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded because "
> -				"'%s (%pM)' has a stronger signal.\n",
> -				escaped, network->bssid,
> +		DECLARE_SSID_BUF(escaped);
> +		IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded because '%s (%pM)' has a stronger signal\n",
> +				print_ssid(escaped, network->ssid,
> +					   network->ssid_len),
> +				network->bssid,
>  				print_ssid(ssid, match->network->ssid,
>  					   match->network->ssid_len),
>  				match->network->bssid);
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Chen Gang

Flying Transformer

--------------090907000102010505060005
Content-Type: text/x-vcard; charset=utf-8;
 name="chen_gang_flying_transformer.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chen_gang_flying_transformer.vcf"

YmVnaW46dmNhcmQNCmZuOkNoZW4gR2FuZw0Kbjo7Q2hlbiBHYW5nDQp2ZXJzaW9uOjIuMQ0K
ZW5kOnZjYXJkDQoNCg==
--------------090907000102010505060005--
