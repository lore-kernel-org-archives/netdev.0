From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] GRE: enable offloads for GRE
Date: Thu, 10 Jul 2014 17:29:21 -0700
Message-ID: <1405038561-14852-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Amritha Nambiar <amritha.nambiar@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40355 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751170AbaGKA3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2014 20:29:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amritha Nambiar <amritha.nambiar@intel.com>

To get offloads to work with Generic Routing Encapsulation (GRE), the
outer transport header has to be reset after skb_push is done. This
patch has the support for this fix and hence GRE offloading.

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
Tested-By: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 net/ipv4/gre_demux.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 4e9619b..0485bf7 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -68,6 +68,7 @@ void gre_build_header(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 
 	skb_push(skb, hdr_len);
 
+	skb_reset_transport_header(skb);
 	greh = (struct gre_base_hdr *)skb->data;
 	greh->flags = tnl_flags_to_gre_flags(tpi->flags);
 	greh->protocol = tpi->proto;
-- 
1.9.3
