From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH 3/8] staging: et131x: Use for loop to initialise contiguous
 registers to zero
Date: Wed, 20 Aug 2014 23:17:53 +0100
Message-ID: <1408573078-9320-4-git-send-email-mark.einon@gmail.com>
References: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Mark Einon <mark.einon@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Replace a long list of contiguous writel() calls with a for loop iterating
over the same values.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---
 drivers/staging/et131x/et131x.c | 27 +++------------------------
 1 file changed, 3 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index fffe763..44cc684 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -1138,6 +1138,7 @@ static void et1310_config_rxmac_regs(struct et131x_adapter *adapter)
 	u32 sa_lo;
 	u32 sa_hi = 0;
 	u32 pf_ctrl = 0;
+	u32 *wolw;
 
 	/* Disable the MAC while it is being configured (also disable WOL) */
 	writel(0x8, &rxmac->ctrl);
@@ -1151,30 +1152,8 @@ static void et1310_config_rxmac_regs(struct et131x_adapter *adapter)
 	 * its default Values of 0x00000000 because there are not WOL masks
 	 * as of this time.
 	 */
-	writel(0, &rxmac->mask0_word0);
-	writel(0, &rxmac->mask0_word1);
-	writel(0, &rxmac->mask0_word2);
-	writel(0, &rxmac->mask0_word3);
-
-	writel(0, &rxmac->mask1_word0);
-	writel(0, &rxmac->mask1_word1);
-	writel(0, &rxmac->mask1_word2);
-	writel(0, &rxmac->mask1_word3);
-
-	writel(0, &rxmac->mask2_word0);
-	writel(0, &rxmac->mask2_word1);
-	writel(0, &rxmac->mask2_word2);
-	writel(0, &rxmac->mask2_word3);
-
-	writel(0, &rxmac->mask3_word0);
-	writel(0, &rxmac->mask3_word1);
-	writel(0, &rxmac->mask3_word2);
-	writel(0, &rxmac->mask3_word3);
-
-	writel(0, &rxmac->mask4_word0);
-	writel(0, &rxmac->mask4_word1);
-	writel(0, &rxmac->mask4_word2);
-	writel(0, &rxmac->mask4_word3);
+	for (wolw = &rxmac->mask0_word0; wolw <= &rxmac->mask4_word3; wolw++)
+		writel(0, wolw);
 
 	/* Lets setup the WOL Source Address */
 	sa_lo = (adapter->addr[2] << ET_RX_WOL_LO_SA3_SHIFT) |
-- 
2.1.0
