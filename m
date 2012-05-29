From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] asix: allow full size 8021Q frames to be received
Date: Tue, 29 May 2012 10:31:41 +0200
Message-ID: <1338280301.4120.0.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Trond Wuellner <trond@chromium.org>,
	Grant Grundler <grundler@chromium.org>,
	Paul Stewart <pstew@chromium.org>,
	Allan Chou <allan@asix.com.tw>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:41048 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279Ab2E2Ibq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 04:31:46 -0400
Received: by eeit10 with SMTP id t10so964362eei.19
        for <netdev@vger.kernel.org>; Tue, 29 May 2012 01:31:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

asix driver drops 8021Q full size frames because it doesn't take into
account VLAN header size.

Tested on AX88772 adapter.

Signed-off-by: Eric Dumazet <edumazet@google.com>
CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
CC: Allan Chou <allan@asix.com.tw>
CC: Trond Wuellner <trond@chromium.org>
CC: Grant Grundler <grundler@chromium.org>
CC: Paul Stewart <pstew@chromium.org>
---
drivers/net/usb/asix.c |    3 ++-
1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 71e2b05..3ae80ec 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -35,6 +35,7 @@
 #include <linux/crc32.h>
 #include <linux/usb/usbnet.h>
 #include <linux/slab.h>
+#include <linux/if_vlan.h>
 
 #define DRIVER_VERSION "22-Dec-2011"
 #define DRIVER_NAME "asix"
@@ -321,7 +322,7 @@ static int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			return 0;
 		}
 
-		if ((size > dev->net->mtu + ETH_HLEN) ||
+		if ((size > dev->net->mtu + ETH_HLEN + VLAN_HLEN) ||
 		    (size + offset > skb->len)) {
 			netdev_err(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
 				   size);
