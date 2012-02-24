From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 09/11] usb/kaweth: print MAC via printk format specifier
Date: Fri, 24 Feb 2012 14:46:00 +0100
Message-ID: <1330091162-8141-10-git-send-email-danny.kukawka@bisect.de>
References: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, linux-usb@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Print MAC/dev_addr via printk extended format specifier %pM
instead of custom code.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/usb/kaweth.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index d034d9c..df2a2cf 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -1098,13 +1098,7 @@ err_fw:
 	dev_info(&intf->dev, "Statistics collection: %x\n", kaweth->configuration.statistics_mask);
 	dev_info(&intf->dev, "Multicast filter limit: %x\n", kaweth->configuration.max_multicast_filters & ((1 << 15) - 1));
 	dev_info(&intf->dev, "MTU: %d\n", le16_to_cpu(kaweth->configuration.segment_size));
-	dev_info(&intf->dev, "Read MAC address %2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x\n",
-		 (int)kaweth->configuration.hw_addr[0],
-		 (int)kaweth->configuration.hw_addr[1],
-		 (int)kaweth->configuration.hw_addr[2],
-		 (int)kaweth->configuration.hw_addr[3],
-		 (int)kaweth->configuration.hw_addr[4],
-		 (int)kaweth->configuration.hw_addr[5]);
+	dev_info(&intf->dev, "Read MAC address %pM\n", kaweth->configuration.hw_addr);
 
 	if(!memcmp(&kaweth->configuration.hw_addr,
                    &bcast_addr,
-- 
1.7.8.3
