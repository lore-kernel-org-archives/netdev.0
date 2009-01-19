From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac80211: cleanup kmalloc/memset -> kcalloc
Date: Sun, 18 Jan 2009 21:43:35 -0800 (PST)
Message-ID: <20090118.214335.142183946.davem@davemloft.net>
References: <496F04BC.3030703@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linville@tuxdriver.com
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50670
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751977AbZASFnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 00:43:33 -0500
In-Reply-To: <496F04BC.3030703@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Thu, 15 Jan 2009 17:41:16 +0800

> Transform calls kmalloc/memset to a single kcalloc.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Wireless, thus this goes to linux-wireless and John
Linville, CC:'d

> diff --git a/net/mac80211/ht.c b/net/mac80211/ht.c
> index 5f510a1..743d530 100644
> --- a/net/mac80211/ht.c
> +++ b/net/mac80211/ht.c
> @@ -949,7 +949,7 @@ void ieee80211_process_addba_request(struct ieee80211_local *local,
>  
>  	/* prepare reordering buffer */
>  	tid_agg_rx->reorder_buf =
> -		kmalloc(buf_size * sizeof(struct sk_buff *), GFP_ATOMIC);
> +		kcalloc(buf_size, sizeof(struct sk_buff *), GFP_ATOMIC);
>  	if (!tid_agg_rx->reorder_buf) {
>  #ifdef CONFIG_MAC80211_HT_DEBUG
>  		if (net_ratelimit())
> @@ -959,8 +959,6 @@ void ieee80211_process_addba_request(struct ieee80211_local *local,
>  		kfree(sta->ampdu_mlme.tid_rx[tid]);
>  		goto end;
>  	}
> -	memset(tid_agg_rx->reorder_buf, 0,
> -		buf_size * sizeof(struct sk_buff *));
>  
>  	if (local->ops->ampdu_action)
>  		ret = local->ops->ampdu_action(hw, IEEE80211_AMPDU_RX_START,
> -- 
> 1.6.0.3
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
