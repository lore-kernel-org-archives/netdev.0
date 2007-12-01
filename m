From: Sebastian Siewior <netdev@ml.breakpoint.cc>
Subject: [PATCH] [net] RxRPC session sockets depend on crypto
Date: Sat, 1 Dec 2007 13:20:12 +0100
Message-ID: <20071201122012.GC8048@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: davem@davemloft.net, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:42937 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753527AbXLAMUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 07:20:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/built-in.o: In function `rxrpc_destroy_s':
ar-key.c:(.text+0x653cd): undefined reference to `crypto_free_tfm'
net/built-in.o: In function `rxrpc_instantiate_s':
ar-key.c:(.text+0x65496): undefined reference to `crypto_alloc_base'

Signed-off-by: Sebastian Siewior <sebastian@breakpoint.cc>
---
 net/rxrpc/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rxrpc/Kconfig b/net/rxrpc/Kconfig
index e662f1d..60c4738 100644
--- a/net/rxrpc/Kconfig
+++ b/net/rxrpc/Kconfig
@@ -6,6 +6,7 @@ config AF_RXRPC
 	tristate "RxRPC session sockets"
 	depends on INET && EXPERIMENTAL
 	select KEYS
+	select CRYPTO
 	help
 	  Say Y or M here to include support for RxRPC session sockets (just
 	  the transport part, not the presentation part: (un)marshalling is
@@ -31,7 +32,6 @@ config AF_RXRPC_DEBUG
 config RXKAD
 	tristate "RxRPC Kerberos security"
 	depends on AF_RXRPC
-	select CRYPTO
 	select CRYPTO_MANAGER
 	select CRYPTO_BLKCIPHER
 	select CRYPTO_PCBC
-- 
1.5.3.4

