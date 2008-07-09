From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: [RFC] mark MD5 as broken in older (stable) kernels
Date: Wed, 9 Jul 2008 09:58:51 -0700
Message-ID: <20080709095851.1f9da054@speedy>
References: <396556a20807071021n2039fc8eo6ab343355e36b468@mail.gmail.com>
	<396556a20805301217k293e5718h6bbf02bfe069001@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Adam Langley" <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:41848 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752294AbYGIQ6x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2008 12:58:53 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069001@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following should probably be sent to stable kernel tree to disable
MD5 in older kernels. It will avoid problems for all those vendor
kernels.

--- a/net/ipv4/Kconfig	2008-07-09 09:52:50.000000000 -0700
+++ b/net/ipv4/Kconfig	2008-07-09 09:54:27.000000000 -0700
@@ -622,7 +622,7 @@ config DEFAULT_TCP_CONG
 
 config TCP_MD5SIG
 	bool "TCP: MD5 Signature Option support (RFC2385) (EXPERIMENTAL)"
-	depends on EXPERIMENTAL
+	depends on EXPERIMENTAL && BROKEN
 	select CRYPTO
 	select CRYPTO_MD5
 	---help---
@@ -631,6 +631,8 @@ config TCP_MD5SIG
 	  on the Internet.
 
 	  If unsure, say N.
+	  The current version is broken for case of TCP SACK and devices that
+          use TSO or Scatter/Gather.
 
 source "net/ipv4/ipvs/Kconfig"
 
