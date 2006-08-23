From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 03/3] d80211:  adhoc
Date: Wed, 23 Aug 2006 17:51:53 +0200
Message-ID: <20060823175153.3ed77ff8@griffin.suse.cz>
References: <20060821074107.648561364@sipsolutions.net>
	<20060821075158.728615077@sipsolutions.net>
	<44EA501E.4010605@linux.intel.com>
	<44EA51EC.8010705@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:40338 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964994AbWHWPvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 11:51:55 -0400
To: Mohamed Abbas <mabbas@linux.intel.com>
In-Reply-To: <44EA51EC.8010705@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2006 17:38:04 -0700, Mohamed Abbas wrote:
> This a small patch allow IBSS network to recieve management frame.
> Thanks
> Mohamed
> 
> diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
> index 8caf352..1153932 100644
> --- a/net/d80211/ieee80211_sta.c
> +++ b/net/d80211/ieee80211_sta.c
> @@ -1716,7 +1710,8 @@ void ieee80211_sta_rx_mgmt(struct net_de
>  		goto fail;
>  
>  	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
> -	if (sdata->type != IEEE80211_IF_TYPE_STA) {
> +	if ((sdata->type != IEEE80211_IF_TYPE_STA) &&
> +            (sdata->type != IEEE80211_IF_TYPE_IBSS)) {
>  		printk(KERN_DEBUG "%s: ieee80211_sta_rx_mgmt: non-STA "
>  		       "interface (type=%d)\n", dev->name, sdata->type);
>  		goto fail;

The check for the interface type can be removed completely here - it is
already checked by ieee80211_rx_h_mgmt. I'll take care of that.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
