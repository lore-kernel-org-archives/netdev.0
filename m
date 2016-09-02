From: Rami Rosen <rami.rosen@intel.com>
Subject: [PATCH net-next] switchdev: Fix return value of switchdev_port_fdb_dump().
Date: Fri,  2 Sep 2016 14:11:57 +0300
Message-ID: <1472814717-11339-1-git-send-email-rami.rosen@intel.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        eric.dumazet@gmail.com, wkok@cumulusnetworks.com,
        Rami Rosen <rami.rosen@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6426 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753963AbcIBLME (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 07:12:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the retun value of switchdev_port_fdb_dump() when
CONFIG_NET_SWITCHDEV is not set. This avoids getting "warning: return makes
integer from pointer without a cast [-Wint-conversion]" when building
when CONFIG_NET_SWITCHDEV is not set under several compiler versions.
This warning is due to commit d297653dd6f07afbe7e6c702a4bcd7615680002e
("rtnetlink: fdb dump: optimize by saving last interface markers").

Signed-off-by: Rami Rosen <rami.rosen@intel.com>
---
 include/net/switchdev.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 6279f2f..729fe15 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -344,7 +344,7 @@ static inline int switchdev_port_fdb_dump(struct sk_buff *skb,
 					  struct net_device *filter_dev,
 					  int *idx)
 {
-       return idx;
+       return *idx;
 }
 
 static inline bool switchdev_port_same_parent_id(struct net_device *a,
-- 
2.5.5
