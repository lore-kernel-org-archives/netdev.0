From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: [PATCH] [ROSE] ROSE_PACLEN  definition used a number constant value
Date: Fri, 14 Dec 2007 23:42:37 +0100
Message-ID: <476306DD.60001@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010203080103010200060201"
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix2-g20.free.fr ([212.27.60.43]:59412 "EHLO
	postfix2-g20.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757424AbXLNWxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 17:53:20 -0500
Received: from smtp5-g19.free.fr (smtp5-g19.free.fr [212.27.42.35])
	by postfix2-g20.free.fr (Postfix) with ESMTP id 9E524213456B
	for <netdev@vger.kernel.org>; Fri, 14 Dec 2007 21:52:30 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010203080103010200060201
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

ROSE_PACLEN was defined by a substraction using a fixed constant value 
of 256 in af_rose.c

#define ROSE_PACLEN (256-ROSE_MIN_LEN)

For more convenience 256 is replaced by AX25_DEF_PACLEN default size 
declared in ax25.h which is the actual AX25 MTU.


signed off by Bernard Pidoux, f6bvp@amsat.org


--------------010203080103010200060201
Content-Type: text/plain;
 name="rose-2.6.24-rc5.patch5"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rose-2.6.24-rc5.patch5"

--- linux-2.6.24-rc5/net/rose/af_rose.c	2007-12-11 04:48:43.000000000 +0100
+++ b/net/rose/af_rose.c	2007-12-14 14:35:16.000000000 +0100
@@ -1148,7 +1148,7 @@
 	}
 
 #ifdef M_BIT
-#define ROSE_PACLEN (256-ROSE_MIN_LEN)
+#define ROSE_PACLEN (AX25_DEF_PACLEN-ROSE_MIN_LEN)
 	if (skb->len - ROSE_MIN_LEN > ROSE_PACLEN) {
 		unsigned char header[ROSE_MIN_LEN];
 		struct sk_buff *skbn;
 

--------------010203080103010200060201--

