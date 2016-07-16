From: Richard Stearn <richard@rns-stearn.demon.co.uk>
Subject: [PATCH 6/6]NET:AX25:ROSE Removes a conditional return and
 corrects the return value.
Date: Sat, 16 Jul 2016 10:46:59 +0100
Message-ID: <201607160946.u6G9kxnD015432@ux4.g1sog>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: [PATCH 6/6]NET:AX25:ROSE Removes a conditional return and corrects the return value.
Removes a conditional return and corrects the return value.

The ROSE header is always finished (as it is not dependant on daddr) so
the test for daddr is not required.

Return value fixed as positive added header length.

Signed-off-by: Richard Stearn <richard@rns-stearn.demon.co.uk>
---
 net/rose/rose_dev.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/rose/rose_dev.c b/net/rose/rose_dev.c
index 44eca10..dc38608 100644
--- a/net/rose/rose_dev.c
+++ b/net/rose/rose_dev.c
@@ -47,10 +47,7 @@ static int rose_header(struct sk_buff *skb, struct net_device *dev,
 	*buff++ = 0x7F;				/* magic marker */
 	*buff++ = AX25_P_IP;			/* this is an IP packet */
 
-	if (daddr != NULL)
-		return 37;
-
-	return -37;
+	return ROSE_MIN_LEN + 2;	/* always creates a finished header */
 }
 
 static int rose_set_mac_address(struct net_device *dev, void *addr)
