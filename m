From: =?UTF-8?q?Stefan=20Br=C3=BCns?= <stefan.bruens-vA1bhqPz9FBZXbeN9DUtxg@public.gmane.org>
Subject: [PATCH v3 2/2] sierra_net: Skip validating irrelevant fields for IDLE LSIs
Date: Wed, 8 Feb 2017 02:46:33 +0100
Message-ID: <726527c0cdc54849a8f82287472faac8@rwthex-w2-b.rwth-ad.de>
References: <20170208014633.15438-1-stefan.bruens@rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        =?UTF-8?q?Stefan=20Br=C3=BCns?= <stefan.bruens-vA1bhqPz9FBZXbeN9DUtxg@public.gmane.org>
To: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170208014633.15438-1-stefan.bruens-vA1bhqPz9FBZXbeN9DUtxg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When the context is deactivated, the link_type is set to 0xff, which
triggers a warning message, and results in a wrong link status, as
the LSI is ignored.

Signed-off-by: Stefan Brüns <stefan.bruens-vA1bhqPz9FBZXbeN9DUtxg@public.gmane.org>
---
 drivers/net/usb/sierra_net.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index 6300a4454ae5..0b5a84c9022c 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -385,6 +385,13 @@ static int sierra_net_parse_lsi(struct usbnet *dev, char *data, int datalen)
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
@@ -418,13 +425,6 @@ static int sierra_net_parse_lsi(struct usbnet *dev, char *data, int datalen)
 		return 0;
 	}
 
-	/* Validate the session state */
-	if (lsi->session_state == SIERRA_NET_SESSION_IDLE) {
-		netdev_err(dev->net, "Session idle, 0x%02x\n",
-			lsi->session_state);
-		return 0;
-	}
