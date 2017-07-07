From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net] nfp: flower: add missing clean up call to avoid memory leaks
Date: Thu,  6 Jul 2017 17:29:05 -0700
Message-ID: <20170707002905.31111-1-jakub.kicinski@netronome.com>
Cc: simon.horman@netronome.com, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35149 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753072AbdGGA3W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 20:29:22 -0400
Received: by mail-pf0-f169.google.com with SMTP id c73so8594103pfk.2
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2017 17:29:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nfp_flower_metadata_cleanup() is defined but never invoked,
not calling it will cause us to leak mask and statistics
queue memory on the host.

Fixes: 43f84b72c50d ("nfp: add metadata to each flow offload")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.c b/drivers/net/ethernet/netronome/nfp/flower/main.c
index fc10f27e0a0c..6a65c8b33807 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.c
@@ -356,6 +356,7 @@ static int nfp_flower_init(struct nfp_app *app)
 
 static void nfp_flower_clean(struct nfp_app *app)
 {
+	nfp_flower_metadata_cleanup(app);
 	vfree(app->priv);
 	app->priv = NULL;
 }
-- 
2.11.0
