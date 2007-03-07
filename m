From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/4] myri10ge: fix error checking and return value in myri10ge_allocate_rings
Date: Wed, 07 Mar 2007 19:59:52 +0100
Message-ID: <45EF0BA8.3080903@myri.com>
References: <45EF0B6C.9070005@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1910 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S2992480AbXCGTCA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 14:02:00 -0500
In-Reply-To: <45EF0B6C.9070005@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a missing error check in myri10ge_allocate_rings() and set status
to -ENOMEM before all actual allocations so that the error path returns
what it should.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-03-07 08:49:08.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-03-07 08:51:07.000000000 +0100
@@ -1456,6 +1456,8 @@
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_RING_SIZE, &cmd, 0);
 	tx_ring_size = cmd.data0;
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_RX_RING_SIZE, &cmd, 0);
+	if (status != 0)
+		return status;
 	rx_ring_size = cmd.data0;
 
 	tx_ring_entries = tx_ring_size / sizeof(struct mcp_kreq_ether_send);
@@ -1463,6 +1465,8 @@
 	mgp->tx.mask = tx_ring_entries - 1;
 	mgp->rx_small.mask = mgp->rx_big.mask = rx_ring_entries - 1;
 
+	status = -ENOMEM;
+
 	/* allocate the host shadow rings */
 
 	bytes = 8 + (MYRI10GE_MAX_SEND_DESC_TSO + 4)


