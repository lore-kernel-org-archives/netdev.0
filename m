From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [ESP]: Add select on AUTHENC
Date: Tue, 4 Mar 2008 20:17:52 +0800
Message-ID: <20080304121752.GA17343@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Kazunori Miyazawa <kazunori@miyazawa.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56623 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753559AbYCDMR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 07:17:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

This patch should make the IPv6 tests work again.

[ESP]: Add select on AUTHENC

Now the ESP uses the AEAD interface even for algorithms which are
not combined mode, we need to select CONFIG_CRYPTO_AUTHENC as
otherwise only combined mode algorithms will work.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 19880b0..9c7e5ff 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -343,7 +343,7 @@ config INET_ESP
 	tristate "IP: ESP transformation"
 	select XFRM
 	select CRYPTO
-	select CRYPTO_AEAD
+	select CRYPTO_AUTHENC
 	select CRYPTO_HMAC
 	select CRYPTO_MD5
 	select CRYPTO_CBC
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 3ffb032..58219df 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -85,7 +85,7 @@ config INET6_ESP
 	depends on IPV6
 	select XFRM
 	select CRYPTO
-	select CRYPTO_AEAD
+	select CRYPTO_AUTHENC
 	select CRYPTO_HMAC
 	select CRYPTO_MD5
 	select CRYPTO_CBC
