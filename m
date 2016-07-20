From: David Miller <davem@davemloft.net>
Subject: Re: [Patch-V2 2/3] chcr: Support for Chelsio's Crypto Hardware
Date: Tue, 19 Jul 2016 21:15:22 -0700 (PDT)
Message-ID: <20160719.211522.465417746785662817.davem@davemloft.net>
References: <1468906935-6770-1-git-send-email-yeshaswi@chelsio.com>
	<1468906935-6770-3-git-send-email-yeshaswi@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
	jlulla@chelsio.ccom, harsh@chelsio.com, atul.gupta@chelsio.com,
	herbert@gondor.apana.org.au
To: yeshaswi@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468906935-6770-3-git-send-email-yeshaswi@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yeshaswi M R Gowda <yeshaswi@chelsio.com>
Date: Mon, 18 Jul 2016 22:42:14 -0700

> +config CRYPTO_DEV_CHELSIO
> +	tristate "Chelsio Crypto Co-processor Driver"
> +	depends on PCI && NETDEVICES && ETHERNET
> +	select CRYPTO_SHA1
> +	select CRYPTO_SHA256
> +	select CRYPTO_SHA512
> +	select NET_VENDOR_CHELSIO
> +	select CHELSIO_T4

The user shouldn't have to know about the technical details about
how this chip is physically implemented.

It's therefore not reasonable to require an ethernet driver to be
enabled to use the crypto engine.

Also, selecting Kconfig symbol X does not recursively enable the
"select" statement(s) of symbol X nor does it check symbol X's
dependencies.

This is really one big huge dependency mess, and I think you have
to split out the core of the T4 driver into a driver subtype
agnostic library or similar to make this work properly.

Don't just shoehorn this stuff into the ethernet driver.  Round
peg, square hole.
