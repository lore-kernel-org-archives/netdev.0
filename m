From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/4] i40e: fix call of ndo_dflt_bridge_getlink()
Date: Thu, 27 Oct 2016 14:27:57 -0700
Message-ID: <1477603677-39957-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477603677-39957-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Huaibin Wang <huaibin.wang@6wind.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Carolyn Wyborny <carolyn.wyborny@intel.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:18068 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1032765AbcJ0V2C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Oct 2016 17:28:02 -0400
In-Reply-To: <1477603677-39957-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 6abc130..31c97e3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9034,7 +9034,7 @@ static int i40e_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 		return 0;
 
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, veb->bridge_mode,
-				       nlflags, 0, 0, filter_mask, NULL);
+				       0, 0, nlflags, filter_mask, NULL);
 }
 
 /* Hardware supports L4 tunnel length of 128B (=2^7) which includes
-- 
2.7.4
