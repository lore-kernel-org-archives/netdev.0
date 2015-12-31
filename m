From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] net-thunder: One check less in nicvf_register_interrupts()
 after error detection
Date: Thu, 31 Dec 2015 22:47:31 +0100
Message-ID: <5685A273.6070607@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Julia Lawall <julia.lawall@lip6.fr>, kernel-janitors@vger.kernel.org,
 LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Robert Richter <rric@kernel.org>, Sunil Goutham <sgoutham@cavium.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <566ABCD9.1060404@users.sourceforge.net>
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

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 31 Dec 2015 22:40:39 +0100

Adjust a jump target to eliminate a check before error logging.
Use the identifier "report_failure" instead of "err".

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index c24cb2a..21e1579 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -922,7 +922,7 @@ static int nicvf_register_interrupts(struct nicvf *nic)
 		ret = request_irq(vector, nicvf_intr_handler,
 				  0, nic->irq_name[irq], nic->napi[irq]);
 		if (ret)
-			goto err;
+			goto report_failure;
 		nic->irq_allocated[irq] = true;
 	}
 
@@ -933,7 +933,7 @@ static int nicvf_register_interrupts(struct nicvf *nic)
 		ret = request_irq(vector, nicvf_rbdr_intr_handler,
 				  0, nic->irq_name[irq], nic);
 		if (ret)
-			goto err;
+			goto report_failure;
 		nic->irq_allocated[irq] = true;
 	}
 
@@ -944,13 +944,12 @@ static int nicvf_register_interrupts(struct nicvf *nic)
 	ret = request_irq(nic->msix_entries[irq].vector,
 			  nicvf_qs_err_intr_handler,
 			  0, nic->irq_name[irq], nic);
-	if (!ret)
+	if (!ret) {
 		nic->irq_allocated[irq] = true;
-
-err:
-	if (ret)
-		netdev_err(nic->netdev, "request_irq failed, vector %d\n", irq);
-
+		return 0;
+	}
+report_failure:
+	netdev_err(nic->netdev, "request_irq failed, vector %d\n", irq);
 	return ret;
 }
 
-- 
2.6.3
