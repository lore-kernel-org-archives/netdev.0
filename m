From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 07/12] usb/rtl8150: check given MAC address, if invalid return -EADDRNOTAVAIL
Date: Fri, 24 Feb 2012 17:01:17 +0100
Message-ID: <1330099282-4588-8-git-send-email-danny.kukawka@bisect.de>
References: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Petko Manolov <petkan@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wp188.webpack.hosteurope.de ([80.237.132.195]:53215 "EHLO
	wp188.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757678Ab2BXQBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 11:01:37 -0500
In-Reply-To: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check if given address is valid in .ndo_set_mac_address/
rtl8150_set_mac_address(), if invalid return -EADDRNOTAVAIL as
eth_mac_addr() already does if is_valid_ether_addr() fails.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/usb/rtl8150.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 6dda2fe..aa539be 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -299,6 +299,9 @@ static int rtl8150_set_mac_address(struct net_device *netdev, void *p)
 	if (netif_running(netdev))
 		return -EBUSY;
 
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 	dbg("%s: Setting MAC address to %pM\n", netdev->name, netdev->dev_addr);
 	/* Set the IDR registers. */
-- 
1.7.8.3
