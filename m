From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v2 net 3/4] bridge: Fix the way the PVID is referenced
Date: Wed, 16 Oct 2013 17:07:15 +0900
Message-ID: <1381910836-718-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1381910836-718-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Toshiaki Makita <toshiaki.makita1@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:50639 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760004Ab3JPIIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 04:08:06 -0400
In-Reply-To: <1381910836-718-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are using the VLAN_TAG_PRESENT bit to detect whether the PVID is
set or not at br_get_pvid(), while we don't care about the bit in
adding/deleting the PVID, which makes it impossible to forward any
incomming untagged frame with vlan_filtering enabled.

Since vid 0 cannot be used for the PVID, we can use vid 0 to indicate
that the PVID is not set, which is slightly more efficient than using
the VLAN_TAG_PRESENT.

Fix the problem by getting rid of using the VLAN_TAG_PRESENT.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Reviewed-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_private.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index efb57d9..7ca2ae4 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -643,9 +643,7 @@ static inline u16 br_get_pvid(const struct net_port_vlans *v)
 	 * vid wasn't set
 	 */
 	smp_rmb();
-	return (v->pvid & VLAN_TAG_PRESENT) ?
-			(v->pvid & ~VLAN_TAG_PRESENT) :
-			VLAN_N_VID;
+	return v->pvid ?: VLAN_N_VID;
 }
 
 #else
-- 
1.8.1.2
