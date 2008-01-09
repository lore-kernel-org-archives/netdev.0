From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 2/5] iwlwifi: iwl3945 synchronize interrupt
	and tasklet for down iwlwifi
Date: Wed,  9 Jan 2008 20:02:28 +0900
Message-ID: <11998765481610-git-send-email-joonwpark81@gmail.com>
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

After disabling interrupts, it's possible irq & tasklet is pending or running
This patch eleminates races for down iwlwifi

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index c97448d..3986aaf 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -6262,6 +6262,10 @@ static void __iwl_down(struct iwl_priv *priv)
 	/* tell the device to stop sending interrupts */
 	iwl_disable_interrupts(priv);
 
+	/* synchronize irq and tasklet */
+	synchronize_irq(priv->pci_dev->irq);
+	tasklet_kill(&priv->irq_tasklet);
+
 	if (priv->mac80211_registered)
 		ieee80211_stop_queues(priv->hw);
 
-- 
1.5.3.rc5


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
