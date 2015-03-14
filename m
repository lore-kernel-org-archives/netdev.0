From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH 2/2] ath10k: core: harmonize error case handling in
 ath10k_core_start
Date: Sat, 14 Mar 2015 04:55:13 -0400
Message-ID: <1426323313-1344-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 linux-kernel@vger.kernel.org, ath10k@lists.infradead.org,
 Michal Kazior <michal.kazior@tieto.com>, Nicholas Mc Guire <hofrat@osadl.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>
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

All of the bringup/init functions called in ath10k_core_start return 0 on
success and != 0 on failure - ath10k_wmi_wait_for_service_ready and
ath10k_wmi_wait_for_unified_ready were adjusted to fit this model and the
call sites here fixed up accordingly. 

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Patch was only compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_ATH10K=m

Patch is against 4.0-rc3 (localversion-next is -next-20150313)

 drivers/net/wireless/ath/ath10k/core.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/core.c b/drivers/net/wireless/ath/ath10k/core.c
index c0e454b..e97069f 100644
--- a/drivers/net/wireless/ath/ath10k/core.c
+++ b/drivers/net/wireless/ath/ath10k/core.c
@@ -1080,9 +1080,8 @@ int ath10k_core_start(struct ath10k *ar, enum ath10k_firmware_mode mode)
 
 	if (mode == ATH10K_FIRMWARE_MODE_NORMAL) {
 		status = ath10k_wmi_wait_for_service_ready(ar);
-		if (status <= 0) {
+		if (status) {
 			ath10k_warn(ar, "wmi service ready event not received");
-			status = -ETIMEDOUT;
 			goto err_hif_stop;
 		}
 	}
@@ -1098,9 +1097,8 @@ int ath10k_core_start(struct ath10k *ar, enum ath10k_firmware_mode mode)
 	}
 
 	status = ath10k_wmi_wait_for_unified_ready(ar);
-	if (status <= 0) {
+	if (status) {
 		ath10k_err(ar, "wmi unified ready event not received\n");
-		status = -ETIMEDOUT;
 		goto err_hif_stop;
 	}
 
-- 
1.7.10.4
