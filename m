From: Sameer Nanda <snanda@chromium.org>
Subject: [PATCH 1/2] r8169: Enable WOL from Magic Packet by
	default
Date: Tue, 14 Feb 2012 10:27:59 -0800
Message-ID: <1329244079-27842-1-git-send-email-snanda@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	Sameer Nanda <snanda@chromium.org>
To: omieu@fr.zoreil.com,
	jw@sisk.pl,
	hayeswang@realtek.com
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/linux-pm/>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Set the WOL config registers to only enable WOL from magic packet by
default. Without this change in place, the WOL config register
settings on warm reboot come up in an inconsistent state since these
registers don't get reset on a warm reboot.

Signed-off-by: Sameer Nanda <snanda@chromium.org>
---
 drivers/net/ethernet/realtek/r8169.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7a0c800..a6921b7 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4073,12 +4073,13 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->txd_version = rtl_chip_infos[chipset].txd_version;
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
+
+	/* Enable WOL from Magic Packet by default */
 	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
-	RTL_W8(Config5, RTL_R8(Config5) & PMEStatus);
-	if ((RTL_R8(Config3) & (LinkUp | MagicPacket)) != 0)
-		tp->features |= RTL_FEATURE_WOL;
-	if ((RTL_R8(Config5) & (UWF | BWF | MWF)) != 0)
-		tp->features |= RTL_FEATURE_WOL;
+	RTL_W8(Config3, MagicPacket);
+	RTL_W8(Config5, PMEStatus);
+	tp->features |= RTL_FEATURE_WOL;
+
 	tp->features |= rtl_try_msi(tp, cfg);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-- 
1.7.7.3
