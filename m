From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 5/6] nfp: don't completely refuse to work with old flashes
Date: Thu, 27 Apr 2017 21:06:19 -0700
Message-ID: <20170428040620.8256-6-jakub.kicinski@netronome.com>
References: <20170428040620.8256-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33998 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751304AbdD1EHB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 00:07:01 -0400
Received: by mail-pg0-f50.google.com with SMTP id v1so8366958pgv.1
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 21:07:01 -0700 (PDT)
In-Reply-To: <20170428040620.8256-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right now the required Service Process ABI version is still tied
to max ID of known commands.  For new NSP commands we are adding
we are checking if NSP version is recent enough on command-by-command
basis.  The driver doesn't have to force the device to have the
very latest flash, anything newer than 0.8 should do.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
index 61797c98f5fe..2fa9247bb23d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
@@ -78,7 +78,7 @@
 
 #define NSP_MAGIC		0xab10
 #define NSP_MAJOR		0
-#define NSP_MINOR		(__MAX_SPCODE - 1)
+#define NSP_MINOR		8
 
 #define NSP_CODE_MAJOR		GENMASK(15, 12)
 #define NSP_CODE_MINOR		GENMASK(11, 0)
@@ -94,8 +94,6 @@ enum nfp_nsp_cmd {
 	SPCODE_ETH_RESCAN	= 7, /* Rescan ETHs, write ETH_TABLE to buf */
 	SPCODE_ETH_CONTROL	= 8, /* Update media config from buffer */
 	SPCODE_NSP_IDENTIFY	= 13, /* Read NSP version */
-
-	__MAX_SPCODE,
 };
 
 static const struct {
-- 
2.11.0
