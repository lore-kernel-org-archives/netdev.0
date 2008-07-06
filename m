From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 06/06]: tehuti: don't truncate VLAN TCI with VLAN stripping
Date: Mon, 07 Jul 2008 00:48:21 +0200
Message-ID: <48714BB5.2010107@trash.net>
References: <487148E0.5040407@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030906030407020802060200"
Cc: Jeff Garzik <jeff@garzik.org>, baum@tehutinetworks.net,
	andy@greyhouse.net
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42116 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756798AbYGFWyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 18:54:23 -0400
In-Reply-To: <487148E0.5040407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030906030407020802060200
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit




--------------030906030407020802060200
Content-Type: text/x-diff;
 name="06.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="06.diff"

tehuti: don't truncate VLAN TCI with VLAN stripping

The vlan_hwaccel_{rx,receive_skb} functions expect the full TCI field
for priority mappings, don't truncate the upper 4 bits.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c05578e004584c39ae91f4bd9d82582913905a29
tree 8a22a280fc7cff6badb7c363369054067914e298
parent c8695f4c66c53182b2b6dc8a848d07e0208edd5d
author Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 00:25:14 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 00:25:14 +0200

 drivers/net/tehuti.c |    2 +-
 drivers/net/tehuti.h |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 432e837..91f9054 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1165,7 +1165,7 @@ NETIF_RX_MUX(struct bdx_priv *priv, u32 rxd_val1, u16 rxd_vlan,
 					  GET_RXD_VLAN_ID(rxd_vlan))->name);
 		/* NAPI variant of receive functions */
 		vlan_hwaccel_receive_skb(skb, priv->vlgrp,
-					 GET_RXD_VLAN_ID(rxd_vlan));
+					 GET_RXD_VLAN_TCI(rxd_vlan));
 	} else {
 		netif_receive_skb(skb);
 	}
diff --git a/drivers/net/tehuti.h b/drivers/net/tehuti.h
index efd170f..e620a0e 100644
--- a/drivers/net/tehuti.h
+++ b/drivers/net/tehuti.h
@@ -309,6 +309,7 @@ struct rxf_desc {
 #define GET_RXD_PKT_ID(x)		GET_BITS_SHIFT((x), 3, 28)
 #define GET_RXD_VTAG(x)			GET_BITS_SHIFT((x), 1, 31)
 #define GET_RXD_VLAN_ID(x)		GET_BITS_SHIFT((x), 12, 0)
+#define GET_RXD_VLAN_TCI(x)		GET_BITS_SHIFT((x), 16, 0)
 #define GET_RXD_CFI(x)			GET_BITS_SHIFT((x), 1, 12)
 #define GET_RXD_PRIO(x)			GET_BITS_SHIFT((x), 3, 13)
 


--------------030906030407020802060200--
