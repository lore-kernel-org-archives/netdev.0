From: Takahiro Shimizu <tshimizu818@gmail.com>
Subject: [PATCH 1/2] ptp/ptp_pch: Changed PTP supporting mode
Date: Fri, 23 Mar 2012 11:18:58 +0900
Message-ID: <1332469139-2654-1-git-send-email-tshimizu818@gmail.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, Takahiro Shimizu <tshimizu818@gmail.com>
To: jeffrey.t.kirsher@intel.com, davem@davemloft.net,
	lucas.demarchi@profusion.mobi, mirq-linux@rere.qmqm.pl,
	paul.gortmaker@windriver.com, jdmason@kudzu.us,
	john.stultz@linaro.org, richardcochran@gmail.com, arnd@arndb.de,
	khc@pm.waw.pl, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Takahiro Shimizu <tshimizu818@gmail.com>
---
 drivers/ptp/Kconfig   |    4 ++--
 drivers/ptp/ptp_pch.c |    3 ++-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index cd9bc3b..6af221b 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -78,8 +78,8 @@ config PTP_1588_CLOCK_PCH
 	depends on PCH_GBE
 	help
 	  This driver adds support for using the PCH EG20T as a PTP
-	  clock. This clock is only useful if your PTP programs are
-	  getting hardware time stamps on the PTP Ethernet packets
+	  clock E2E mode. This clock is only useful if your PTP programs
+	  are getting hardware time stamps on the PTP Ethernet packets
 	  using the SO_TIMESTAMPING API.
 
 	  To compile this driver as a module, choose M here: the module
diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
index 212381e..08c3311 100644
--- a/drivers/ptp/ptp_pch.c
+++ b/drivers/ptp/ptp_pch.c
@@ -308,7 +308,7 @@ static void pch_reset(struct pch_dev *chip)
  *				    traffic on the  ethernet interface
  * @addr:	dress which contain the column separated address to be used.
  */
-static int pch_set_station_address(u8 *addr, struct pci_dev *pdev)
+int pch_set_station_address(u8 *addr, struct pci_dev *pdev)
 {
 	s32 i;
 	struct pch_dev *chip = pci_get_drvdata(pdev);
@@ -352,6 +352,7 @@ static int pch_set_station_address(u8 *addr, struct pci_dev *pdev)
 	}
 	return 0;
 }
+EXPORT_SYMBOL(pch_set_station_address);
 
 /*
  * Interrupt service routine
-- 
1.7.4.4
