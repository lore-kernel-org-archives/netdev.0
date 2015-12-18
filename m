From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] asix: silence log message from oversize packet
Date: Thu, 17 Dec 2015 17:51:16 -0800
Message-ID: <20151217175116.234fa63b@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <ben.hutchings@codethink.co.uk>,
	Ivan Vecera <ivecera@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, linuxbrad@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36717 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964859AbbLRBvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 20:51:09 -0500
Received: by mail-pf0-f172.google.com with SMTP id o64so40274380pfb.3
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 17:51:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since it is possible for an external system to send oversize packets
at anytime, it is best for driver not to print a message and spam
the log (potential external DoS).

Fixes: https://bugzilla.kernel.org/show_bug.cgi?id=109471

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/usb/asix_common.c	2015-10-16 16:05:30.997785598 -0700
+++ b/drivers/net/usb/asix_common.c	2015-12-17 17:50:30.983973764 -0800
@@ -118,7 +118,7 @@ int asix_rx_fixup_internal(struct usbnet
 				return 0;
 			}
 			if (size > dev->net->mtu + ETH_HLEN + VLAN_HLEN) {
-				netdev_err(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
+				netdev_dbg(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
 					   size);
 				return 0;
 			}
