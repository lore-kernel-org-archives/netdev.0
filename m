From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 4/9] nfp: don't assume RSS and IRQ moderation are always enabled
Date: Mon, 15 May 2017 17:55:18 -0700
Message-ID: <20170516005523.26124-5-jakub.kicinski@netronome.com>
References: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36364 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750896AbdEPA40 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 20:56:26 -0400
Received: by mail-pf0-f173.google.com with SMTP id m17so71278331pfg.3
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 17:56:20 -0700 (PDT)
In-Reply-To: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even if capability for RSS and IRQ moderation are present we may
have not initialized them for control vNIC.  Depend on selected
features mask (ctrl) rather than capabilities (cap) to determine
which features should be enabled.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 5e8049a84d16..ae32c0e8d6e6 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2201,17 +2201,15 @@ static int nfp_net_set_config_and_enable(struct nfp_net *nn)
 
 	new_ctrl = nn->dp.ctrl;
 
-	if (nn->cap & NFP_NET_CFG_CTRL_RSS) {
+	if (nn->dp.ctrl & NFP_NET_CFG_CTRL_RSS) {
 		nfp_net_rss_write_key(nn);
 		nfp_net_rss_write_itbl(nn);
 		nn_writel(nn, NFP_NET_CFG_RSS_CTRL, nn->rss_cfg);
 		update |= NFP_NET_CFG_UPDATE_RSS;
 	}
 
-	if (nn->cap & NFP_NET_CFG_CTRL_IRQMOD) {
+	if (nn->dp.ctrl & NFP_NET_CFG_CTRL_IRQMOD) {
 		nfp_net_coalesce_write_cfg(nn);
-
-		new_ctrl |= NFP_NET_CFG_CTRL_IRQMOD;
 		update |= NFP_NET_CFG_UPDATE_IRQMOD;
 	}
 
-- 
2.11.0
