From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 1/3] nfp: remove the probe deferral when FW not present
Date: Wed, 26 Jul 2017 11:09:46 -0700
Message-ID: <20170726180948.3220-2-jakub.kicinski@netronome.com>
References: <20170726180948.3220-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:33727 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751406AbdGZSMc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 14:12:32 -0400
Received: by mail-pg0-f44.google.com with SMTP id b8so10822693pgn.0
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 11:12:32 -0700 (PDT)
In-Reply-To: <20170726180948.3220-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We use a hack to defer probe when firmware was not pre-loaded
or found on disk.  This helps in case users forgot to include
firmware in initramfs, the driver will most likely get another
shot at probing after real root is mounted.

This is not for what EPROBE_DEFER is supposed to be used, and
when FW is completely missing every time new device is probed
NFP will reprobe spamming kernel logs.

Remove this hack, users will now have to make sure the right
firmware image is present in initramfs if nfp.ko is placed
there or built in.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 5797dbf2b507..d5e2361f0e86 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -704,7 +704,7 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 	if (!pf->rtbl) {
 		nfp_err(pf->cpp, "No %s, giving up.\n",
 			pf->fw_loaded ? "symbol table" : "firmware found");
-		return -EPROBE_DEFER;
+		return -EINVAL;
 	}
 
 	mutex_lock(&pf->lock);
-- 
2.11.0
