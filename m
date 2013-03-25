From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH 1/1 net-next] net: fec: build fec.c and fec_ptp.c to one module
Date: Mon, 25 Mar 2013 09:03:42 +0800
Message-ID: <1364173422-7865-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Frank Li <Frank.Li@freescale.com>
To: <festevam@gmail.com>, <lznuaa@gmail.com>,
 <u.kleine-koenig@pengutronix.de>, <netdev@vger.kernel.org>,
 <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

fec_ptp.ko can't run individually
rename fec.c to fec_main.c
Build fec.o and fec_ptp.o into one fec.ko
Remove unnessary EXPORT_SYMBOL in fec_ptp

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/Makefile            |    3 ++-
 .../net/ethernet/freescale/{fec.c => fec_main.c}   |    0
 drivers/net/ethernet/freescale/fec_ptp.c           |    3 ---
 3 files changed, 2 insertions(+), 4 deletions(-)
 rename drivers/net/ethernet/freescale/{fec.c => fec_main.c} (100%)

diff --git a/drivers/net/ethernet/freescale/Makefile b/drivers/net/ethernet/freescale/Makefile
index b7d58fe..549ce13 100644
--- a/drivers/net/ethernet/freescale/Makefile
+++ b/drivers/net/ethernet/freescale/Makefile
@@ -2,7 +2,8 @@
 # Makefile for the Freescale network device drivers.
 #
 
-obj-$(CONFIG_FEC) += fec.o fec_ptp.o
+obj-$(CONFIG_FEC) += fec.o
+fec-objs :=fec_main.o fec_ptp.o
 obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
 ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
 	obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx_phy.o
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec_main.c
similarity index 100%
rename from drivers/net/ethernet/freescale/fec.c
rename to drivers/net/ethernet/freescale/fec_main.c
diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 0d8df40..1f17ca0 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -128,7 +128,6 @@ void fec_ptp_start_cyclecounter(struct net_device *ndev)
 
 	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
 }
-EXPORT_SYMBOL(fec_ptp_start_cyclecounter);
 
 /**
  * fec_ptp_adjfreq - adjust ptp cycle frequency
@@ -319,7 +318,6 @@ int fec_ptp_ioctl(struct net_device *ndev, struct ifreq *ifr, int cmd)
 	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
 	    -EFAULT : 0;
 }
-EXPORT_SYMBOL(fec_ptp_ioctl);
 
 /**
  * fec_time_keep - call timecounter_read every second to avoid timer overrun
@@ -385,4 +383,3 @@ void fec_ptp_init(struct net_device *ndev, struct platform_device *pdev)
 		pr_info("registered PHC device on %s\n", ndev->name);
 	}
 }
-EXPORT_SYMBOL(fec_ptp_init);
-- 
1.7.1
