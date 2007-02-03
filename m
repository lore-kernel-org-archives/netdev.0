From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2/3] d80211-bcm43xx: Add control structure for beacontemplates
Date: Sat, 3 Feb 2007 17:47:59 +0100
Message-ID: <200702031747.59783.mb@bu3sch.de>
References: <200702031725.21428.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John Linville" <linville@tuxdriver.com>,
	Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:47550
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946501AbXBCQsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 11:48:13 -0500
In-Reply-To: <200702031725.21428.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 03 February 2007 17:25, Ivo van Doorn wrote:
> Drivers that require beacon templates will also have the
> control structure at their disposal and should always free it.
> 
> bcm43xx doesn't use the control structure, but should still free it.
> 
> Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>
> 
> ---
> 
> diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> index 9f4d51d..24be8f5 100644
> --- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> +++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> @@ -2732,8 +2732,10 @@ static int bcm43xx_config_interface(struct ieee80211_hw *hw,
>  		if (bcm43xx_is_mode(wl, IEEE80211_IF_TYPE_AP)) {
>  			assert(conf->type == IEEE80211_IF_TYPE_AP);
>  			bcm43xx_set_ssid(dev, conf->ssid, conf->ssid_len);
> -			if (conf->beacon)
> +			if (conf->beacon) {
>  				bcm43xx_refresh_templates(dev, conf->beacon);
> +				kfree(conf->beacon_control);
> +			}
>  		}
>  	}

ACK to this patch, for now.
I will take care to actually properly set the beacon tx control
parameters in hardware (the possible ones) with a later patch.

-- 
Greetings Michael.
