From: Dan Carpenter <error27@gmail.com>
Subject: [patch 1/3 -next] 6LoWPAN: use kfree_skb() instead of kfree()
Date: Tue, 30 Aug 2011 16:45:52 +0300
Message-ID: <20110830134552.GH3705@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Sergey Lapin <slapin@ossfans.org>,
	"David S. Miller" <davem@davemloft.net>,
	"open list:IEEE 802.15.4 SUB..."
	<linux-zigbee-devel@lists.sourceforge.net>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:54028 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753722Ab1H3NsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 09:48:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use kfree_skb() to free sbk_buffs.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index cf304cc..8a9dbaa 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -674,7 +674,7 @@ lowpan_process_data(struct sk_buff *skb)
 							sizeof(hdr));
 	return lowpan_skb_deliver(skb, &hdr);
 drop:
-	kfree(skb);
+	kfree_skb(skb);
 	return -EINVAL;
 }
 
