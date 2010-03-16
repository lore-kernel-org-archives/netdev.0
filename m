From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6] bridge br_multicast: Fix skb leakage in error path.
Date: Tue, 16 Mar 2010 14:26:56 +0900
Message-ID: <201003160526.o2G5QuVN010801@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:36768 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753456Ab0CPF1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 01:27:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/bridge/br_multicast.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index fd96a8d..4095192 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -990,7 +990,7 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 
 		err = pskb_trim_rcsum(skb2, len);
 		if (err)
-			return err;
+			goto err_out;
 	}
 
 	len -= ip_hdrlen(skb2);
@@ -1012,7 +1012,7 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	case CHECKSUM_NONE:
 		skb2->csum = 0;
 		if (skb_checksum_complete(skb2))
-			return -EINVAL;
+			goto out;
 	}
 
 	err = 0;
@@ -1039,6 +1039,7 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 
 out:
 	__skb_push(skb2, offset);
+err_out:
 	if (skb2 != skb)
 		kfree_skb(skb2);
 	return err;
-- 
1.5.6.5

