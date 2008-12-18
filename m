From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: [patch]startup race in hso driver
Date: Thu, 18 Dec 2008 14:57:35 +0100
Message-ID: <200812181457.36340.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org, "Greg Kroah-Hartman" <gregkh-l3A5Bk7waGM@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The flag marking a device running must be set before the URBs for
recption are submitted or they may complete too early and fail to resubmit.

Signed-off-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>

	Regards
		Oliver

---

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 8e90891..cc75c8b 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -658,10 +658,9 @@ static int hso_net_open(struct net_device *net)
 	odev->rx_buf_missing = sizeof(struct iphdr);
 	spin_unlock_irqrestore(&odev->net_lock, flags);
 
-	hso_start_net_device(odev->parent);
