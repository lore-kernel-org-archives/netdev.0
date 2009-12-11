From: Paul Mundt <lethal@linux-sh.org>
Subject: [PATCH] net: smc91x: Fix up type mismatch in smc_drv_resume().
Date: Fri, 11 Dec 2009 15:42:27 +0900
Message-ID: <20091211064226.GA7625@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicolas Pitre <nico@fluxnic.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757574AbZLKGm0@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

smc_drv_resume() takes a struct device, while smc_enable_device() takes a
platform device. This fixes up the smc_enable_device() callsite with the
proper pointer.

It's not obvious when this change was introduced, as git history doesn't
go back that far. Presumably the resume code has always been broken in
this fashion.

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

---

 drivers/net/smc91x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index ae4983a..5c9222d 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -2387,7 +2387,7 @@ static int smc_drv_resume(struct device *dev)
 
 	if (ndev) {
 		struct smc_local *lp = netdev_priv(ndev);
-		smc_enable_device(dev);
+		smc_enable_device(pdev);
 		if (netif_running(ndev)) {
 			smc_reset(ndev);
 			smc_enable(ndev);
