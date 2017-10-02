From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: aead api to reduce redundancy
Date: Mon, 02 Oct 2017 14:04:58 +0200
Message-ID: <1506945898.25586.3.camel@sipsolutions.net>
References: <20170926131945.3962-1-qasdfgtyuiop@gmail.com>
         (sfid-20170926_152018_942414_806DE318)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Xiang Gao <qasdfgtyuiop@gmail.com>, davem@davemloft.net,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926131945.3962-1-qasdfgtyuiop@gmail.com> (sfid-20170926_152018_942414_806DE318)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please use "v2" tag or so in the subject line, having the same patch
again is really not helpful.

The next should be v3, obviously.

> +++ b/net/mac80211/aead_api.c
> @@ -1,7 +1,4 @@
> -/*
> - * Copyright 2014-2015, Qualcomm Atheros, Inc.
> - *
> - * This program is free software; you can redistribute it and/or
> modify
> +/* This program is free software; you can redistribute it and/or
> modify

I see no reason to make this change, why remove copyright?

> +++ b/net/mac80211/wpa.c
> @@ -464,7 +464,8 @@ static int ccmp_encrypt_skb(struct
> ieee80211_tx_data *tx, struct sk_buff *skb,
>  	pos += IEEE80211_CCMP_HDR_LEN;
>  	ccmp_special_blocks(skb, pn, b_0, aad);
>  	return ieee80211_aes_ccm_encrypt(key->u.ccmp.tfm, b_0, aad,
> pos, len,
> -					 skb_put(skb, mic_len),
> mic_len);
> +					 skb_put(skb,
> +						 key->u.ccmp.tfm-
> >authsize));
>  }

I see no reason for the change from mic_len to authsize here?

> @@ -540,10 +541,11 @@ ieee80211_crypto_ccmp_decrypt(struct
> ieee80211_rx_data *rx,
>  			ccmp_special_blocks(skb, pn, b_0, aad);
>  
>  			if (ieee80211_aes_ccm_decrypt(
> -				    key->u.ccmp.tfm, b_0, aad,
> -				    skb->data + hdrlen + IEEE80211_CCMP_HDR_LEN,
> -				    data_len,
> -				    skb->data + skb->len - mic_len, mic_len))
> +				key->u.ccmp.tfm, b_0, aad,
> +				skb->data + hdrlen + IEEE80211_CCMP_HDR_LEN,
> +				data_len,
> +				skb->data + skb->len - key->u.ccmp.tfm->authsize
> +			))
>  				return RX_DROP_UNUSABLE;

That's a really really strange way of writing this ...

Please reformat.

johannes
