From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH RFC net-next] net/vxlan: Fix kernel unaligned access in
 __vxlan_find_mac
Date: Fri, 17 Jul 2015 13:07:31 +0200
Message-ID: <20150717110731.GA30336@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30946 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757544AbbGQLHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 07:07:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


__vxlan_find_mac invokes ether_addr_equal on the eth_addr field,
which triggers unaligned access messages, so rearrange vxlan_fdb
to avoid this as non-intrusively as possible. 

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 drivers/net/vxlan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 34c519e..c9790a2 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -107,8 +107,8 @@ struct vxlan_fdb {
 	unsigned long	  used;
 	struct list_head  remotes;
 	u16		  state;	/* see ndm_state */
-	u8		  flags;	/* see ndm_flags */
 	u8		  eth_addr[ETH_ALEN];
+	u8		  flags;	/* see ndm_flags */
 };
 
 /* Pseudo network device */
-- 
1.7.1
