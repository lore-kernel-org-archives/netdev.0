From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] dmascc: fix incomplete conversion to network_device_ops
Date: Sun, 29 Mar 2009 05:42:24 +0400
Message-ID: <20090329014224.GA23405@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:7401 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754348AbZC2Bmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 21:42:37 -0400
Received: by fg-out-1718.google.com with SMTP id e12so536482fga.17
        for <netdev@vger.kernel.org>; Sat, 28 Mar 2009 18:42:34 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/hamradio/dmascc.c:587: error: 'struct net_device' has no
member named 'set_mac_address'

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/hamradio/dmascc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index 881bf81..7459b3a 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -445,6 +445,7 @@ static const struct net_device_ops scc_netdev_ops = {
 	.ndo_stop = scc_close,
 	.ndo_start_xmit = scc_send_packet,
 	.ndo_do_ioctl = scc_ioctl,
+	.ndo_set_mac_address = scc_set_mac_address,
 };
 
 static int __init setup_adapter(int card_base, int type, int n)
@@ -584,7 +585,6 @@ static int __init setup_adapter(int card_base, int type, int n)
 		dev->irq = irq;
 		dev->netdev_ops = &scc_netdev_ops;
 		dev->header_ops = &ax25_header_ops;
-		dev->set_mac_address = scc_set_mac_address;
 	}
 	if (register_netdev(info->dev[0])) {
 		printk(KERN_ERR "dmascc: could not register %s\n",
