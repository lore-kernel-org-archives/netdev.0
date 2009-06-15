From: Paul Mundt <lethal@linux-sh.org>
Subject: [PATCH] net: CNIC depends on PCI.
Date: Tue, 16 Jun 2009 03:12:44 +0900
Message-ID: <20090615181244.GC30693@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 124x34x33x190.ap124.ftth.ucom.ne.jp ([124.34.33.190]:42248 "EHLO
	master.linux-sh.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933154AbZFOSNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 14:13:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even though this driver does shifty things with UIO to make it less
obvious, it is still PCI dependent:

drivers/net/cnic.c:2395: error: implicit declaration of function 'pci_dev_get'
make[3]: *** [drivers/net/cnic.o] Error 1
make[2]: *** [drivers/net] Error 2

This fixes up the CONFIG_PCI=n case, primarily triggered on
allmodconfig/allyesconfig builds:

Signed-off-by: Paul Mundt <lethal@linux-sh.org>
Cc: Michael Chan <mchan@broadcom.com>

---

 drivers/net/Kconfig |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 3b63831..f6d6888 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2272,8 +2272,7 @@ config BNX2
 
 config CNIC
 	tristate "Broadcom CNIC support"
-	depends on BNX2
-	depends on UIO
+	depends on PCI && BNX2 && UIO
 	help
 	  This driver supports offload features of Broadcom NetXtremeII
 	  gigabit Ethernet cards.
