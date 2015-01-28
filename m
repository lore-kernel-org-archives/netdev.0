From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v2 iproute2-next 4/4] bridge/fdb: display link netns id
Date: Wed, 28 Jan 2015 15:15:50 +0100
Message-ID: <1422454550-32222-4-git-send-email-nicolas.dichtel@6wind.com>
References: <54C8E3EB.8050904@6wind.com>
 <1422454550-32222-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:44111 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754603AbbA1UPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 15:15:14 -0500
In-Reply-To: <1422454550-32222-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When this attribute is set, it means that the i/o part of the related netdevice
is in another netns.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: new in the series

 bridge/fdb.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index c01a5020de63..6941edd90f90 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -131,12 +131,16 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		if (ifindex) {
 			char ifname[IF_NAMESIZE];
 
-			if (if_indextoname(ifindex, ifname))
+			if (!tb[NDA_LINK_NETNSID] &&
+			    if_indextoname(ifindex, ifname))
 				fprintf(fp, "via %s ", ifname);
 			else
 				fprintf(fp, "via ifindex %u ", ifindex);
 		}
 	}
+	if (tb[NDA_LINK_NETNSID])
+		fprintf(fp, "link-netnsid %d ",
+			rta_getattr_u32(tb[NDA_LINK_NETNSID]));
 
 	if (show_stats && tb[NDA_CACHEINFO]) {
 		struct nda_cacheinfo *ci = RTA_DATA(tb[NDA_CACHEINFO]);
-- 
2.2.2
