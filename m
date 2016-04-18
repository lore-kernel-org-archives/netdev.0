From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] macsec: fix crypto Kconfig dependency
Date: Mon, 18 Apr 2016 18:43:36 +0800
Message-ID: <20160418104336.GA19175@gondor.apana.org.au>
References: <20160418080202.GA18155@gondor.apana.org.au>
 <11585265.Dbvl2xi4u3@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, sd@queasysnail.net,
	hannes@stressinduktion.org, johannes@sipsolutions.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <11585265.Dbvl2xi4u3@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 18, 2016 at 12:23:42PM +0200, Arnd Bergmann wrote:
> 
> No, that is not the problem.
> 
> These are the options from the randconfig file that showed the error:
> 
> # CONFIG_MODULES is not set
> # CONFIG_CRYPTO is not set
> CONFIG_CRYPTO_GCM=y
> CONFIG_CRYPTO_AES=y
> CONFIG_MACSEC=y
> # CONFIG_CFG80211 is not set
> 
> As you can see, none of them are modules, and CRYPTO is completely
> disabled.

Right, the problem is that nothing within crypto ever selects
CRYPTO since it's also used as a way of hiding the crypto menu
options.

It's kind of silly really now that IPv4 selects CRYPTO which
means that you can't really avoid seeing all those options which
most users won't care about.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
