From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 1/5] iwlwifi: iwl3945 flush interrupt mask
Date: Wed,  9 Jan 2008 20:02:14 +0900
Message-ID: <11998765342443-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Joonwoo Park <joonwpark81@gmail.com>,
	ipw3945-devel@lists.sourceforge.net
To: Zhu Yi <yi.zhu@intel.com>, netdev@vger.kernel.org
Return-path: <ipw3945-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ipw3945-devel>
List-Post: <mailto:ipw3945-devel@lists.sourceforge.net>
List-Help: <mailto:ipw3945-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw3945-devel-bounces@lists.sourceforge.net
Errors-To: ipw3945-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

After enabling/disabling interrupts flushing is required

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 drivers/net/wireless/iwlwifi/iwl-io.h       |    2 ++
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    6 ++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-io.h b/drivers/net/wireless/iwlwifi/iwl-io.h
index 8a8b96f..f2bc30e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-io.h
+++ b/drivers/net/wireless/iwlwifi/iwl-io.h
@@ -87,6 +87,8 @@ static inline u32 __iwl_read32(char *f, u32 l, struct iwl_priv *iwl, u32 ofs)
 #define iwl_read32(p, o) _iwl_read32(p, o)
 #endif
 
+#define iwl_flush32(iwl, ofs) iwl_read32(iwl, ofs)
+
 static inline int _iwl_poll_bit(struct iwl_priv *priv, u32 addr,
 				u32 bits, u32 mask, int timeout)
 {
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 8ed898d..85f1112 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -4410,6 +4410,7 @@ static void iwl_enable_interrupts(struct iwl_priv *priv)
 	IWL_DEBUG_ISR("Enabling interrupts\n");
 	set_bit(STATUS_INT_ENABLED, &priv->status);
 	iwl_write32(priv, CSR_INT_MASK, CSR_INI_SET_MASK);
+	iwl_flush32(priv, CSR_INT_MASK);
 }
 
 static inline void iwl_disable_interrupts(struct iwl_priv *priv)
@@ -4418,11 +4419,15 @@ static inline void iwl_disable_interrupts(struct iwl_priv *priv)
 
 	/* disable interrupts from uCode/NIC to host */
 	iwl_write32(priv, CSR_INT_MASK, 0x00000000);
+	iwl_flush32(priv, CSR_INT_MASK);
 
 	/* acknowledge/clear/reset any interrupts still pending
 	 * from uCode or flow handler (Rx/Tx DMA) */
 	iwl_write32(priv, CSR_INT, 0xffffffff);
+	iwl_flush32(priv, CSR_INT);
 	iwl_write32(priv, CSR_FH_INT_STATUS, 0xffffffff);
+	iwl_flush32(priv, CSR_FH_INT_STATUS);
+
 	IWL_DEBUG_ISR("Disabled interrupts\n");
 }
 
@@ -4840,6 +4845,7 @@ static irqreturn_t iwl_isr(int irq, void *data)
 	 * If we *don't* have something, we'll re-enable before leaving here. */
 	inta_mask = iwl_read32(priv, CSR_INT_MASK);  /* just for debug */
 	iwl_write32(priv, CSR_INT_MASK, 0x00000000);
+	iwl_flush32(priv, CSR_INT_MASK);
 
 	/* Discover which interrupts are active/pending */
 	inta = iwl_read32(priv, CSR_INT);
-- 
1.5.3.rc5


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
