From: Bob Copeland <me@bobcopeland.com>
Subject: Re: [PATCH 3/3] mac80211: mesh: fixed HT ies in beacon template
Date: Mon, 18 Jul 2016 09:38:24 -0400
Message-ID: <20160718133824.GA11996@localhost>
References: <20160713114542.24937-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Meirav Kama <meiravk@ti.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Yaniv Machani <yanivma@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35471 "EHLO
	mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbcGRNic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 09:38:32 -0400
Received: by mail-qk0-f194.google.com with SMTP id q62so12048631qkf.2
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 06:38:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160713114542.24937-1-yanivma@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2016 at 02:45:40PM +0300, Yaniv Machani wrote:
> The HT capab info field inside the HT capab IE of the mesh beacon
> is incorrect (in the case of 20MHz channel width).
> To fix this driver will check configuration from cfg and
> will build it accordingly.

> +    /* determine capability flags */
> +	cap = sband->ht_cap.cap;
> +
> +    /* if channel width is 20MHz - configure HT capab accordingly*/
> +	if (sdata->vif.bss_conf.chandef.width == NL80211_CHAN_WIDTH_20) {
> +		cap &= ~IEEE80211_HT_CAP_SUP_WIDTH_20_40;
> +		cap &= ~IEEE80211_HT_CAP_DSSSCCK40;
> +	}

Is it required that HT capability match the HT operation in this case?

> diff --git a/net/mac80211/util.c b/net/mac80211/util.c
> index 42bf0b6..5375a82 100644
> --- a/net/mac80211/util.c
> +++ b/net/mac80211/util.c
> @@ -2349,10 +2349,7 @@ u8 *ieee80211_ie_build_ht_oper(u8 *pos, struct ieee80211_sta_ht_cap *ht_cap,
>  	ht_oper->operation_mode = cpu_to_le16(prot_mode);
>  	ht_oper->stbc_param = 0x0000;
>  
> -	/* It seems that Basic MCS set and Supported MCS set
> -	   are identical for the first 10 bytes */
>  	memset(&ht_oper->basic_set, 0, 16);
> -	memcpy(&ht_oper->basic_set, &ht_cap->mcs, 10);

This change doesn't look right (basic mcs set will be all zeroes) but
then, neither does the original code.  Basic MCS set for a mesh STA should
be the mandatory MCSes according to 9.7.4.

-- 
Bob Copeland %% http://bobcopeland.com/
