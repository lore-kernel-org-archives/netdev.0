From: Bernard Lee <leewk123@hkbn.net>
Subject: [PATCH 2.6.18] 8139too: force media setting cleanup
Date: Sat, 30 Sep 2006 19:11:19 +0800
Message-ID: <20060930111119.GG9175@lfs5p1.leewkb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Bernard Lee <leewkb@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctimail.com ([203.186.94.58]:53430 "EHLO smtpo.ctimail.com")
	by vger.kernel.org with ESMTP id S1750820AbWI3LKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2006 07:10:13 -0400
To: Jeff Garzik <jeff@garzik.org>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernard Lee <leewkb@yahoo.com>

Setting bit 4 & 5 alone in 8139too module media option does not really
force 100Mbps full-duplex mode. When media option bit 0-3 is cleared,
8139too module does not force media setting. Therefore, bit 0-3 requires
to be set for bit 4 & 5 to take effect. The hidden bit 0-3 setting is
not stated in module description.

It can be fixed by changing rtl8139_private structure default_port
bitfield from 4-bit to 6-bit.

Besides, module media bit 9 is a duplicate of bit 4 (full-duplex). It
is suggested that bit 9 is freed. A remark is added to module
description that bit 0 can be used to force setting. It helps to clarify
10Mbps half-duplex mode.

Signed-off-by: Bernard Lee <leewkb@yahoo.com>
---

 8139too.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

--- linux-2.6.18/drivers/net/8139too.c	2006-09-20 11:42:06.000000000 +0800
+++ linux-2.6.18-fixed/drivers/net/8139too.c	2006-09-30 16:30:32.000000000 +0800
@@ -588,3 +588,3 @@ struct rtl8139_private {
 	unsigned int watchdog_fired : 1;
-	unsigned int default_port : 4;	/* Last dev->if_port value. */
+	unsigned int default_port : 6;	/* Last dev->if_port value. */
 	unsigned int have_thread : 1;
@@ -614,3 +614,3 @@ MODULE_PARM_DESC (debug, "8139too bitmap
 MODULE_PARM_DESC (multicast_filter_limit, "8139too maximum number of filtered multicast addresses");
-MODULE_PARM_DESC (media, "8139too: Bits 4+9: force full duplex, bit 5: 100Mbps");
+MODULE_PARM_DESC (media, "8139too: bit 0: force setting, bit 4: full duplex, bit 5: 100Mbps");
 MODULE_PARM_DESC (full_duplex, "8139too: Force full duplex for board(s) (1)");
@@ -1071,4 +1071,4 @@ static int __devinit rtl8139_init_one (s
 	if (option > 0) {
-		tp->mii.full_duplex = (option & 0x210) ? 1 : 0;
-		tp->default_port = option & 0xFF;
+		tp->mii.full_duplex = (option & 0x10) ? 1 : 0;
+		tp->default_port = option & 0x3F;
 		if (tp->default_port)
