From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] NET: hamradio: Fix IP over bpq encapsulation.
Date: Sat, 4 Jul 2015 11:22:30 +0200
Message-ID: <20150704092230.GN5255@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org, stable@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:53579 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755963AbbGEIu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2015 04:50:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 1d5da757da860a6916adbf68b09e868062b4b3b8 (ax25: Stop using magic
neighbour cache operations.) any attempt to transmit IP packets over
a bpqether device will result in a message like "Dead loop on virtual
device bpq0, fix it urgently!"

Fix suggested by Eric W. Biederman <ebiederm@xmission.com>.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
Cc: <stable@vger.kernel.org> # 4.1
---
 drivers/net/hamradio/bpqether.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 63ff08a..5b54b18 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -483,6 +483,7 @@ static void bpq_setup(struct net_device *dev)
 	memcpy(dev->dev_addr,  &ax25_defaddr, AX25_ADDR_LEN);
 
 	dev->flags      = 0;
+	dev->features	= NETIF_F_LLTX;	/* Allow recursion */
 
 #if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 	dev->header_ops      = &ax25_header_ops;
