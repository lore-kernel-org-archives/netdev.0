From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH v4 3/3] can: kvaser_usb: Use can-dev unregistration mechanism
Date: Sat, 14 Mar 2015 09:11:47 -0400
Message-ID: <20150314131147.GC20796@linux>
References: <20150226152011.GA6075@linux>
 <20150314130249.GA20796@linux>
 <20150314130952.GB20796@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Andri Yngvason <andri.yngvason@marel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150314130952.GB20796@linux>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ahmed S. Darwish <ahmed.darwish@valeo.com>

Use can-dev's unregister_candev() instead of directly calling
networking unregister_netdev(). While both are functionally
equivalent, unregister_candev() might do extra stuff in the
future than just calling networking layer unregistration code.

Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
---
 drivers/net/can/usb/kvaser_usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 60eadf5..d44fb1e 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -1866,7 +1866,7 @@ static void kvaser_usb_remove_interfaces(struct kvaser_usb *dev)
 		if (!dev->nets[i])
 			continue;
 
-		unregister_netdev(dev->nets[i]->netdev);
+		unregister_candev(dev->nets[i]->netdev);
 	}
 
 	kvaser_usb_unlink_all_urbs(dev);
-- 
1.9.1
