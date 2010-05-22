From: Dan Carpenter <error27@gmail.com>
Subject: [patch] caif: cleanup: remove duplicate checks
Date: Sat, 22 May 2010 22:45:19 +0200
Message-ID: <20100522204519.GW22515@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:42349 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758238Ab0EVUp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 16:45:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These checks merely duplicate the things we've asserted already.  In the
case of the checks for null we've already dereferenced those variables
as well.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index df43f26..cc2f072 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -313,14 +313,10 @@ cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id, enum cfctrl_srv serv,
 	caif_assert(phyinfo->phy_layer != NULL);
 	caif_assert(phyinfo->phy_layer->id == phyid);
 
-	if (phyinfo != NULL &&
-	    phyinfo->phy_ref_count++ == 0 &&
-	    phyinfo->phy_layer != NULL &&
+	if (phyinfo->phy_ref_count++ == 0 &&
 	    phyinfo->phy_layer->modemcmd != NULL) {
-		caif_assert(phyinfo->phy_layer->id == phyid);
 		phyinfo->phy_layer->modemcmd(phyinfo->phy_layer,
 					     _CAIF_MODEMCMD_PHYIF_USEFULL);
-
 	}
 	adapt_layer->id = channel_id;
 
