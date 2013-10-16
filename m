From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v2 net 4/4] bridge: Fix updating FDB entries when the PVID is applied
Date: Wed, 16 Oct 2013 17:07:16 +0900
Message-ID: <1381910836-718-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1381910836-718-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Toshiaki Makita <toshiaki.makita1@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:50640 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759964Ab3JPIIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 04:08:06 -0400
In-Reply-To: <1381910836-718-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently set the value that variable vid is pointing, which will be
used in FDB later, to 0 at br_allowed_ingress() when we receive untagged
or priority-tagged frames, even though the PVID is valid.
This leads to FDB updates in such a wrong way that they are learned with
VID 0.
Update the value to that of PVID if the PVID is applied.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Reviewed-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_vlan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 5a9c44a..53f0990 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -217,6 +217,7 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 		/* PVID is set on this port.  Any untagged or priority-tagged
 		 * ingress frame is considered to belong to this vlan.
 		 */
+		*vid = pvid;
 		if (likely(err))
 			/* Untagged Frame. */
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), pvid);
-- 
1.8.1.2
