From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 03/21] ARCNET: capmode: fix transfer length
Date: Fri, 24 Apr 2015 19:20:37 +0200
Message-ID: <1429896055-31680-4-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The commit <52edc17f94f7bd4d9> ("bugfixes and new hardware support for
arcnet driver") adds fixes for the packet length calculations in
arc-rawmode. As the capmode protocol is derived from the arc-rawmode
code, the capmode also needs the fixes.

rx():
- Fixed error in received packet lengths; 256 byte packets were
  being received as 257 bytes packets.

prepare_tx():
- Fixed error in transmit length calcs; 257 byte packets were being
  transmitted as 260 byte packets.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/capmode.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 42fce91..b6868a2 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -49,7 +49,7 @@ static void rx(struct net_device *dev, int bufnum,
 
 	BUGMSG(D_DURING, "it's a raw(cap) packet (length=%d)\n", length);
 
-	if (length >= MinTU)
+	if (length > MTU)
 		ofs = 512 - length;
 	else
 		ofs = 256 - length;
@@ -156,7 +156,7 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		       length, XMTU);
 		length = XMTU;
 	}
-	if (length > MinTU) {
+	if (length >= MinTU) {
 		hard->offset[0] = 0;
 		hard->offset[1] = ofs = 512 - length;
 	} else if (length > MTU) {
-- 
2.1.4
