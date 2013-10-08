From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: port CCMP to cryptoapi's CCM driver
Date: Tue, 08 Oct 2013 21:08:36 +0200
Message-ID: <1381259316.13359.17.camel@jlt4.sipsolutions.net>
References: <1381231915-24232-1-git-send-email-ard.biesheuvel@linaro.org>
	 (sfid-20131008_133333_304168_2D31449F)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1381231915-24232-1-git-send-email-ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> (sfid-20131008_133333_304168_2D31449F)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I'm not too familiar with the aead API, so here's another question:

> +	sg_init_one(&pt, data, data_len);
> +	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
> +	sg_init_table(ct, 2);
> +	sg_set_buf(&ct[0], cdata, data_len);
> +	sg_set_buf(&ct[1], mic, IEEE80211_CCMP_MIC_LEN);

Is it guaranteed to be allowed that the input and output are the same
buffer? It seems we rely on that for encrypt_one(), but is it true here
as well?

(Btw - why pass in data/cdata as separate pointers into the function?)

> @@ -343,7 +337,7 @@ static void ccmp_special_blocks(struct sk_buff *skb, u8 *pn, u8 *scratch,
>  		data_len -= IEEE80211_CCMP_MIC_LEN;
>  
>  	/* First block, b_0 */
> -	b_0[0] = 0x59; /* flags: Adata: 1, M: 011, L: 001 */
> +	b_0[0] = 0x1; /* set L := 1, M and Adata flags are implied */

Hmm. I don't think I understand, can you explain this to me?

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
