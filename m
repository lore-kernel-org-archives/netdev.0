From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] libertas: fix possible NULL dereference
Date: Mon, 23 Nov 2015 18:02:02 +0530
Message-ID: <1448281922-20382-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, libertas-dev@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We were dereferencing cmd first and checking for NULL later. Lets first
check for NULL.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 drivers/net/wireless/marvell/libertas/cfg.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/libertas/cfg.c b/drivers/net/wireless/marvell/libertas/cfg.c
index 8317afd..e38ad1d 100644
--- a/drivers/net/wireless/marvell/libertas/cfg.c
+++ b/drivers/net/wireless/marvell/libertas/cfg.c
@@ -1108,7 +1108,7 @@ static int lbs_associate(struct lbs_private *priv,
 	size_t len, resp_ie_len;
 	int status;
 	int ret;
-	u8 *pos = &(cmd->iebuf[0]);
+	u8 *pos;
 	u8 *tmp;
 
 	lbs_deb_enter(LBS_DEB_CFG80211);
@@ -1117,6 +1117,7 @@ static int lbs_associate(struct lbs_private *priv,
 		ret = -ENOMEM;
 		goto done;
 	}
+	pos = &cmd->iebuf[0];
 
 	/*
 	 * cmd              50 00
-- 
1.9.1
