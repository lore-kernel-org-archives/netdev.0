From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next 11/13] driver: usb: remove unnecessary NULL check before dev_kfree_skb_any
Date: Sat,  2 Nov 2013 19:17:52 +0530
Message-ID: <1383400074-30555-12-git-send-email-govindarajulu90@gmail.com>
References: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Cc: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
To: davem@davemloft.net, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	schwidefsky@de.ibm.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	IvDoorn@gmail.com, sbhatewara@vmware.com, samuel@sortiz.org,
	chas@cmf.nrl.navy.mil, roland@kernel.org, isdn@linux-pingi.de,
	jcliburn@gmail.com, benve@cisco.com, ssujith@cisco.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shahed.shaikh@qlogic.com, joe@perches.com, apw@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dev_kfree_skb_any is protected from NULL. No need to check for NULL
while calling this function.

Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
---
 drivers/usb/gadget/u_ether.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/usb/gadget/u_ether.c b/drivers/usb/gadget/u_ether.c
index 2aae0d6..3b61ac6 100644
--- a/drivers/usb/gadget/u_ether.c
+++ b/drivers/usb/gadget/u_ether.c
@@ -251,8 +251,7 @@ enomem:
 		defer_kevent(dev, WORK_RX_MEMORY);
 	if (retval) {
 		DBG(dev, "rx submit --> %d\n", retval);
-		if (skb)
-			dev_kfree_skb_any(skb);
+		dev_kfree_skb_any(skb);
 		spin_lock_irqsave(&dev->req_lock, flags);
 		list_add(&req->list, &dev->rx_reqs);
 		spin_unlock_irqrestore(&dev->req_lock, flags);
@@ -339,8 +338,7 @@ quiesce:
 		break;
 	}
 
-	if (skb)
-		dev_kfree_skb_any(skb);
+	dev_kfree_skb_any(skb);
 	if (!netif_running(dev->net)) {
 clean:
 		spin_lock(&dev->req_lock);
-- 
1.8.4.2
