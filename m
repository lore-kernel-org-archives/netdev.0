From: Richard Stearn <richard@rns-stearn.demon.co.uk>
Subject: [PATCH 4/6]NET:AX25:ROSE Fixes to rose_header
Date: Sat, 16 Jul 2016 10:44:59 +0100
Message-ID: <201607160944.u6G9ixOJ015059@ux4.g1sog>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: [PATCH 4/6]NET:AX25:ROSE Fixes to rose_header
Adds comments on the header fields. Removes address copy.

Added comments detailing the ROSE header fields being built.
Removes an address copy that is irrelevant for this ROSE header as there are no
addresses in the header and the copy corrupts the data field of the packet.

Signed-off-by: Richard Stearn <richard@rns-stearn.demon.co.uk>
---
 net/rose/rose_dev.c |   13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

There are no hardware address fields in the packet. The memcpy corrupts the
packet data.

diff --git a/net/rose/rose_dev.c b/net/rose/rose_dev.c
index 369ca81..44eca10 100644
--- a/net/rose/rose_dev.c
+++ b/net/rose/rose_dev.c
@@ -41,14 +41,11 @@ static int rose_header(struct sk_buff *skb, struct net_device *dev,
 {
 	unsigned char *buff = skb_push(skb, ROSE_MIN_LEN + 2);
 
-	if (daddr)
-		memcpy(buff + 7, daddr, dev->addr_len);
-
-	*buff++ = ROSE_GFI | ROSE_Q_BIT;
-	*buff++ = 0x00;
-	*buff++ = ROSE_DATA;
-	*buff++ = 0x7F;
-	*buff++ = AX25_P_IP;
+	*buff++ = ROSE_GFI | ROSE_Q_BIT; /* GFI and upper 4 bits of the LCI */
+	*buff++ = 0x00;			 /* lower 8 bits of the LCI */
+	*buff++ = ROSE_DATA;		 /* P(S), M, P(R) and data flag */
+	*buff++ = 0x7F;			 /* magic marker */
+	*buff++ = AX25_P_IP;		 /* this is an IP packet */
 
 	if (daddr != NULL)
 		return 37;
