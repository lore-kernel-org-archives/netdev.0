From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: RE: [PATCH 2/2] [net/wireless/iwlwifi] : iwlwifi 4965 Fix race conditional panic.
Date: Thu, 29 Nov 2007 10:43:16 +0900
Message-ID: <016501c83229$3abdbbe0$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <yi.zhu@intel.com>, <ipw3945-devel@lists.sourceforge.net>,
	<linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:63523 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761951AbXK2Bni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 20:43:38 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2006558wah
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2007 17:43:38 -0800 (PST)
References: 
In-Reply-To: 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cancel_delayed_work_sync has moved into ilw_cancel_deferred_work.
Thanks Zhu Yi.

[net/wireless/iwlwifi] : iwlwifi 4965 Fix race conditional panic.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index 9918780..2474eba 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -8864,6 +8864,7 @@ static void iwl_cancel_deferred_work(struct iwl_priv *priv)
 {
 	iwl_hw_cancel_deferred_work(priv);
 
+	cancel_delayed_work_sync(&priv->init_alive_start);
 	cancel_delayed_work(&priv->scan_check);
 	cancel_delayed_work(&priv->alive_start);
 	cancel_delayed_work(&priv->post_associate);
---

