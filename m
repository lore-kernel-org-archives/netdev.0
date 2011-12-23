From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] usb: pegasus: cleanup a couple conditions
Date: Fri, 23 Dec 2011 13:44:36 +0300
Message-ID: <20111223104436.GA8592@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Petko Manolov <petkan@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:45046 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756551Ab1LWKo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 05:44:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We recently made loopback a bool type instead of an int, so the bitwise
AND is redundent.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 908b427..5d99b8c 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -517,7 +517,7 @@ static inline int reset_mac(pegasus_t *pegasus)
 	for (i = 0; i < REG_TIMEOUT; i++) {
 		get_registers(pegasus, EthCtrl1, 1, &data);
 		if (~data & 0x08) {
-			if (loopback & 1)
+			if (loopback)
 				break;
 			if (mii_mode && (pegasus->features & HAS_HOME_PNA))
 				set_register(pegasus, Gpio1, 0x34);
@@ -561,7 +561,7 @@ static int enable_net_traffic(struct net_device *dev, struct usb_device *usb)
 		data[1] |= 0x10;	/* set 100 Mbps */
 	if (mii_mode)
 		data[1] = 0;
-	data[2] = (loopback & 1) ? 0x09 : 0x01;
+	data[2] = loopback ? 0x09 : 0x01;
 
 	memcpy(pegasus->eth_regs, data, sizeof(data));
 	ret = set_registers(pegasus, EthCtrl0, 3, data);
