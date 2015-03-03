From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH] ath:Release resources for structure pointer,
 ar if error pointing device in the function, ath10k_core_register_work
Date: Mon,  2 Mar 2015 21:36:11 -0500
Message-ID: <1425350171-26333-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 linux-kernel@vger.kernel.org, ath10k@lists.infradead.org
To: kvalo@qca.qualcomm.com
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Releases resources and deregisters the stucture pointer ar passed by the caller to the function, ath10k_core_register_work
if unable to probe the structure pointer successfully with a call to ath10k_core_probe_fw. Further more if this happerns
we must first jump to the label err for the goto statement required to jump to handle this particular error in the function,
ath10k_core_register_work.  After we are in the correct error section we must free the resources for the structure pointer,ar
with a call to the function,  ath10k_core_unregister to free resources allocated for the structure pointer,ar.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 drivers/net/wireless/ath/ath10k/core.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/core.c b/drivers/net/wireless/ath/ath10k/core.c
index 310e12b..8b2ca25 100644
--- a/drivers/net/wireless/ath/ath10k/core.c
+++ b/drivers/net/wireless/ath/ath10k/core.c
@@ -1307,9 +1307,7 @@ err_unregister_mac:
 err_release_fw:
 	ath10k_core_free_firmware_files(ar);
 err:
-	/* TODO: It's probably a good idea to release device from the driver
-	 * but calling device_release_driver() here will cause a deadlock.
-	 */
+	ath10k_core_unregister(ar);
 	return;
 }
 
-- 
2.1.0
