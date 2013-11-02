From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next 01/13] net: Check skb for NULL in dev_kfree_skb_irq
Date: Sat,  2 Nov 2013 19:17:42 +0530
Message-ID: <1383400074-30555-2-git-send-email-govindarajulu90@gmail.com>
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

Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0054c8c..63bd44d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2146,7 +2146,7 @@ EXPORT_SYMBOL(__netif_schedule);
 
 void dev_kfree_skb_irq(struct sk_buff *skb)
 {
-	if (atomic_dec_and_test(&skb->users)) {
+	if (skb && atomic_dec_and_test(&skb->users)) {
 		struct softnet_data *sd;
 		unsigned long flags;
 
-- 
1.8.4.2
