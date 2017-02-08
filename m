From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3 1/2] mac80211: fils_aead: Use crypto api CMAC shash
 rather than bare cipher
Date: Wed, 08 Feb 2017 08:46:48 +0100
Message-ID: <1486540008.4603.3.camel@sipsolutions.net>
References: <1486378168-31028-1-git-send-email-ard.biesheuvel@linaro.org>
         <1486378168-31028-2-git-send-email-ard.biesheuvel@linaro.org>
         <1486537227.4603.2.camel@sipsolutions.net>
         <CAKv+Gu9Be-bA-Trn5cMwVvf4+yMm8w2Krm59WGAhdM3bxBSJfw@mail.gmail.com>
         (sfid-20170208_084553_216930_7D2DAE1D)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        Jouni Malinen <jouni@qca.qualcomm.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:40450 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753604AbdBHHra (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 02:47:30 -0500
In-Reply-To: <CAKv+Gu9Be-bA-Trn5cMwVvf4+yMm8w2Krm59WGAhdM3bxBSJfw@mail.gmail.com> (sfid-20170208_084553_216930_7D2DAE1D)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-08 at 07:45 +0000, Ard Biesheuvel wrote:
> On 8 February 2017 at 07:00, Johannes Berg <johannes@sipsolutions.net
> > wrote:
> > This looks strange to me:
> > 
> > > +static int aes_s2v(struct crypto_shash *tfm,
> > >                  size_t num_elem, const u8 *addr[], size_t len[],
> > > u8 *v)
> > >  {
> > > -     u8 d[AES_BLOCK_SIZE], tmp[AES_BLOCK_SIZE];
> > > +     u8 d[AES_BLOCK_SIZE], tmp[AES_BLOCK_SIZE] = {};
> > > +     SHASH_DESC_ON_STACK(desc, tfm);
> > 
> > desc declared
> > 
> > > 
> > > +     crypto_shash_digest(desc, tmp, AES_BLOCK_SIZE, d);
> > 
> > used here
> > 
> 
> Each digest() call combines a init()/update()/final() sequence
> 
> > > +     crypto_shash_init(desc);
> > 
> > but initialized now?
> > 
> 
> ... for the 6th time, or so. The final vector may require two
> update()s, so we cannot use digest() here. But we can use finup() for
> the last one, which combines update() and final().
> 
> Hence,
> 
> init()/finup()
> 
> or
> 
> init()/update()/finup()
> 
> depending on the length of the last vector.

Great, thanks for the explanation :)

johannes
