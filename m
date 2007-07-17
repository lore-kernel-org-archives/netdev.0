From: Patrick McHardy <kaber@trash.net>
Subject: [PPPOL2TP 2/2]: Reset meta-data in xmit function
Date: Tue, 17 Jul 2007 14:19:50 +0200
Message-ID: <469CB3E6.7070309@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080204000700080803010706"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	James Chapman <jchapman@katalix.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43224 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756767AbXGQMTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 08:19:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080204000700080803010706
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------080204000700080803010706
Content-Type: text/x-diff;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[PPPOL2TP]: Reset meta-data in xmit function

Reset netfilter data and IP CB, fix dst_entry leak.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 308ac1b6249226730b70fcf7c13a289c27ce2bf3
tree ea05987add4c9423af023e4bc9ca773ab70568c3
parent 86394ab99d7a4532cf23f8d456aecfa6e3085dfd
author Patrick McHardy <kaber@trash.net> Tue, 17 Jul 2007 14:16:51 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 17 Jul 2007 14:16:51 +0200

 drivers/net/pppol2tp.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index 856610f..f871760 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -1049,7 +1049,13 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 		printk("\n");
 	}
 
+	memset(&(IPCB(skb2)->opt), 0, sizeof(IPCB(skb2)->opt));
+	IPCB(skb2)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
+			       IPSKB_REROUTED);
+	nf_reset(skb2);
+
 	/* Get routing info from the tunnel socket */
+	dst_release(skb2->dst);
 	skb2->dst = sk_dst_get(sk_tun);
 
 	/* Queue the packet to IP for output */

--------------080204000700080803010706--
