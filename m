From: Dmitry Artamonow <mad_soft@inbox.ru>
Subject: [PATCH] irda/sa1100_ir: check return value of startup hook
Date: Fri,  9 Oct 2009 11:25:53 +0400
Message-ID: <1255073153-24962-1-git-send-email-mad_soft@inbox.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Dmitry Artamonow <mad_soft@inbox.ru>
---
 drivers/net/irda/sa1100_ir.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
index 38bf7cf..df5db2d 100644
--- a/drivers/net/irda/sa1100_ir.c
+++ b/drivers/net/irda/sa1100_ir.c
@@ -232,8 +232,11 @@ static int sa1100_irda_startup(struct sa1100_irda *si)
 	/*
 	 * Ensure that the ports for this device are setup correctly.
 	 */
-	if (si->pdata->startup)
-		si->pdata->startup(si->dev);
+	if (si->pdata->startup)	{
+		ret = si->pdata->startup(si->dev);
+		if (ret)
+			return ret;
+		}
 
 	/*
 	 * Configure PPC for IRDA - we want to drive TXD2 low.
-- 
1.6.3.4
