From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v3 1/2] mac80211: fils_aead: Use crypto api CMAC shash
 rather than bare cipher
Date: Wed, 08 Feb 2017 08:00:27 +0100
Message-ID: <1486537227.4603.2.camel@sipsolutions.net>
References: <1486378168-31028-1-git-send-email-ard.biesheuvel@linaro.org>
         <1486378168-31028-2-git-send-email-ard.biesheuvel@linaro.org>
         (sfid-20170206_114945_027134_93100C60)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org
To: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1486378168-31028-2-git-send-email-ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> (sfid-20170206_114945_027134_93100C60)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This looks strange to me:

> +static int aes_s2v(struct crypto_shash *tfm,
>  		   size_t num_elem, const u8 *addr[], size_t len[],
> u8 *v)
>  {
> -	u8 d[AES_BLOCK_SIZE], tmp[AES_BLOCK_SIZE];
> +	u8 d[AES_BLOCK_SIZE], tmp[AES_BLOCK_SIZE] = {};
> +	SHASH_DESC_ON_STACK(desc, tfm);

desc declared

> 
> +	crypto_shash_digest(desc, tmp, AES_BLOCK_SIZE, d);

used here
 
> +	crypto_shash_init(desc);

but initialized now?

johannes
