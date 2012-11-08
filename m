From: Ian Coolidge <iancoolidge-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 1/2] usb: gadget: g_ether: fix frame size check for 802.1Q
Date: Wed,  7 Nov 2012 16:39:18 -0800
Message-ID: <1352335159-8049-2-git-send-email-iancoolidge@gmail.com>
References: <1352335159-8049-1-git-send-email-iancoolidge@gmail.com>
Cc: Ian Coolidge <iancoolidge-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1352335159-8049-1-git-send-email-iancoolidge-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Checking skb->len against ETH_FRAME_LEN assumes a 1514
ethernet frame size. With an 802.1Q VLAN header, ethernet
frame length can now be 1518. Validate frame length against that.

Signed-off-by: Ian Coolidge <iancoolidge-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/usb/gadget/u_ether.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/usb/gadget/u_ether.c b/drivers/usb/gadget/u_ether.c
index 6458764..4ec3c0d 100644
--- a/drivers/usb/gadget/u_ether.c
+++ b/drivers/usb/gadget/u_ether.c
@@ -20,6 +20,7 @@
 #include <linux/ctype.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
+#include <linux/if_vlan.h>
 
 #include "u_ether.h"
 
@@ -295,7 +296,7 @@ static void rx_complete(struct usb_ep *ep, struct usb_request *req)
 		while (skb2) {
 			if (status < 0
 					|| ETH_HLEN > skb2->len
-					|| skb2->len > ETH_FRAME_LEN) {
+					|| skb2->len > VLAN_ETH_FRAME_LEN) {
 				dev->net->stats.rx_errors++;
 				dev->net->stats.rx_length_errors++;
 				DBG(dev, "rx length %d\n", skb2->len);
-- 
1.7.6.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
