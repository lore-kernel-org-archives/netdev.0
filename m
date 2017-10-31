From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: RE: Using the aesni generic gcm(aes) aead in atomic context
Date: Tue, 31 Oct 2017 09:41:24 +0000
Message-ID: <AM4PR0501MB2723C14143D6FE272BDA58E5D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
References: <AM4PR0501MB2723742986C5098642C50D01D4590@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031041015.GB24806@gondor.apana.org.au>
 <AM4PR0501MB27232A20751B0443EBA7B446D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031071729.GA25871@gondor.apana.org.au>
 <AM4PR0501MB27231A649C20C10E024C83DBD45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031073239.GA25958@gondor.apana.org.au>
 <AM4PR0501MB2723C23EAC7467B09587C2C9D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031074438.GA26042@gondor.apana.org.au>
 <20171031091345.GF30509@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "sd@queasysnail.net" <sd@queasysnail.net>,
        Boris Pismenny <borisp@mellanox.com>,
        "davejwatson@fb.com" <davejwatson@fb.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr30063.outbound.protection.outlook.com ([40.107.3.63]:15168
        "EHLO EUR03-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751378AbdJaJl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 05:41:27 -0400
In-Reply-To: <20171031091345.GF30509@secunet.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, October 31, 2017 11:14 AM Steffen Klassert wrote:

> I think Ilya talks about the case where the TLS crypto is intended to be =
offloaded
> to a NIC. In this case we need a software crypto fallback e.g. if a packe=
t got
> rerouted to a device that does not support crypto offloading.=20
You are correct.
>=20
> Allowing for async crypto would require some way to handle async returnes=
 or
> the -EBUSY case from the crypto layer inside of a qdisc. Also, in the GSO=
 case it is
> not clear how to unwind the GSO call stack on a async return.
>=20
> I had a discussion with davem at the netfilter workshop about this. Based=
 on this
> discussion, I prepared some patches that I hope to be (RFC) ready until t=
he
> netdev2.2 next week.

Are you sure supporting ASYNC crypto for fallback is worth the trouble?
This path is going to be slower that the path were you do the crypto in adv=
ance, right?

Are you concerned about the lack of synchronous crypto implementations for =
some algorithms?
