From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: [PATCH net-next] rndis_host: Set valid random MAC on buggy devices
Date: Thu, 14 Jul 2016 10:23:03 +0200
Message-ID: <1468484583-12620-1-git-send-email-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kristian Evensen <kristian.evensen@gmail.com>
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33963 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbcGNIXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 04:23:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Kristian Evensen <kristian.evensen@gmail.com>

Some devices of the same type all export the same, random MAC address. =
This
behavior has been seen on the ZTE MF910, MF823 and MF831, and there are
probably more devices out there. Fix this by generating a valid random =
MAC
address if we read a random MAC from device.

Also, changed the memcpy() to ether_addr_copy(), as pointed out by
checkpatch.

Suggested-by: Bj=C3=B8rn Mork <bjorn@mork.no>
Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>
---
 drivers/net/usb/rndis_host.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.=
c
index 524a47a281..4f4f71b 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -428,7 +428,11 @@ generic_rndis_bind(struct usbnet *dev, struct usb_=
interface *intf, int flags)
 		dev_err(&intf->dev, "rndis get ethaddr, %d\n", retval);
 		goto halt_fail_and_release;
 	}
-	memcpy(net->dev_addr, bp, ETH_ALEN);
+
+	if (bp[0] & 0x02)
+		eth_hw_addr_random(net);
+	else
+		ether_addr_copy(net->dev_addr, bp);
=20
 	/* set a nonzero filter to enable data transfers */
 	memset(u.set, 0, sizeof *u.set);
--=20
2.5.0
