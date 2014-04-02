From: mihailov ivan <mihailov.iaa@gmail.com>
Subject: [PATCH] add missing support of 10mbit in emac/rgmii
Date: Wed, 2 Apr 2014 21:41:50 +0400
Message-ID: <CA+Z7AcYQSwYj7SGWnFSrsN_LMM=R6yJbiosiSQRJ3Eq39U3Xmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:41301 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932598AbaDBRlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 13:41:52 -0400
Received: by mail-wg0-f46.google.com with SMTP id b13so620395wgh.5
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 10:41:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In chips of emac/rgmii b'000' for 0/1 channel isn't suitable which
resulted in non working network interface in this mode.

Signed-off-by: Ivan Mikhaylov <mihailov.iaa@gmail.com>

--- a/drivers/net/ethernet/ibm/
emac/rgmii.c    2014-03-31
07:40:15.000000000 +0400
+++ b/drivers/net/ethernet/ibm/emac/rgmii.c    2014-04-02
19:52:12.957559554 +0400
@@ -45,6 +45,7 @@

 /* RGMIIx_SSR */
 #define RGMII_SSR_MASK(idx)    (0x7 << ((idx) * 8))
+#define RGMII_SSR_10(idx)    (0x1 << ((idx) * 8))
 #define RGMII_SSR_100(idx)    (0x2 << ((idx) * 8))
 #define RGMII_SSR_1000(idx)    (0x4 << ((idx) * 8))

@@ -139,6 +140,8 @@
         ssr |= RGMII_SSR_1000(input);
     else if (speed == SPEED_100)
         ssr |= RGMII_SSR_100(input);
+    else if (speed == SPEED_10)
+        ssr |= RGMII_SSR_10(input);

     out_be32(&p->ssr, ssr);
