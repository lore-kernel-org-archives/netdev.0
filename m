From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] net: bnx2x: fix build error with ptp
Date: Mon, 25 Aug 2014 13:11:48 -0700
Message-ID: <53FB9884.8000707@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jim Davis <jim.epost@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Ariel Elior <ariel.elior@qlogic.com>
To: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>

bnx2x uses ptp functions, so it should select the provider of
those functions (PTP_1588_CLOCK).  Fixes these build errors:

drivers/built-in.o: In function `__bnx2x_remove':
/home/jim/linux/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:13409:
undefined reference to `ptp_clock_unregister'
drivers/built-in.o: In function `bnx2x_register_phc':
/home/jim/linux/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:13202:
undefined reference to `ptp_clock_register'
drivers/built-in.o: In function `bnx2x_get_ts_info':
/home/jim/linux/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c:3498:
undefined reference to `ptp_clock_index'

Reported-by: Jim Davis <jim.epost@gmail.com>
Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 drivers/net/ethernet/broadcom/Kconfig |    1 +
 1 file changed, 1 insertion(+)

Index: linux-next-20140825/drivers/net/ethernet/broadcom/Kconfig
===================================================================
--- linux-next-20140825.orig/drivers/net/ethernet/broadcom/Kconfig
+++ linux-next-20140825/drivers/net/ethernet/broadcom/Kconfig
@@ -122,6 +122,7 @@ config TIGON3
 config BNX2X
 	tristate "Broadcom NetXtremeII 10Gb support"
 	depends on PCI
+	select PTP_1588_CLOCK
 	select FW_LOADER
 	select ZLIB_INFLATE
 	select LIBCRC32C
