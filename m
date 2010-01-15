From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] drivers: set_sg should not be set for !F_SG drivers
Date: Fri, 15 Jan 2010 11:02:29 +0530
Message-ID: <20100115053229.31542.51066.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([122.248.162.2]:47649 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980Ab0AOFcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 00:32:33 -0500
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp02.in.ibm.com (8.14.3/8.13.1) with ESMTP id o0F5WVir030209
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 11:02:31 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0F5WUvx1081400
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 11:02:30 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0F5WUWZ017598
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 16:32:30 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

set_sg should not be set to ethtool_op_set_sg() by drivers
that do not support SG. It is also not required for these
drivers to set get_sg since it is handled by the generic
ethtool_op_get_sg.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/net/8139cp.c |    1 -
 drivers/net/r8169.c  |    1 -
 drivers/net/veth.c   |    2 --
 3 files changed, 4 deletions(-)

diff -ruNp org/drivers/net/8139cp.c new/drivers/net/8139cp.c
--- org/drivers/net/8139cp.c	2009-12-29 18:32:57.000000000 +0530
+++ new/drivers/net/8139cp.c	2009-12-29 18:34:29.000000000 +0530
@@ -1570,7 +1570,6 @@ static const struct ethtool_ops cp_ethto
 	.get_rx_csum		= cp_get_rx_csum,
 	.set_rx_csum		= cp_set_rx_csum,
 	.set_tx_csum		= ethtool_op_set_tx_csum, /* local! */
-	.set_sg			= ethtool_op_set_sg,
 	.set_tso		= ethtool_op_set_tso,
 	.get_regs		= cp_get_regs,
 	.get_wol		= cp_get_wol,
diff -ruNp org/drivers/net/r8169.c new/drivers/net/r8169.c
--- org/drivers/net/r8169.c	2009-12-29 18:32:57.000000000 +0530
+++ new/drivers/net/r8169.c	2009-12-29 18:34:32.000000000 +0530
@@ -1253,7 +1253,6 @@ static const struct ethtool_ops rtl8169_
 	.get_rx_csum		= rtl8169_get_rx_csum,
 	.set_rx_csum		= rtl8169_set_rx_csum,
 	.set_tx_csum		= ethtool_op_set_tx_csum,
-	.set_sg			= ethtool_op_set_sg,
 	.set_tso		= ethtool_op_set_tso,
 	.get_regs		= rtl8169_get_regs,
 	.get_wol		= rtl8169_get_wol,
diff -ruNp org/drivers/net/veth.c new/drivers/net/veth.c
--- org/drivers/net/veth.c	2009-12-29 18:32:57.000000000 +0530
+++ new/drivers/net/veth.c	2009-12-29 18:34:38.000000000 +0530
@@ -137,8 +137,6 @@ static const struct ethtool_ops veth_eth
 	.set_rx_csum		= veth_set_rx_csum,
 	.get_tx_csum		= veth_get_tx_csum,
 	.set_tx_csum		= veth_set_tx_csum,
-	.get_sg			= ethtool_op_get_sg,
-	.set_sg			= ethtool_op_set_sg,
 	.get_strings		= veth_get_strings,
 	.get_sset_count		= veth_get_sset_count,
 	.get_ethtool_stats	= veth_get_ethtool_stats,
