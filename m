From: Xiang Gao <qasdfgtyuiop@gmail.com>
Subject: Re: [PATCH] mac80211: aead api to reduce redundancy
Date: Sun, 24 Sep 2017 14:39:53 -0400
Message-ID: <CAMtaSwRy8Ae2VZoXqWN0bV4tX_j_Wv_ZMY+9tizPCcwEue4vcA@mail.gmail.com>
References: <20170924054015.8958-1-qasdfgtyuiop@gmail.com> <1506265531.2909.5.camel@sipsolutions.net>
 <CAMtaSwR4YTgh9N9x8a12R4dEZNuarjwvfOmnO6vnaDffVV-j3w@mail.gmail.com> <1506274966.2909.7.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        linux-crypto@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1506274966.2909.7.camel@sipsolutions.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2017-09-24 13:42 GMT-04:00 Johannes Berg <johannes@sipsolutions.net>:
> On Sun, 2017-09-24 at 13:21 -0400, Xiang Gao wrote:
>>
>> Do you mean to put more characters each line in the description
>>
> Huh, sorry, no - my bad. I was thinking of the code, not the
> description at all.

Oh yes, these indentation do looks ugly. Thank you for figuring this
out. The tab
width of my editor was set to 4. It should be 8... I will fix these
problems and resend
the patch soon, maybe after receiving a bit more feedback.

>
> For example here:
>
>> -int ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
>> -                             u8 *data, size_t data_len, u8 *mic)
>> +int aead_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad, size_t aad_len,
>> +                                u8 *data, size_t data_len, u8 *auth)
>>
>
> I think you should adjust the indentation to match - or did it just get
> mangled in my mail? It looks *further* indented now, when it should be
> less (to after the opening parenthesis). Similarly in various other
> places.
>
> And perhaps for long things like
>
>> +static inline struct crypto_aead *ieee80211_aes_key_setup_encrypt(
>> +                               const u8 key[], size_t key_len,
>> size_t mic_len)
>
>> +struct crypto_aead *aead_key_setup_encrypt(const char *alg,
>> +                       const u8 key[], size_t key_len, size_t authsize);
>
> it might be better to write
>
> static inline struct crypto_aead *
> ieee80211_aes_key_setup_encrypt(const u8 key[], ...)
>
> and
>
> struct crypto_aead *
> aead_key_setup_encrypt(const char *alg, ...)
>
>
> respectively, depending on how far you have to indent to break lines
> etc.
>
> Anyway, I'm nitpicking.
>
> Unrelated to this, I'm not sure whose tree this should go through -
> probably Herbert's (or DaveM's with his ACK? not sure if there's a
> crypto tree?) or so?

Yes, there is one at
https://git.kernel.org/pub/scm/linux/kernel/git/herbert/cryptodev-2.6.git/
I'm not sure which tree to go either. I'm also not sure about the
beginning of the patch title,
should it be "mac80211:" or "crypto:"?

Options are:
1. This whole patch goes to either mac80211 tree or crypto tree. I
don't know which is better.
2. Make the higher level api only for internal usage in mac80211, i.e.
move the aead_api.c and aead_api.h to net/mac80211, does not export
the symbol. And of course, this will go to the mac80211 tree. I
personally don't want this to be the final solution because I happen
to be writing a loadable kernel module that uses these higher level
api.
3. Maybe split this patch, one for changes in crypto, which will go to
crypto tree, and the other for mac80211 part, which goes to the
mac80211 tree?

>
> johannes
