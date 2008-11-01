From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] Fix ESP SA loading (by default)
Date: Sat, 1 Nov 2008 07:37:37 +0300
Message-ID: <20081101043737.GA1621@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:6694 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbYKAEeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2008 00:34:24 -0400
Received: by ey-out-2122.google.com with SMTP id 6so583830eyi.37
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2008 21:34:22 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

digest_null algorithm is now mandatory for ESP.

Steps to reproduce:

	kernel with CONFIG_CRYPTO_NULL=n

	#!/usr/sbin/setkey -f
	flush;
	spdflush;
	add 192.168.0.1 192.168.0.42 esp 15701 -E 3des-cbc "123456789012123456789012";

This will successfully create ESP SA.

Now, apply commit 38320c70d282be1997a5204c7c7fe14c3aa6bfaa aka
"[IPSEC]: Use crypto_aead and authenc in ESP" and ESP SAs won't be created.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 Ewwww, such a cool bug turned out to be configuration issue!

 And I was thinking why on earth why Debian 2.6.26 based kernel is OK,
 but 2.6.25-rc1 (!) fails. Ditto for minimalistic config for testing with KVM.
 Not mentioning Debian's gcc creating references to __ucmdhowitiscalled up
 and including to 2.6.18 and screwing bisection hard way.

 Now that I passed first IPsec tutorial, allow me to start netns XFRM work :^)

 net/ipv4/Kconfig |    1 +
 net/ipv6/Kconfig |    1 +
 2 files changed, 2 insertions(+)

--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -346,6 +346,7 @@ config INET_ESP
 	select CRYPTO_AUTHENC
 	select CRYPTO_HMAC
 	select CRYPTO_MD5
+	select CRYPTO_NULL
 	select CRYPTO_CBC
 	select CRYPTO_SHA1
 	select CRYPTO_DES
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -86,6 +86,7 @@ config INET6_ESP
 	select CRYPTO_AUTHENC
 	select CRYPTO_HMAC
 	select CRYPTO_MD5
+	select CRYPTO_NULL
 	select CRYPTO_CBC
 	select CRYPTO_SHA1
 	select CRYPTO_DES
