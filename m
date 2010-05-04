From: Mattias Walstrom <mattias@vmlinux.org>
Subject: [PATCH] FEC: Fix kernel panic in fec_set_mac_address.
Date: Tue, 04 May 2010 16:16:30 +0200
Message-ID: <4BE02C3E.2000705@vmlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail13.aspcenter.se ([194.29.119.16]:1410 "EHLO
	mail13.aspcenter.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759909Ab0EDObf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 10:31:35 -0400
Received: from [192.168.131.142] by rd.westermo.se (MDaemon PRO v10.1.2)
	with ESMTP id 50-md50000011854.msg
	for <netdev@vger.kernel.org>; Tue, 04 May 2010 16:16:31 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix memory corruption that sometimes result in kernel panic.

Signed-off-by: Mattias Walstr=F6m <mattias@vmlinux.org>

fec.c |    2 +-
1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 9f98c1c..9b4e8f7 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1653,7 +1653,7 @@ fec_set_mac_address(struct net_device *dev, void =
*p)
 		(dev->dev_addr[1] << 16) | (dev->dev_addr[0] << 24),
 		fep->hwp + FEC_ADDR_LOW);
 	writel((dev->dev_addr[5] << 16) | (dev->dev_addr[4] << 24),
-		fep + FEC_ADDR_HIGH);
+		fep->hwp + FEC_ADDR_HIGH);
 	return 0;
 }
=20



