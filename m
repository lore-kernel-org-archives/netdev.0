From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: mpls: Update lfib_nlmsg_size to skip deleted nexthops
Date: Tue, 28 Mar 2017 15:19:49 -0700
Message-ID: <1490739589-3039-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:36885 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752323AbdC1WU3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 18:20:29 -0400
Received: by mail-it0-f42.google.com with SMTP id 190so36374303itm.0
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 15:20:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent commit skips nexthops in a route if the device has been
deleted. Update lfib_nlmsg_size accordingly.

Reported-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 74755920c689..0d08229c98c9 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1876,6 +1876,8 @@ static inline size_t lfib_nlmsg_size(struct mpls_route *rt)
 		size_t nhsize = 0;
 
 		for_nexthops(rt) {
+			if (!rtnl_dereference(nh->nh_dev))
+				continue;
 			nhsize += nla_total_size(sizeof(struct rtnexthop));
 			/* RTA_VIA */
 			if (nh->nh_via_table != MPLS_NEIGH_TABLE_UNSPEC)
-- 
2.1.4
