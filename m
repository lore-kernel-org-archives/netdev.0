From: Sam Ravnborg <sam@ravnborg.org>
Subject: [PATCH][IPV4] annotate a few functions __init in ipconfig.c
Date: Tue, 29 Apr 2008 21:50:06 +0200
Message-ID: <20080429195006.GA468@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:40094 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753396AbYD2Ttc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 15:49:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few functions are only used from __init context.
So annotate these with __init for consistency and silence
the following warnings:

WARNING: net/ipv4/built-in.o(.text+0x2a876): Section mismatch
         in reference from the function ic_bootp_init() to
         the variable .init.data:bootp_packet_type
WARNING: net/ipv4/built-in.o(.text+0x2a907): Section mismatch
         in reference from the function ic_bootp_cleanup() to
         the variable .init.data:bootp_packet_type

Note: The warnings only appear with CONFIG_DEBUG_SECTION_MISMATCH=y

Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
---

Build testet only - but trivial.

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 0f42d1c..89dee43 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -412,12 +412,12 @@ static struct packet_type rarp_packet_type __initdata = {
 	.func =	ic_rarp_recv,
 };
 
-static inline void ic_rarp_init(void)
+static inline void __init ic_rarp_init(void)
 {
 	dev_add_pack(&rarp_packet_type);
 }
 
-static inline void ic_rarp_cleanup(void)
+static inline void __init ic_rarp_cleanup(void)
 {
 	dev_remove_pack(&rarp_packet_type);
 }
@@ -682,7 +682,7 @@ static void __init ic_bootp_init_ext(u8 *e)
 /*
  *  Initialize the DHCP/BOOTP mechanism.
  */
-static inline void ic_bootp_init(void)
+static inline void __init ic_bootp_init(void)
 {
 	int i;
 
@@ -696,7 +696,7 @@ static inline void ic_bootp_init(void)
 /*
  *  DHCP/BOOTP cleanup.
  */
-static inline void ic_bootp_cleanup(void)
+static inline void __init ic_bootp_cleanup(void)
 {
 	dev_remove_pack(&bootp_packet_type);
 }
