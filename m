From: Thomas Egerer <hakke_007@gmx.de>
Subject: [PATCH] ipv4+ipv6: Make INET*_ESP select CRYPTO_ECHAINIV
Date: Sat, 23 Jan 2016 14:30:56 +0100
Message-ID: <56A38090.5030909@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:61418 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752582AbcAWNaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jan 2016 08:30:04 -0500
Received: from [192.168.178.113] ([87.157.62.212]) by mail.gmx.com (mrgmx003)
 with ESMTPSA (Nemesis) id 0MTkNU-1aVsDJ3n72-00QVMQ for
 <netdev@vger.kernel.org>; Sat, 23 Jan 2016 14:30:01 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ESP algorithms using CBC mode require echainiv. Hence INET*_ESP have
to select CRYPTO_ECHAINIV in order to work properly. This solves the
issues caused by a misconfiguration as described in [1].
The original approach, patching crypto/Kconfig was turned down by
Herbert Xu [2].

[1] https://lists.strongswan.org/pipermail/users/2015-December/009074.html
[2] http://marc.info/?l=linux-crypto-vger&m=145224655809562&w=2

Signed-off-by: Thomas Egerer <hakke_007@gmx.de>
---
 net/ipv4/Kconfig | 1 +
 net/ipv6/Kconfig | 1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index c229205..7758247 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -353,6 +353,7 @@ config INET_ESP
 	select CRYPTO_CBC
 	select CRYPTO_SHA1
 	select CRYPTO_DES
+	select CRYPTO_ECHAINIV
 	---help---
 	  Support for IPsec ESP.
 
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index bb7dabe..40c8975 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -69,6 +69,7 @@ config INET6_ESP
 	select CRYPTO_CBC
 	select CRYPTO_SHA1
 	select CRYPTO_DES
