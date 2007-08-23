From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 1/2] E1000: Fix ifdown hang in git-2.6.24
Date: Thu, 23 Aug 2007 14:34:18 +0530
Message-ID: <20070823090418.13099.89298.sendpatchset@localhost.localdomain>
Cc: Krishna Kumar <krkumar2@in.ibm.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:35672 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751050AbXHWJCk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2007 05:02:40 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7N92eFV018803
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 05:02:40 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7N92dtx466992
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 05:02:39 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7N92dH5024325
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 05:02:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Doing napi_disable twice hangs "ifdown" of the device. e1000_down is the
common place to call napi_disable.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 e1000_main.c |    4 ----
 1 files changed, 4 deletions(-)

diff -ruNp org/drivers/net/e1000/e1000_main.c new/drivers/net/e1000/e1000_main.c
--- org/drivers/net/e1000/e1000_main.c	2007-08-23 13:32:16.000000000 +0530
+++ new/drivers/net/e1000/e1000_main.c	2007-08-23 13:32:34.000000000 +0530
@@ -1477,10 +1477,6 @@ e1000_close(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-#ifdef CONFIG_E1000_NAPI
-	napi_disable(&adapter->napi);
-#endif
-
 	WARN_ON(test_bit(__E1000_RESETTING, &adapter->flags));
 	e1000_down(adapter);
 	e1000_power_down_phy(adapter);
