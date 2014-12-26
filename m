From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 12/27] iwlwifi: dvm: main: Use setup_timer
Date: Fri, 26 Dec 2014 15:35:44 +0100
Message-ID: <1419604558-29743-14-git-send-email-Julia.Lawall@lip6.fr>
References: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert a call to init_timer and accompanying intializations of
the timer's data and function fields to a call to setup_timer.

A simplified version of the semantic match that fixes this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression t,f,d;
@@

-init_timer(&t);
+setup_timer(&t,f,d);
-t.data = d;
-t.function = f;
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wireless/iwlwifi/dvm/main.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/dvm/main.c b/drivers/net/wireless/iwlwifi/dvm/main.c
index 0b7f46f..75ec691 100644
--- a/drivers/net/wireless/iwlwifi/dvm/main.c
+++ b/drivers/net/wireless/iwlwifi/dvm/main.c
@@ -1011,13 +1011,11 @@ static void iwl_setup_deferred_work(struct iwl_priv *priv)
 	if (priv->lib->bt_params)
 		iwlagn_bt_setup_deferred_work(priv);
 
-	init_timer(&priv->statistics_periodic);
-	priv->statistics_periodic.data = (unsigned long)priv;
-	priv->statistics_periodic.function = iwl_bg_statistics_periodic;
+	setup_timer(&priv->statistics_periodic, iwl_bg_statistics_periodic,
+		    (unsigned long)priv);
 
-	init_timer(&priv->ucode_trace);
-	priv->ucode_trace.data = (unsigned long)priv;
-	priv->ucode_trace.function = iwl_bg_ucode_trace;
+	setup_timer(&priv->ucode_trace, iwl_bg_ucode_trace,
+		    (unsigned long)priv);
 }
 
 void iwl_cancel_deferred_work(struct iwl_priv *priv)
