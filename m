From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 13/14] at86rf230: remove
	unnecessary state read
Date: Thu, 24 Apr 2014 19:09:17 +0200
Message-ID: <1398359358-11085-14-git-send-email-alex.aring@gmail.com>
References: <1398359358-11085-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1398359358-11085-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch removes a unnecessary state read. The status value is never
evaluate after reading the state.

Also rename the status variable to dvdd, because this variable will be
used later.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 67c01bf..1331152 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -969,13 +969,9 @@ static int at86rf230_irq_polarity(struct at86rf230_local *lp, int pol)
 static int at86rf230_hw_init(struct at86rf230_local *lp)
 {
 	int rc, irq_pol, irq_type;
-	u8 status;
+	u8 dvdd;
 	u8 csma_seed[2];
 
-	rc = at86rf230_read_subreg(lp, SR_TRX_STATUS, &status);
-	if (rc)
-		return rc;
-
 	rc = at86rf230_write_subreg(lp, SR_TRX_CMD, STATE_FORCE_TRX_OFF);
 	if (rc)
 		return rc;
@@ -1015,10 +1011,10 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 	/* Wait the next SLEEP cycle */
 	msleep(100);
 
-	rc = at86rf230_read_subreg(lp, SR_DVDD_OK, &status);
+	rc = at86rf230_read_subreg(lp, SR_DVDD_OK, &dvdd);
 	if (rc)
 		return rc;
-	if (!status) {
+	if (!dvdd) {
 		dev_err(&lp->spi->dev, "DVDD error\n");
 		return -EINVAL;
 	}
-- 
1.9.2


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
