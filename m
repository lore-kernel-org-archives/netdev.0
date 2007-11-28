From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH 2/2] [net/wireless/iwlwifi] : iwlwifi 4965
	Fix race conditional panic.
Date: Wed, 28 Nov 2007 19:41:08 +0900
Message-ID: <00e601c831ab$30475910$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: <yi.zhu@intel.com>, <ipw3945-devel@lists.sourceforge.net>,
	<linux-wireless@vger.kernel.org>
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

I think 4965 may suffer it too, but I could not test.

Thanks
Joonwoo

[net/wireless/iwlwifi] : iwlwifi 4965 Fix race conditional panic.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index 9918780..a71a572 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -9165,6 +9165,7 @@ static void iwl_pci_remove(struct pci_dev *pdev)
 	IWL_DEBUG_INFO("*** UNLOAD DRIVER ***\n");
 
 	mutex_lock(&priv->mutex);
+	cancel_delayed_work_sync(&priv->init_alive_start);
 	set_bit(STATUS_EXIT_PENDING, &priv->status);
 	__iwl_down(priv);
 	mutex_unlock(&priv->mutex);
---


-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
