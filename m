From: =?UTF-8?q?Stefan=20Br=C3=BCns?= <stefan.bruens@rwth-aachen.de>
Subject: [PATCH 2/2] sierra_net: Skip validating irrelevant fields for IDLE LSIs
Date: Mon, 6 Feb 2017 21:20:34 +0100
Message-ID: <df81548691714f2fb6b02f14b8e58ed4@rwthex-w2-b.rwth-ad.de>
References: <20170206202034.10962-1-stefan.bruens@rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        =?UTF-8?q?Stefan=20Br=C3=BCns?= <stefan.bruens@rwth-aachen.de>
To: <linux-usb@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170206202034.10962-1-stefan.bruens@rwth-aachen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the context is deactivated, the link_type is set to 0xff, which
triggers a warning message, and results in a wrong link status, as
the LSI is ignored.

Signed-off-by: Stefan Brüns <stefan.bruens@rwth-aachen.de>
---
 drivers/net/usb/sierra_net.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index 8c2a16c28ec1..567c7a0bb30e 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -387,6 +387,13 @@ static int sierra_net_parse_lsi(struct usbnet *dev, char *data, int datalen)
 		return -1;
 	}
 
+	/* Validate the session state */
+	if (lsi->session_state == SIERRA_NET_SESSION_IDLE) {
+		netdev_err(dev->net, "Session idle, 0x%02x\n",
+			   lsi->session_state);
+		return 0;
+	}
+
 	/* Validate the protocol  - only support UMTS for now */
 	if (lsi->protocol == SIERRA_NET_PROTOCOL_UMTS) {
 		struct lsi_umts_single *single = (struct lsi_umts_single *)lsi;
@@ -420,13 +427,6 @@ static int sierra_net_parse_lsi(struct usbnet *dev, char *data, int datalen)
 		return 0;
 	}
 
-	/* Validate the session state */
-	if (lsi->session_state == SIERRA_NET_SESSION_IDLE) {
-		netdev_err(dev->net, "Session idle, 0x%02x\n",
-			lsi->session_state);
-		return 0;
-	}
-
 	/* Set link_sense true */
 	return 1;
 }
-- 
2.11.0
