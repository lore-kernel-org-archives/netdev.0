From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: [PATCH] [ROSE] ax25_send_frame() called with a constant paclen =
 260
Date: Fri, 14 Dec 2007 23:49:11 +0100
Message-ID: <47630867.5040404@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060705000208020205070407"
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix1-g20.free.fr ([212.27.60.42]:49373 "EHLO
	postfix1-g20.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757424AbXLNWzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 17:55:08 -0500
Received: from smtp5-g19.free.fr (smtp5-g19.free.fr [212.27.42.35])
	by postfix1-g20.free.fr (Postfix) with ESMTP id 98E652021070
	for <netdev@vger.kernel.org>; Fri, 14 Dec 2007 23:55:06 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060705000208020205070407
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

In rose_link.c ax25_send_frame() was called with a constant paclen 
parameter of 260 bytes.
This value looked odd to me for it did not correspond to any defined or 
possible computed length.Replacing this value by 0 (zero) allowed 
ax25_send_frame() to substitute it by the default AX25 frame size, which 
in turn induced significant results on the AX25 frame fragmentation and 
removed some garbage trailing characters in AX25 frames sent.


signed off by Bernard Pidoux, f6bvp@amsat.org

--------------060705000208020205070407
Content-Type: text/plain;
 name="rose-2.6.24-rc5.patch6"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rose-2.6.24-rc5.patch6"

--- linux-2.6.24-rc5/net/rose/rose_link.c	2007-12-11 04:48:43.000000000 +0100
+++ b/net/rose/rose_link.c	2007-12-14 14:39:23.000000000 +0100
@@ -107,7 +107,7 @@
 	else
 		rose_call = &rose_callsign;
 
-	neigh->ax25 = ax25_send_frame(skb, 260, rose_call, &neigh->callsign, neigh->digipeat, neigh->dev);
+	neigh->ax25 = ax25_send_frame(skb, 0, rose_call, &neigh->callsign, neigh->digipeat, neigh->dev);
 
 	return (neigh->ax25 != NULL);
 }

--------------060705000208020205070407--

