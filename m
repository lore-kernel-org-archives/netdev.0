From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH net-next] staging: irda: force to be a kernel module
Date: Tue, 29 Aug 2017 11:14:17 +0200
Message-ID: <20170829091417.GA9481@kroah.com>
References: <20170829070929.GA15824@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devel@driverdev.osuosl.org
To: davem@davemloft.net, samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170829070929.GA15824@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the IRDA networking code has moved into drivers/staging/, the
link order is changed for when it is initialized if built into the
system.  This can cause a crash when initializing as the netfilter core
hasn't been initialized yet.

So force the IRDA code to be built as a module, preventing the crash.

Reported-by: kernel test robot <fengguang.wu@intel.com>
Signed-off-by: Greg Kroah-Hartman gregkh@linuxfoundation.org
---
 drivers/staging/irda/net/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/irda/net/Kconfig b/drivers/staging/irda/net/Kconfig
index 6abeae6c666a..9c6489bcb596 100644
--- a/drivers/staging/irda/net/Kconfig
+++ b/drivers/staging/irda/net/Kconfig
@@ -3,7 +3,7 @@
 #
 
 menuconfig IRDA
-	depends on NET && !S390
+	depends on NET && !S390 && m
 	tristate "IrDA (infrared) subsystem support"
 	select CRC_CCITT
 	---help---
-- 
2.14.1
