From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] macsec: fix crypto Kconfig dependency
Date: Mon, 18 Apr 2016 13:07:23 +0200
Message-ID: <4281377.HK1TLEoJOo@wuerfel>
References: <20160418080202.GA18155@gondor.apana.org.au> <11585265.Dbvl2xi4u3@wuerfel> <20160418104336.GA19175@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, sd@queasysnail.net,
	hannes@stressinduktion.org, johannes@sipsolutions.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160418104336.GA19175@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 18 April 2016 18:43:36 Herbert Xu wrote:
> 
> It's kind of silly really now that IPv4 selects CRYPTO which
> means that you can't really avoid seeing all those options which
> most users won't care about.

I had not noticed that IPv4 does it, but that is a good point.

We have had a couple of other subsystems with the issue (e.g. MFD),
and have turned around the logic in the end so the user-visible
options are always there and the subsystem core is selected by
all drivers that need it. We could do the same for crypto as below
(untested). I only select CRYPTO from ALGAPI2 there, which may be
wrong if some parts of crypto need the core but do not need algapi,
but it illustrates what we could do.

	Arnd

diff --git a/crypto/Kconfig b/crypto/Kconfig
index 93a1fdc1feee..ed1bc0c49022 100644
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -12,14 +12,12 @@ source "crypto/async_tx/Kconfig"
 #
 # Cryptographic API Configuration
 #
-menuconfig CRYPTO
-	tristate "Cryptographic API"
+config CRYPTO
+	tristate
 	help
 	  This option provides the core Cryptographic API.
 
-if CRYPTO
-
-comment "Crypto core or helper"
+menu "Crypto core or helper"
 
 config CRYPTO_FIPS
 	bool "FIPS 200 compliance"
@@ -39,6 +37,7 @@ config CRYPTO_ALGAPI
 
 config CRYPTO_ALGAPI2
 	tristate
+	select CRYPTO
 
 config CRYPTO_AEAD
 	tristate
@@ -1633,4 +1632,4 @@ source "drivers/crypto/Kconfig"
 source crypto/asymmetric_keys/Kconfig
 source certs/Kconfig
 
-endif	# if CRYPTO
+endmenu
