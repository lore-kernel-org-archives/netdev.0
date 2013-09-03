From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v2 2/2] atm: he: print MAC via %pM
Date: Tue,  3 Sep 2013 15:13:44 +0300
Message-ID: <1378210424-14781-2-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1378210424-14781-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net,
	inux Net Dev <netdev@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35778 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759909Ab3ICMOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 08:14:04 -0400
In-Reply-To: <1378210424-14781-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/atm/he.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 80f9743..c232dd3 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -1088,15 +1088,8 @@ static int he_start(struct atm_dev *dev)
 	for (i = 0; i < 6; ++i)
 		dev->esi[i] = read_prom_byte(he_dev, MAC_ADDR + i);
 
-	hprintk("%s%s, %x:%x:%x:%x:%x:%x\n",
-				he_dev->prod_id,
-					he_dev->media & 0x40 ? "SM" : "MM",
-						dev->esi[0],
-						dev->esi[1],
-						dev->esi[2],
-						dev->esi[3],
-						dev->esi[4],
-						dev->esi[5]);
+	hprintk("%s%s, %*pM\n", he_dev->prod_id,
+		he_dev->media & 0x40 ? "SM" : "MM", dev->esi);
 	he_dev->atm_dev->link_rate = he_is622(he_dev) ?
 						ATM_OC12_PCR : ATM_OC3_PCR;
 
-- 
1.8.4.rc3
