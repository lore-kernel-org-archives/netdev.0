From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net v2 1/2] at86rf230: remove check if
	AVDD settled
Date: Mon, 14 Apr 2014 18:48:01 +0200
Message-ID: <1397494082-9394-2-git-send-email-alex.aring@gmail.com>
References: <1397494082-9394-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1397494082-9394-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

The AVDD regulator is only enabled when the RF section is active TX_ON
(PLL_ON) state. Since commit 7dcbd22a97eb0689e6c583ad630ae0e7341e34c1
("ieee802154: ensure that first RF212 state comes from TRX_OFF").
We are in TRX_OFF state at the time at86rf230_hw_init is run.

Note that this test would only fail in case of a severe hardware
malfunction (faulty/shorted power supply, etc.) so it wasn't all that
useful in the first place.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reviewed-by: Werner Almesberger <werner-SEdMjqphH88wryQfseakQg@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 430bb0d..e102eef 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -1025,14 +1025,6 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 		return -EINVAL;
 	}
 
-	rc = at86rf230_read_subreg(lp, SR_AVDD_OK, &status);
-	if (rc)
-		return rc;
-	if (!status) {
-		dev_err(&lp->spi->dev, "AVDD error\n");
-		return -EINVAL;
-	}
-
 	return 0;
 }
 
-- 
1.9.2


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/NeoTech
