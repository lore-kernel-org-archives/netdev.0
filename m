From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv3 net-next 4/4] crypto: Added Chelsio Menu to the Kconfig file
Date: Wed, 17 Aug 2016 12:33:06 +0530
Message-ID: <1471417386-14026-5-git-send-email-hariprasad@chelsio.com>
References: <1471417386-14026-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	atul.gupta@chelsio.com, yeshaswi@chelsio.com, jlulla@chelsio.com,
	harsh@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:4071 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753853AbcHQHEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 03:04:30 -0400
In-Reply-To: <1471417386-14026-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds the config entry for the Chelsio Crypto Driver, Makefile changes
for the same.

Signed-off-by: Atul Gupta <atul.gupta@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/crypto/Kconfig          |    2 ++
 drivers/crypto/Makefile         |    1 +
 drivers/crypto/chelsio/Kconfig  |   19 +++++++++++++++++++
 drivers/crypto/chelsio/Makefile |    4 ++++
 4 files changed, 26 insertions(+), 0 deletions(-)
 create mode 100644 drivers/crypto/chelsio/Kconfig
 create mode 100644 drivers/crypto/chelsio/Makefile

diff --git a/drivers/crypto/Kconfig b/drivers/crypto/Kconfig
index d77ba2f..b44faf0 100644
--- a/drivers/crypto/Kconfig
+++ b/drivers/crypto/Kconfig
@@ -537,4 +537,6 @@ config CRYPTO_DEV_ROCKCHIP
 	  This driver interfaces with the hardware crypto accelerator.
 	  Supporting cbc/ecb chainmode, and aes/des/des3_ede cipher mode.
 
+source "drivers/crypto/chelsio/Kconfig"
+
 endif # CRYPTO_HW
diff --git a/drivers/crypto/Makefile b/drivers/crypto/Makefile
index 3c6432d..ad7250f 100644
--- a/drivers/crypto/Makefile
+++ b/drivers/crypto/Makefile
@@ -31,3 +31,4 @@ obj-$(CONFIG_CRYPTO_DEV_QCE) += qce/
 obj-$(CONFIG_CRYPTO_DEV_VMX) += vmx/
 obj-$(CONFIG_CRYPTO_DEV_SUN4I_SS) += sunxi-ss/
 obj-$(CONFIG_CRYPTO_DEV_ROCKCHIP) += rockchip/
+obj-$(CONFIG_CRYPTO_DEV_CHELSIO) += chelsio/
diff --git a/drivers/crypto/chelsio/Kconfig b/drivers/crypto/chelsio/Kconfig
new file mode 100644
index 0000000..2c05224
--- /dev/null
+++ b/drivers/crypto/chelsio/Kconfig
@@ -0,0 +1,19 @@
+config CRYPTO_DEV_CHELSIO
+	tristate "Chelsio Crypto Co-processor Driver"
+	depends on CHELSIO_T4 
+	select CRYPTO_SHA1
+	select CRYPTO_SHA256
+	select CRYPTO_SHA512
+	---help---
+	  The Chelsio Crypto Co-processor driver for T6 adapters.
+
+	  For general information about Chelsio and our products, visit
+	  our website at <http://www.chelsio.com>.
+
+	  For customer support, please visit our customer support page at
+	  <http://www.chelsio.com/support.html>.
+
+	  Please send feedback to <linux-bugs@chelsio.com>.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called chcr.
diff --git a/drivers/crypto/chelsio/Makefile b/drivers/crypto/chelsio/Makefile
new file mode 100644
index 0000000..7e4fda5
--- /dev/null
+++ b/drivers/crypto/chelsio/Makefile
@@ -0,0 +1,4 @@
+ ccflags-y := -Idrivers/net/ethernet/chelsio/cxgb4
+
+ obj-$(CONFIG_CRYPTO_DEV_CHELSIO) += chcr.o
+ chcr-objs :=  chcr_core.o chcr_algo.o
\ No newline at end of file
-- 
1.7.3
