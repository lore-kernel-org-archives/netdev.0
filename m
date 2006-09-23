From: Joerg Roedel <joro-lkml@zlug.org>
Subject: [PATCH 02/03] net/bridge: add support for EtherIP devices
Date: Sat, 23 Sep 2006 14:16:29 +0200
Message-ID: <20060923121629.GC32284@zlug.org>
References: <20060923120704.GA32284@zlug.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="w7PDEPdKQumQfZlR"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport-c10.fh-zwickau.de ([141.32.72.200]:48006 "EHLO
	ironport-c10.fh-zwickau.de") by vger.kernel.org with ESMTP
	id S1750819AbWIWMQb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 08:16:31 -0400
To: Patrick McHardy <kaber@trash.net>, davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20060923120704.GA32284@zlug.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--w7PDEPdKQumQfZlR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This patch changes the device check in the bridge code to allow EtherIP
devices to be added.

Signed-off-by: Joerg Roedel <joro-lkml@zlug.org>

--w7PDEPdKQumQfZlR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=patch_etherip_bridge

diff -uprN -X linux-2.6.18-vanilla/Documentation/dontdiff linux-2.6.18-vanilla/net/bridge/br_if.c linux-2.6.18/net/bridge/br_if.c
--- linux-2.6.18-vanilla/net/bridge/br_if.c	2006-09-20 05:42:06.000000000 +0200
+++ linux-2.6.18/net/bridge/br_if.c	2006-09-20 23:03:26.000000000 +0200
@@ -407,7 +407,8 @@ int br_add_if(struct net_bridge *br, str
 	struct net_bridge_port *p;
 	int err = 0;
 
-	if (dev->flags & IFF_LOOPBACK || dev->type != ARPHRD_ETHER)
+	if (dev->flags & IFF_LOOPBACK ||
+	    dev->type != ARPHRD_ETHER && dev->type != ARPHRD_ETHERIP)
 		return -EINVAL;
 
 	if (dev->hard_start_xmit == br_dev_xmit)

--w7PDEPdKQumQfZlR--
