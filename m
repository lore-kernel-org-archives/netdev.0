From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2.6.18] WE-21 for bcm43xx (wireless-2.6 git)
Date: Wed, 30 Aug 2006 14:51:05 +0200
Message-ID: <200608301451.05697.mb@bu3sch.de>
References: <20060830011211.GO8405@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:47289
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750918AbWH3Mvz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 08:51:55 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060830011211.GO8405@bougret.hpl.hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 30 August 2006 03:12, Jean Tourrilhes wrote:
>         Hi,
> 
>         WE-21 for Broadcom driver and SoftMAC...
> 	This version is for wireless-2.6 git.
> 
>         Jean
> 
> Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Next time CC Larry Finger <Larry.Finger@lwfinger.net>,
as he is the bcm43xx-softmac maintainer, please.

> -----------------------------------------------------------
> 
> diff -u -p linux/net/ieee80211/softmac/ieee80211softmac_wx.20.c linux/net/ieee80211/softmac/ieee80211softmac_wx.c
> --- linux/net/ieee80211/softmac/ieee80211softmac_wx.20.c	2006-08-29 14:45:56.000000000 -0700
> +++ linux/net/ieee80211/softmac/ieee80211softmac_wx.c	2006-08-29 14:46:24.000000000 -0700
> @@ -80,10 +80,10 @@ ieee80211softmac_wx_set_essid(struct net
>  	 * If it's our network, ignore the change, we're already doing it!
>  	 */
>  	if((sm->associnfo.associating || sm->associated) &&
> -	   (data->essid.flags && data->essid.length && extra)) {
> +	   (data->essid.flags && data->essid.length)) {
>  		/* Get the associating network */
>  		n = ieee80211softmac_get_network_by_bssid(sm, sm->associnfo.bssid);
> -		if(n && n->essid.len == (data->essid.length - 1) &&
> +		if(n && (n->essid.len == data->essid.length) &&
>  		   !memcmp(n->essid.data, extra, n->essid.len)) {
>  			dprintk(KERN_INFO PFX "Already associating or associated to "MAC_FMT"\n",
>  				MAC_ARG(sm->associnfo.bssid));
> @@ -109,8 +109,8 @@ ieee80211softmac_wx_set_essid(struct net
>  	sm->associnfo.static_essid = 0;
>  	sm->associnfo.assoc_wait = 0;
>  
> -	if (data->essid.flags && data->essid.length && extra /*required?*/) {
> -		length = min(data->essid.length - 1, IW_ESSID_MAX_SIZE);
> +	if (data->essid.flags && data->essid.length) {
> +		length = min((int) data->essid.length, IW_ESSID_MAX_SIZE);
>  		if (length) {
>  			memcpy(sm->associnfo.req_essid.data, extra, length);
>  			sm->associnfo.static_essid = 1;
> diff -u -p linux/drivers/net/wireless/bcm43xx/bcm43xx_wx.20.c linux/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
> --- linux/drivers/net/wireless/bcm43xx/bcm43xx_wx.20.c	2006-08-29 14:46:08.000000000 -0700
> +++ linux/drivers/net/wireless/bcm43xx/bcm43xx_wx.c	2006-08-29 14:47:47.000000000 -0700
> @@ -334,7 +334,7 @@ static int bcm43xx_wx_get_nick(struct ne
>  	size_t len;
>  
>  	mutex_lock(&bcm->mutex);
> -	len = strlen(bcm->nick) + 1;
> +	len = strlen(bcm->nick);
>  	memcpy(extra, bcm->nick, len);
>  	data->data.length = (__u16)len;
>  	data->data.flags = 1;
> 

-- 
Greetings Michael.
