From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net-next] rtnetlink: Drop unnecessary return value from
 ndo_dflt_fdb_del
Date: Tue, 15 Jul 2014 15:15:20 -0700
Message-ID: <20140715221417.22730.78891.stgit@ahduyck-cp2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3207 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753369AbaGOWP0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 18:15:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change cleans up ndo_dflt_fdb_del to drop the ENOTSUPP return value since
that isn't actually returned anywhere in the code.  As a result we are able to
drop a few lines by just defaulting this to -EINVAL.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/core/rtnetlink.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1f8a59e..ad00c35 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2388,22 +2388,20 @@ int ndo_dflt_fdb_del(struct ndmsg *ndm,
 		     struct net_device *dev,
 		     const unsigned char *addr)
 {
-	int err = -EOPNOTSUPP;
+	int err = -EINVAL;
 
 	/* If aging addresses are supported device will need to
 	 * implement its own handler for this.
 	 */
 	if (!(ndm->ndm_state & NUD_PERMANENT)) {
 		pr_info("%s: FDB only supports static addresses\n", dev->name);
-		return -EINVAL;
+		return err;
 	}
 
 	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr))
 		err = dev_uc_del(dev, addr);
 	else if (is_multicast_ether_addr(addr))
 		err = dev_mc_del(dev, addr);
-	else
-		err = -EINVAL;
 
 	return err;
 }
