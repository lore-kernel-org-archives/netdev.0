From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] qtnfmac: fix uninitialized return code in ret
Date: Wed, 21 Jun 2017 14:25:30 +0100
Message-ID: <20170621132530.11937-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Igor Mitsyanko <imitsyanko@quantenna.com>,
        Avinash Patil <avinashp@quantenna.com>,
        Sergey Matyukevich <smatyukevich@quantenna.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "David S . Miller" <davem@davemloft.net>,
        Bindu Therthala <btherthala@quantenna.com>,
        Kamlesh Rath <krath@quantenna.com>,
        Sergei Maksimenko <smaksimenko@quantenna.com>,
        Johannes Berg <johannes.berg@intel.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The return value ret is unitialized and garbage is being returned
for the three different error conditions when setting up the PCIe
BARs. Fix this by initializing ret to  -ENOMEM to indicate that
the BARs failed to be setup correctly.

Detected by CoverityScan, CID#1437563 ("Unitialized scalar variable")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c b/drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c
index f93b27f3a236..7fc4f0d6a9ad 100644
--- a/drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c
+++ b/drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c
@@ -247,7 +247,7 @@ static void qtnf_pcie_free_shm_ipc(struct qtnf_pcie_bus_priv *priv)
 
 static int qtnf_pcie_init_memory(struct qtnf_pcie_bus_priv *priv)
 {
-	int ret;
+	int ret = -ENOMEM;
 
 	priv->sysctl_bar = qtnf_map_bar(priv, QTN_SYSCTL_BAR);
 	if (IS_ERR_OR_NULL(priv->sysctl_bar)) {
-- 
2.11.0
