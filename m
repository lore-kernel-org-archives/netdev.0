From: David Brownell <david-b@pacbell.net>
Subject: Fwd: [PATCH 01/22] usb gadget: fix ethernet link reports to ethtool
Date: Fri, 17 Apr 2009 12:45:14 -0700
Message-ID: <200904171245.14785.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Network development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp128.sbc.mail.sp1.yahoo.com ([69.147.65.187]:26618 "HELO
	smtp128.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752470AbZDQTwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 15:52:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hmm, I should probably try to cc netdev on some of these
patches.  They're fairly infrequent any more, but...

Likewise, it'd be good to get cc'd from netdev on patches
that affect drivers/usb/gadget ... I was very recently
surprised to see a "phonet" driver just appear.

- Dave


----------  Forwarded Message  ----------

Subject: [PATCH 01/22] usb gadget: fix ethernet link reports to ethtool
Date: Friday 17 April 2009
From: "Greg Kroah-Hartman" <gregkh@suse.de>
To: linux-usb@vger.kernel.org

From: Jonathan McDowell <noodles@earth.li>

The g_ether USB gadget driver currently decides whether or not there's a
link to report back for eth_get_link based on if the USB link speed is
set. The USB gadget speed is however often set even before the device is
enumerated. It seems more sensible to only report a "link" if we're
actually connected to a host that wants to talk to us. The patch below
does this for me - tested with the PXA27x UDC driver.

Signed-off-by: Jonathan McDowell <noodles@earth.li>
Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
Cc: stable <stable@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
---
 drivers/usb/gadget/u_ether.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/drivers/usb/gadget/u_ether.c b/drivers/usb/gadget/u_ether.c
index 96d65ca..4007770 100644
--- a/drivers/usb/gadget/u_ether.c
+++ b/drivers/usb/gadget/u_ether.c
@@ -175,12 +175,6 @@ static void eth_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *p)
 	strlcpy(p->bus_info, dev_name(&dev->gadget->dev), sizeof p->bus_info);
 }
 
-static u32 eth_get_link(struct net_device *net)
-{
-	struct eth_dev	*dev = netdev_priv(net);
-	return dev->gadget->speed != USB_SPEED_UNKNOWN;
-}
-
 /* REVISIT can also support:
  *   - WOL (by tracking suspends and issuing remote wakeup)
  *   - msglevel (implies updated messaging)
@@ -189,7 +183,7 @@ static u32 eth_get_link(struct net_device *net)
 
 static struct ethtool_ops ops = {
 	.get_drvinfo = eth_get_drvinfo,
-	.get_link = eth_get_link
+	.get_link = ethtool_op_get_link,
 };
 
 static void defer_kevent(struct eth_dev *dev, int flag)
-- 
1.6.2


-------------------------------------------------------
