From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: Using the aesni generic gcm(aes) aead in atomic context
Date: Mon, 30 Oct 2017 15:18:21 +0000
Message-ID: <AM4PR0501MB2723742986C5098642C50D01D4590@AM4PR0501MB2723.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Boris Pismenny <borisp@mellanox.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "sd@queasysnail.net" <sd@queasysnail.net>,
        "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0074.outbound.protection.outlook.com ([104.47.0.74]:63759
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752064AbdJ3PSY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 11:18:24 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I've tried using the aesni generic gcm(aes) aead to implement TLS SW fallba=
ck and
I'm getting=20
[ 3356.839506] BUG: sleeping function called from invalid context at ./incl=
ude/crypto/algapi.h:417

The warning is coming from a ___might_sleep() macro that is called if CRYPT=
O_TFM_REQ_MAY_SLEEP is set.
I'm getting the warning regardless of if pass CRYPTO_ALG_ASYNC or 0 as flag=
s to crypto_alloc_aead("gcm(aes)", 0, flags).

I've also noticed that rfc4106_encrypt() includes a irq_fpu_usable() check =
while generic_gcmaes_encrypt() doesn't.=20
Is the generic gcm(aes) aead unsafe in atomic context?
And if so which aead should I use?

Finally, out of curiosity, doesn't macsec crypto run in atomic context?

Thanks,
Ilya
