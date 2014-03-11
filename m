From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net] xen-netback: use skb_is_gso in xenvif_start_xmit
Date: Tue, 11 Mar 2014 12:45:32 +0000
Message-ID: <1394541932-8119-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>, Annie Li <annie.li@oracle.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Paul Durrant <paul.durrant@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:40979 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbaCKMvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 08:51:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In 5bd076708 ("Xen-netback: Fix issue caused by using gso_type wrongly")
we use skb_is_gso to determine if we need an extra slot to accommodate
the SKB. There's similar error in interface.c. Change that to use
skb_is_gso as well.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: Annie Li <annie.li@oracle.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Paul Durrant <paul.durrant@citrix.com>
---
 drivers/net/xen-netback/interface.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 7669d49..301cc03 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -132,8 +132,7 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* If the skb is GSO then we'll also need an extra slot for the
 	 * metadata.
 	 */
-	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4 ||
-	    skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+	if (skb_is_gso(skb))
 		min_slots_needed++;
 
 	/* If the skb can't possibly fit in the remaining slots
-- 
1.7.10.4
