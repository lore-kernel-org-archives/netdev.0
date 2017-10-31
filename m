From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: RE: Using the aesni generic gcm(aes) aead in atomic context
Date: Tue, 31 Oct 2017 07:14:12 +0000
Message-ID: <AM4PR0501MB27232A20751B0443EBA7B446D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
References: <AM4PR0501MB2723742986C5098642C50D01D4590@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031041015.GB24806@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "sd@queasysnail.net" <sd@queasysnail.net>,
        Boris Pismenny <borisp@mellanox.com>,
        "davejwatson@fb.com" <davejwatson@fb.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0064.outbound.protection.outlook.com ([104.47.0.64]:13155
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751798AbdJaHOP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 03:14:15 -0400
In-Reply-To: <20171031041015.GB24806@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon Tuesday, October 31, 2017 6:10 AM, Herbert Xu wrote:
>=20
> Are you allocating the tfm from atomic context? That is not allowed.
>=20
> Normally you would allocate the tfm in process context, e.g., when the
> connection is setup.
>=20

I call crypto_alloc_aead("gcm(aes)", 0, flags) in process context.
and aead_request_set_tfm(aead_req, aead) in atomic context.
I'm assuming by tfm you are referring to the struct crypto_aead allocated i=
n the first call I mentioned.

I was able to resolve the  "sleeping function called from invalid context" =
issue
By clearing the CRYPTO_TFM_REQ_MAY_SLEEP flag using=20
aead_request_set_callback with flags =3D 0.

However I'm still concerned about the lack of irq_fpu_usable() check.
and I don't really want to do the check myself outside of the crypto code a=
s it is
arch specific.
