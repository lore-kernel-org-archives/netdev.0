From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] net: tulip: rearrange order of searching for substrings
Date: Wed,  3 Jun 2015 13:44:03 +0200
Message-ID: <1433331843-32301-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, two of the branches are dead code, since an earlier smaller
substring would have been found ("TP" in the "TP_NW" case and either
of "BNC" and "AUI" in the "BNC_AUI" case). Rearrange the strstr()
calls so that the longer strings are searched for first.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
This is rather old code; presumably nobody ever noticed or cared. So
alternatively the dead branches can just be deleted.

 drivers/net/ethernet/dec/tulip/de4x5.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index badff181e719..8966f3159bb2 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -5189,16 +5189,16 @@ de4x5_parse_params(struct net_device *dev)
 	if (strstr(p, "fdx") || strstr(p, "FDX")) lp->params.fdx = true;
 
 	if (strstr(p, "autosense") || strstr(p, "AUTOSENSE")) {
-	    if (strstr(p, "TP")) {
-		lp->params.autosense = TP;
-	    } else if (strstr(p, "TP_NW")) {
+	    if (strstr(p, "TP_NW")) {
 		lp->params.autosense = TP_NW;
+	    } else if (strstr(p, "TP")) {
+		lp->params.autosense = TP;
+	    } else if (strstr(p, "BNC_AUI")) {
+		lp->params.autosense = BNC;
 	    } else if (strstr(p, "BNC")) {
 		lp->params.autosense = BNC;
 	    } else if (strstr(p, "AUI")) {
 		lp->params.autosense = AUI;
-	    } else if (strstr(p, "BNC_AUI")) {
-		lp->params.autosense = BNC;
 	    } else if (strstr(p, "10Mb")) {
 		lp->params.autosense = _10Mb;
 	    } else if (strstr(p, "100Mb")) {
-- 
2.1.3
