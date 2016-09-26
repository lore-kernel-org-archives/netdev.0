From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net v2] i40e: fix call of ndo_dflt_bridge_getlink()
Date: Mon, 26 Sep 2016 09:51:18 +0200
Message-ID: <1474876278-28640-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        Huaibin Wang <huaibin.wang@6wind.com>,
        Carolyn Wyborny <carolyn.wyborny@intel.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:52979 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750818AbcIZHvh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 03:51:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huaibin Wang <huaibin.wang@6wind.com>

Order of arguments is wrong.
The wrong code has been introduced by commit 7d4f8d871ab1, but is compiled
only since commit 9df70b66418e.

Note that this may break netlink dumps.

Fixes: 9df70b66418e ("i40e: Remove incorrect #ifdef's")
Fixes: 7d4f8d871ab1 ("switchdev; add VLAN support for port's bridge_getlink")
CC: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Huaibin Wang <huaibin.wang@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v1 -> v2
 - remove CC
 - rebase on the last net tree

 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d0b3a1bb82ca..2843f6cae97a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9012,7 +9012,7 @@ static int i40e_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 		return 0;
 
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, veb->bridge_mode,
-				       nlflags, 0, 0, filter_mask, NULL);
+				       0, 0, nlflags, filter_mask, NULL);
 }
 
 /* Hardware supports L4 tunnel length of 128B (=2^7) which includes
-- 
2.8.1
