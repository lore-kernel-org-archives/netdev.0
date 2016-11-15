From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] rtnetlink: fix rtnl message size computation for XDP
Date: Tue, 15 Nov 2016 11:16:35 +0100
Message-ID: <0169d2419991a4ba533087a4fda70420ccdaca30.1479204870.git.sd@queasysnail.net>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54700 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755647AbcKOKQm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 05:16:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtnl_xdp_size() only considers the size of the actual payload attribute,
and misses the space taken by the attribute used for nesting (IFLA_XDP).

Fixes: d1fdd9138682 ("rtnl: add option for setting link xdp prog")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 net/core/rtnetlink.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5aeb61aadd32..5b4c3ba507d0 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -901,7 +901,8 @@ static size_t rtnl_port_size(const struct net_device *dev,
 
 static size_t rtnl_xdp_size(const struct net_device *dev)
 {
-	size_t xdp_size = nla_total_size(1);	/* XDP_ATTACHED */
+	size_t xdp_size = nla_total_size(0) +	/* nest IFLA_XDP */
+			  nla_total_size(1);	/* XDP_ATTACHED */
 
 	if (!dev->netdev_ops->ndo_xdp)
 		return 0;
-- 
2.10.2
