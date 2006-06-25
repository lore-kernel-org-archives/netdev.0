From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Mon, 26 Jun 2006 00:00:02 +0200
Message-ID: <20060626145515.769648000@postel.suug.ch>
References: <20060626145446.948105000@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:24746 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932355AbWFZO6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 10:58:41 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=vlan_input_dev
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Updating iif to the VLAN device helps keeping routing
namespaces defined in case packets from multiple VLANs
collapse on a single device again.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.git/net/8021q/vlan_dev.c
===================================================================
--- net-2.6.git.orig/net/8021q/vlan_dev.c
+++ net-2.6.git/net/8021q/vlan_dev.c
@@ -156,6 +156,8 @@ int vlan_skb_recv(struct sk_buff *skb, s
 		return -1;
 	}
 
+	/* Make packets look like they have been received on the VLAN device */
+	skb->iif = skb->dev->ifindex;
 	skb->dev->last_rx = jiffies;
 
 	/* Bump the rx counters for the VLAN device. */

--

