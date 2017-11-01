From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Using the aesni generic gcm(aes) aead in atomic context
Date: Wed, 1 Nov 2017 10:21:07 +0100
Message-ID: <20171101092106.GI11292@secunet.com>
References: <AM4PR0501MB2723742986C5098642C50D01D4590@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031041015.GB24806@gondor.apana.org.au>
 <AM4PR0501MB27232A20751B0443EBA7B446D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031071729.GA25871@gondor.apana.org.au>
 <AM4PR0501MB27231A649C20C10E024C83DBD45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031073239.GA25958@gondor.apana.org.au>
 <AM4PR0501MB2723C23EAC7467B09587C2C9D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031074438.GA26042@gondor.apana.org.au>
 <20171031091345.GF30509@secunet.com>
 <AM4PR0501MB2723C14143D6FE272BDA58E5D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "sd@queasysnail.net" <sd@queasysnail.net>,
        Boris Pismenny <borisp@mellanox.com>,
        "davejwatson@fb.com" <davejwatson@fb.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Ilya Lesokhin <ilyal@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:59152 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752118AbdKAJVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 05:21:09 -0400
Content-Disposition: inline
In-Reply-To: <AM4PR0501MB2723C14143D6FE272BDA58E5D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 09:41:24AM +0000, Ilya Lesokhin wrote:
> 
> Are you sure supporting ASYNC crypto for fallback is worth the trouble?

It is not just for fallback, I plan to support the IPsec GSO codepath
for software crypto too. In this case we should be able to handle all
algorithms, including the async ones.

> This path is going to be slower that the path were you do the crypto in advance, right?

If the cryptd is used, yes. At least that's what I messured for IPsec
forwarding. But I think this is because we enqueue requests much
faster that the cryptd dequeues them.
