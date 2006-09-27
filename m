From: dean gaudet <dean@arctic.org>
Subject: Re: mii-tool gigabit support.
Date: Wed, 27 Sep 2006 12:15:08 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0609271208400.2299@twinlark.arctic.org>
References: <20060926145113.7a6791c8@freekitty>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, dhinds@pcmcia.sourceforge.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from twinlark.arctic.org ([207.7.145.18]:45279 "EHLO
	twinlark.arctic.org") by vger.kernel.org with ESMTP
	id S1030652AbWI0TPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 15:15:10 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060926145113.7a6791c8@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 26 Sep 2006, Stephen Hemminger wrote:

> The mii-tool utility seems to be abandoned and unmaintained?
> 
> Here is a version that does standard 1000baseT support.
> 	http://developer.osdl.org/shemminger/prototypes/mii-tool.tar.bz2

cool that's bugged me for a while...

there's an off-by-1 for the non-verbose basic output -- you need register 
10 but only read up to register 9.  patch below.

tested on various mobos with e1000, tg3, skge.

oh, two of my tyans show this (one e1000 one tg3):

  product info: vendor 00:08:18, model 25 rev 0

but i'm not physically at the boards so i can't find the PHY to see what 
model it is.

-dean


Index: mii-tool/mii-tool.c
===================================================================
--- mii-tool.orig/mii-tool.c	2006-09-26 14:44:56.000000000 -0700
+++ mii-tool/mii-tool.c	2006-09-27 12:05:03.000000000 -0700
@@ -233,7 +233,7 @@
     /* Some bits in the BMSR are latched, but we can't rely on being
        the only reader, so only the current values are meaningful */
     mdio_read(sock, MII_BMSR);
-    for (i = 0; i < ((verbose > 1) ? 32 : 10); i++)
+    for (i = 0; i < ((verbose > 1) ? 32 : MII_BASIC_MAX); i++)
 	mii_val[i] = mdio_read(sock, i);
 
     if (mii_val[MII_BMCR] == 0xffff) {
Index: mii-tool/mii.h
===================================================================
--- mii-tool.orig/mii.h	2006-09-26 14:44:59.000000000 -0700
+++ mii-tool/mii.h	2006-09-27 12:05:56.000000000 -0700
@@ -94,4 +94,7 @@
 #define   MII_LPA2_1000FULL	0x0800
 #define   MII_LPA2_1000HALF	0x0400
 
+/* Last register we need for show_basic_mii() */
+#define MII_BASIC_MAX		(MII_STAT1000+1)
+
 #endif /* _LINUX_MII_H */
