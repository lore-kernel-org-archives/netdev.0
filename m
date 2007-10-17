From: Don Fry <pcnet32@verizon.net>
Subject: [PATCH] pcnet32: fix non-napi packet reception
Date: Wed, 17 Oct 2007 15:59:22 -0700
Message-ID: <1192661962.474.10.camel@Linux.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms044pub.verizon.net ([206.46.252.44]:63859 "EHLO
	vms044pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932510AbXJQXHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 19:07:06 -0400
Received: from [192.168.1.2] ([71.117.241.192])
 by vms044.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JQ2005BRW5Z8SB8@vms044.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 17 Oct 2007 18:06:00 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Recent changes to the driver for the new napi API broke the reception of packets when in
non-napi mode.  The initialization of napi.weight was removed for the non-napi case
leaving the value zero.

Tested NAPI and non-NAPI on x86_64.

Signed-off-by: Don Fry <pcnet32@verizon.net>
---
--- linux-2.6.23-git7/drivers/net/orig.pcnet32.c	2007-10-15 11:19:17.000000000 -0700
+++ linux-2.6.23-git7/drivers/net/pcnet32.c	2007-10-17 15:56:15.000000000 -0700
@@ -1849,6 +1849,9 @@ pcnet32_probe1(unsigned long ioaddr, int
 	lp->mii_if.mdio_read = mdio_read;
 	lp->mii_if.mdio_write = mdio_write;
 
+	/* napi.weight is used in both the napi and non-napi cases */
+	lp->napi.weight = lp->rx_ring_size / 2;
+
 #ifdef CONFIG_PCNET32_NAPI
 	netif_napi_add(dev, &lp->napi, pcnet32_poll, lp->rx_ring_size / 2);
 #endif


