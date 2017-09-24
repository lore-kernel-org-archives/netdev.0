From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: aead api to reduce redundancy
Date: Sun, 24 Sep 2017 19:42:46 +0200
Message-ID: <1506274966.2909.7.camel@sipsolutions.net>
References: <20170924054015.8958-1-qasdfgtyuiop@gmail.com>
         <1506265531.2909.5.camel@sipsolutions.net>
         <CAMtaSwR4YTgh9N9x8a12R4dEZNuarjwvfOmnO6vnaDffVV-j3w@mail.gmail.com>
         (sfid-20170924_192213_933382_C4E7F059)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        linux-crypto@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Xiang Gao <qasdfgtyuiop@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMtaSwR4YTgh9N9x8a12R4dEZNuarjwvfOmnO6vnaDffVV-j3w@mail.gmail.com> (sfid-20170924_192213_933382_C4E7F059)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2017-09-24 at 13:21 -0400, Xiang Gao wrote:
> 
> Do you mean to put more characters each line in the description
> 
Huh, sorry, no - my bad. I was thinking of the code, not the
description at all.

For example here:

> -int ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
> -                             u8 *data, size_t data_len, u8 *mic)
> +int aead_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad, size_t aad_len,
> +                                u8 *data, size_t data_len, u8 *auth)
> 

I think you should adjust the indentation to match - or did it just get
mangled in my mail? It looks *further* indented now, when it should be
less (to after the opening parenthesis). Similarly in various other
places.

And perhaps for long things like

> +static inline struct crypto_aead *ieee80211_aes_key_setup_encrypt(
> +                               const u8 key[], size_t key_len,
> size_t mic_len)

> +struct crypto_aead *aead_key_setup_encrypt(const char *alg,
> +                       const u8 key[], size_t key_len, size_t authsize);

it might be better to write

static inline struct crypto_aead *
ieee80211_aes_key_setup_encrypt(const u8 key[], ...)

and

struct crypto_aead *
aead_key_setup_encrypt(const char *alg, ...)


respectively, depending on how far you have to indent to break lines
etc.

Anyway, I'm nitpicking.

Unrelated to this, I'm not sure whose tree this should go through -
probably Herbert's (or DaveM's with his ACK? not sure if there's a
crypto tree?) or so?

johannes
