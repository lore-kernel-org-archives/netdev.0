From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH] net: dsa: Fix Marvell Egress Trailer check
Date: Tue, 22 Sep 2015 11:28:14 +0200
Message-ID: <56011F2E.5080208@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Marvell Egress rx trailer check must be fixed to
correctly detect bad bits in the third byte of the
Eggress trailer as described in the Table 28 of the
88E6060 datasheet.
The current code incorrectly omits to check the third
byte and checks the fourth byte twice.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/tag_trailer.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index e268f9d..d0526a9 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -84,7 +84,7 @@ static int trailer_rcv(struct sk_buff *skb, struct net_device *dev,

 	trailer = skb_tail_pointer(skb) - 4;
 	if (trailer[0] != 0x80 || (trailer[1] & 0xf8) != 0x00 ||
-	    (trailer[3] & 0xef) != 0x00 || trailer[3] != 0x00)
+	    (trailer[2] & 0xef) != 0x00 || trailer[3] != 0x00)
 		goto out_drop;

 	source_port = trailer[1] & 7;
-- 
1.9.1
