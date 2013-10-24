From: freddy@asix.com.tw
Subject: [PATCH 1/1] ax88179_178a: Remove AX_MEDIUM_ALWAYS_ONE bit in AX_MEDIUM_STATUS_MODE register to avoid TX throttling
Date: Thu, 24 Oct 2013 14:58:25 +0800
Message-ID: <1382597905-2393-1-git-send-email-freddy@asix.com.tw>
Cc: Freddy Xin <freddy@asix.com.tw>
To: davem@davemloft.net, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	allan@asix.com.tw, louis@asix.com.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Freddy Xin <freddy@asix.com.tw>

Remove AX_MEDIUM_ALWAYS_ONE in AX_MEDIUM_STATUS_MODE register.
Setting this bit may cause TX throttling in Half-Duplex mode.

Signed-off-by: Freddy Xin <freddy@asix.com.tw>
---
 drivers/net/usb/ax88179_178a.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index 846cc19..8e8d0fc 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -78,7 +78,6 @@
 #define AX_MEDIUM_STATUS_MODE			0x22
 	#define AX_MEDIUM_GIGAMODE	0x01
 	#define AX_MEDIUM_FULL_DUPLEX	0x02
-	#define AX_MEDIUM_ALWAYS_ONE	0x04
 	#define AX_MEDIUM_EN_125MHZ	0x08
 	#define AX_MEDIUM_RXFLOW_CTRLEN	0x10
 	#define AX_MEDIUM_TXFLOW_CTRLEN	0x20
@@ -1065,8 +1064,8 @@ static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	/* Configure default medium type => giga */
 	*tmp16 = AX_MEDIUM_RECEIVE_EN | AX_MEDIUM_TXFLOW_CTRLEN |
-		 AX_MEDIUM_RXFLOW_CTRLEN | AX_MEDIUM_ALWAYS_ONE |
-		 AX_MEDIUM_FULL_DUPLEX | AX_MEDIUM_GIGAMODE;
+		 AX_MEDIUM_RXFLOW_CTRLEN | AX_MEDIUM_FULL_DUPLEX |
+		 AX_MEDIUM_GIGAMODE;
 	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_MEDIUM_STATUS_MODE,
 			  2, 2, tmp16);
 
@@ -1225,7 +1224,7 @@ static int ax88179_link_reset(struct usbnet *dev)
 	}
 
 	mode = AX_MEDIUM_RECEIVE_EN | AX_MEDIUM_TXFLOW_CTRLEN |
-	       AX_MEDIUM_RXFLOW_CTRLEN | AX_MEDIUM_ALWAYS_ONE;
+	       AX_MEDIUM_RXFLOW_CTRLEN;
 
 	ax88179_read_cmd(dev, AX_ACCESS_MAC, PHYSICAL_LINK_STATUS,
 			 1, 1, &link_sts);
@@ -1339,8 +1338,8 @@ static int ax88179_reset(struct usbnet *dev)
 
 	/* Configure default medium type => giga */
 	*tmp16 = AX_MEDIUM_RECEIVE_EN | AX_MEDIUM_TXFLOW_CTRLEN |
-		 AX_MEDIUM_RXFLOW_CTRLEN | AX_MEDIUM_ALWAYS_ONE |
-		 AX_MEDIUM_FULL_DUPLEX | AX_MEDIUM_GIGAMODE;
+		 AX_MEDIUM_RXFLOW_CTRLEN | AX_MEDIUM_FULL_DUPLEX |
+		 AX_MEDIUM_GIGAMODE;
 	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_MEDIUM_STATUS_MODE,
 			  2, 2, tmp16);
 
-- 
1.7.10.4
