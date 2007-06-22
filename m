From: Olof Johansson <olof@lixom.net>
Subject: [PATCH 2/9] pasemi_mac: Clean TX ring in poll
Date: Fri, 22 Jun 2007 15:05:01 -0500
Message-ID: <20070622200501.GC11723@lixom.net>
References: <20070622194720.614405000@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:56556 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751234AbXFVUMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2007 16:12:18 -0400
Content-Disposition: inline; filename=pasemi_mac-clean-tx-in-poll
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clean the TX ring in the poll call, to avoid sitting on mapped buffers
for a long time. NFS doesn't seem to like it much, for example.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -1052,6 +1052,7 @@ static int pasemi_mac_poll(struct net_de
 	int pkts, limit = min(*budget, dev->quota);
 	struct pasemi_mac *mac = netdev_priv(dev);
 
+	pasemi_mac_clean_tx(mac);
 	pkts = pasemi_mac_clean_rx(mac, limit);
 
 	dev->quota -= pkts;

--
