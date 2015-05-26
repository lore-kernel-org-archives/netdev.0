From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 13/13] crypto: algif_aead - Switch to new AEAD
 interface
Date: Tue, 26 May 2015 15:36:05 +0800
Message-ID: <20150526073605.GA6530@gondor.apana.org.au>
References: <20150522082708.GA3507@gondor.apana.org.au>
 <20150525115341.GA30627@gondor.apana.org.au>
 <20150526062433.GA6025@gondor.apana.org.au>
 <1720790.K1nOQU1Nxi@tachyon.chronox.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Stephan Mueller <smueller@chronox.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1720790.K1nOQU1Nxi@tachyon.chronox.de>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 26, 2015 at 08:44:29AM +0200, Stephan Mueller wrote:
>
> Confirmed. I see no more issues on the AF_ALG side.

OK it works but there is a more serious issue.  In particular, the
user-space interface only provides spaces for the AD in the source
and not in the destination.

That means if we need to modify the AD (e.g., to rearrange headers
for IPsec) then we'd have to copy it.

So what I'd like to do is to make the recvmsg also provide space
for the AD.  That way we can always copy the AD into that space
and modify it if necessary.

In order to allow this to be done I'm going to disable the AEAD
user-space interface in 4.1 so that we have time to fix it properly
for 4.2.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
