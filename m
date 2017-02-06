From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v2 1/2] mac80211: fils_aead: Use crypto api CMAC shash
 rather than bare cipher
Date: Mon, 06 Feb 2017 09:47:52 +0100
Message-ID: <1486370872.14226.6.camel@sipsolutions.net>
References: <1486308208-3252-1-git-send-email-ard.biesheuvel@linaro.org>
         <1486308208-3252-2-git-send-email-ard.biesheuvel@linaro.org>
         (sfid-20170205_162529_852496_51AF58D1)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1486308208-3252-2-git-send-email-ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> (sfid-20170205_162529_852496_51AF58D1)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


>  {
>  	u8 d[AES_BLOCK_SIZE], tmp[AES_BLOCK_SIZE];
> +	struct shash_desc *desc;
> +	u8 buf[sizeof(*desc) + crypto_shash_descsize(tfm)]
> CRYPTO_MINALIGN_ATTR;
>  	size_t i;
> -	const u8 *data[2];
> -	size_t data_len[2], data_elems;
> +
> +	desc = (struct shash_desc *)buf;
> +	desc->tfm = tfm;
> 
> +	crypto_shash_digest(desc, (u8[AES_BLOCK_SIZE]){},
> AES_BLOCK_SIZE, d);

That's an interesting expression in there. Can we name it into a real
variable? :)

I'm also slightly worried about stack usage now - do we know none of
this goes into an sg list eventually?

johannes
