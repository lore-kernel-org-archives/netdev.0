From: Punit Vara <punitvara@gmail.com>
Subject: [PATCH 09/15] net: wireless: simplify return flow for zd1201_setconfig16
Date: Wed, 21 Oct 2015 20:25:31 +0530
Message-ID: <1445439337-19055-10-git-send-email-punitvara@gmail.com>
References: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
Cc: stas.yakovlev@gmail.com, chaoming_li@realsil.com.cn,
	Larry.Finger@lwfinger.net, chunkeey@googlemail.com,
	sgruszka@redhat.com, brudley@broadcom.com, arend@broadcom.com,
	linville@tuxdriver.com, jirislaby@gmail.com, mickflemm@gmail.com,
	mcgrof@do-not-panic.com, k.eugene.e@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, wcn36xx@lists.infradead.org,
	johannes.berg@intel.com, meuleman@broadcom.com,
	Punit Vara <punitvara@gmail.com>
To: kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to the zd1201.c file that fixes up warning
reported by coccicheck:

WARNING: end returns can be simplified and declaration on line 1658 can
be dropped

Prefer direct return value instead of writing 2-3 more sentence.

Signed-off-by: Punit Vara <punitvara@gmail.com>
---
 drivers/net/wireless/zd1201.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 6f5c793..d9e67d9 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -1655,15 +1655,11 @@ static int zd1201_set_maxassoc(struct net_device *dev,
     struct iw_request_info *info, struct iw_param *rrq, char *extra)
 {
 	struct zd1201 *zd = netdev_priv(dev);
-	int err;
 
 	if (!zd->ap)
 		return -EOPNOTSUPP;
 
-	err = zd1201_setconfig16(zd, ZD1201_RID_CNFMAXASSOCSTATIONS, rrq->value);
-	if (err)
-		return err;
-	return 0;
+	return zd1201_setconfig16(zd, ZD1201_RID_CNFMAXASSOCSTATIONS, rrq->value);
 }
 
 static int zd1201_get_maxassoc(struct net_device *dev,
-- 
2.5.3
