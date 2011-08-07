From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 2/2] dp83640: increase receive time stamp buffer size
Date: Sun,  7 Aug 2011 09:03:04 +0200
Message-ID: <d38d5b44e8894387852a116492cb825159b5842c.1312699694.git.richard.cochran@omicron.at>
References: <cover.1312699693.git.richard.cochran@omicron.at>
Cc: <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>,
	<stable@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1312699693.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1312699693.git.richard.cochran@omicron.at>
References: <cover.1312699693.git.richard.cochran@omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dp83640 buffers receive time stamps from special PHY status frames,
matching them to received PTP packets in a work queue. Because the timeout
for orphaned time stamps is so long and the buffer is so small, the driver
can drop time stamps under moderate PTP traffic.

This commit fixes the issue by decreasing the timeout to (at least) one
timer tick and increasing the buffer size.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
Cc: <stable@kernel.org>
---
 drivers/net/phy/dp83640.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 2cd8dc5..cb6e0b4 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -34,8 +34,7 @@
 #define PAGESEL		0x13
 #define LAYER4		0x02
 #define LAYER2		0x01
-#define MAX_RXTS	4
-#define MAX_TXTS	4
+#define MAX_RXTS	64
 #define N_EXT_TS	1
 #define PSF_PTPVER	2
 #define PSF_EVNT	0x4000
@@ -218,7 +217,7 @@ static void phy2rxts(struct phy_rxts *p, struct rxts *rxts)
 	rxts->seqid = p->seqid;
 	rxts->msgtype = (p->msgtype >> 12) & 0xf;
 	rxts->hash = p->msgtype & 0x0fff;
-	rxts->tmo = jiffies + HZ;
+	rxts->tmo = jiffies + 2;
 }
 
 static u64 phy2txts(struct phy_txts *p)
-- 
1.7.0.4
