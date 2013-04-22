From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] net: avoid inet dependency on aes crypto
Date: Mon, 22 Apr 2013 15:30:03 +0200
Message-ID: <1366637403-11212-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34522 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752846Ab3DVN2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 09:28:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 798b2cbf9227b1bd7d37ae9af4d9c750e6f4de9c
(net: Add INET dependency on aes crypto for the sake of TCP fastopen.)
results in aes-asm module no longer being loaded when AES cipher is
requested, due to CRYPTO_AES=y.

However, there is no link-time dependency on aes. Drop dep and instead
set "default m" for aes crypto if inet is enabled.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 crypto/Kconfig |    1 +
 net/Kconfig    |    1 -
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/crypto/Kconfig b/crypto/Kconfig
index 05c0ce5..151b3e0 100644
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -584,6 +584,7 @@ comment "Ciphers"
 
 config CRYPTO_AES
 	tristate "AES cipher algorithms"
+	default m if INET
 	select CRYPTO_ALGAPI
 	help
 	  AES cipher algorithms (FIPS-197). AES uses the Rijndael
diff --git a/net/Kconfig b/net/Kconfig
index 1a22216..a1d2cab 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -62,7 +62,6 @@ source "net/iucv/Kconfig"
 config INET
 	bool "TCP/IP networking"
 	select CRYPTO
-	select CRYPTO_AES
 	---help---
 	  These are the protocols used on the Internet and on most local
 	  Ethernets. It is highly recommended to say Y here (this will enlarge
-- 
1.7.8.6
