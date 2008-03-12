From: Matteo Croce <technoboy85@gmail.com>
Subject: [PATCH][MIPS][6/6]: AR7 leds
Date: Wed, 12 Mar 2008 02:34:39 +0100
Message-ID: <200803120234.40306.technoboy85@gmail.com>
References: <200803120221.25044.technoboy85@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eugene Konev <ejka@imfi.kspu.ru>, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Anton Vorontsov <avorontsov@ru.mvista.com>
To: linux-mips@linux-mips.org, linux-net@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <200803120221.25044.technoboy85@gmail.com>
Content-Disposition: inline
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Matteo Croce <technoboy85@gmail.com>
Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index c85194f..05191b6 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -1006,23 +1006,10 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 
 	if (phy_id == PHY_MAX_ADDR) {
 		if (external_switch || dumb_switch) {
-			struct fixed_phy_status status = {};
-
-			mdio_bus_id = 0;
-
-			/*
-			 * FIXME: this should be in the platform code!
-			 * Since there is not platform code at all (that is,
-			 * no mainline users of that driver), place it here
-			 * for now.
-			 */
-			phy_id = 0;
-			status.link = 1;
-			status.duplex = 1;
-			status.speed = 100;
-			fixed_phy_add(PHY_POLL, phy_id, &status);
+			mdio_bus_id = 0; /* fixed phys bus */
+			phy_id = pdev->id;
 		} else {
-			printk(KERN_ERR "cpmac: no PHY present\n");
+			dev_err(&pdev->dev, "no PHY present\n");
 			return -ENODEV;
 		}
 	}
