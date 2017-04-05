From: Timothy Redaelli <tredaelli@redhat.com>
Subject: [iproute PATCH] ip-route: Prevent some other double spaces in output
Date: Wed,  5 Apr 2017 19:10:26 +0200
Message-ID: <d73d016dbf5c81869e4fe745b9223fd726f1c43a.1491410198.git.tredaelli@redhat.com>
Cc: psutter@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56860 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754286AbdDERMy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 13:12:54 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7177D80F9A
        for <netdev@vger.kernel.org>; Wed,  5 Apr 2017 17:12:48 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print spaces only after text.

CC: Phil Sutter <phil@nwl.cc>
Signed-off-by: Timothy Redaelli <tredaelli@redhat.com>
---
 ip/iproute.c | 77 ++++++++++++++++++++++++++++++------------------------------
 1 file changed, 39 insertions(+), 38 deletions(-)

Fixed all the problems reported in V2

Tested with improved script https://da.gd/tUVso that tests ip route and ip get
for both ipv4 and ipv6.

If it's OK I'd like to send it upstream

diff --git a/ip/iproute.c b/ip/iproute.c
index 7cdf072..5e23613 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -298,12 +298,12 @@ static void print_rtax_features(FILE *fp, unsigned int features)
 	unsigned int of = features;
 
 	if (features & RTAX_FEATURE_ECN) {
-		fprintf(fp, " ecn");
+		fprintf(fp, "ecn ");
 		features &= ~RTAX_FEATURE_ECN;
 	}
 
 	if (features)
-		fprintf(fp, " 0x%x", of);
+		fprintf(fp, "0x%x ", of);
 }
 
 int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
@@ -511,21 +511,21 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			if (!hz)
 				hz = get_user_hz();
 			if (ci->rta_expires != 0)
-				fprintf(fp, " expires %dsec", ci->rta_expires/hz);
+				fprintf(fp, "expires %dsec ", ci->rta_expires/hz);
 			if (ci->rta_error != 0)
-				fprintf(fp, " error %d", ci->rta_error);
+				fprintf(fp, "error %d ", ci->rta_error);
 			if (show_stats) {
 				if (ci->rta_clntref)
-					fprintf(fp, " users %d", ci->rta_clntref);
+					fprintf(fp, "users %d ", ci->rta_clntref);
 				if (ci->rta_used != 0)
-					fprintf(fp, " used %d", ci->rta_used);
+					fprintf(fp, "used %d ", ci->rta_used);
 				if (ci->rta_lastuse != 0)
-					fprintf(fp, " age %dsec", ci->rta_lastuse/hz);
+					fprintf(fp, "age %dsec ", ci->rta_lastuse/hz);
 			}
 			if (ci->rta_id)
-				fprintf(fp, " ipid 0x%04x", ci->rta_id);
+				fprintf(fp, "ipid 0x%04x ", ci->rta_id);
 			if (ci->rta_ts || ci->rta_tsage)
-				fprintf(fp, " ts 0x%x tsage %dsec",
+				fprintf(fp, "ts 0x%x tsage %dsec ",
 					ci->rta_ts, ci->rta_tsage);
 		}
 	} else if (r->rtm_family == AF_INET6) {
@@ -539,20 +539,20 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			if (r->rtm_flags & RTM_F_CLONED)
 				fprintf(fp, "%s    cache ", _SL_);
 			if (ci->rta_expires)
-				fprintf(fp, " expires %dsec", ci->rta_expires/hz);
+				fprintf(fp, "expires %dsec ", ci->rta_expires/hz);
 			if (ci->rta_error != 0)
-				fprintf(fp, " error %d", ci->rta_error);
+				fprintf(fp, "error %d ", ci->rta_error);
 			if (show_stats) {
 				if (ci->rta_clntref)
-					fprintf(fp, " users %d", ci->rta_clntref);
+					fprintf(fp, "users %d ", ci->rta_clntref);
 				if (ci->rta_used != 0)
-					fprintf(fp, " used %d", ci->rta_used);
+					fprintf(fp, "used %d ", ci->rta_used);
 				if (ci->rta_lastuse != 0)
-					fprintf(fp, " age %dsec", ci->rta_lastuse/hz);
+					fprintf(fp, "age %dsec ", ci->rta_lastuse/hz);
 			}
 		} else if (ci) {
 			if (ci->rta_error != 0)
-				fprintf(fp, " error %d", ci->rta_error);
+				fprintf(fp, "error %d ", ci->rta_error);
 		}
 	}
 	if (tb[RTA_METRICS]) {
@@ -578,19 +578,19 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				continue;
 
 			if (i < sizeof(mx_names)/sizeof(char *) && mx_names[i])
-				fprintf(fp, " %s", mx_names[i]);
+				fprintf(fp, "%s ", mx_names[i]);
 			else
-				fprintf(fp, " metric %d", i);
+				fprintf(fp, "metric %d ", i);
 
 			if (mxlock & (1<<i))
-				fprintf(fp, " lock");
+				fprintf(fp, "lock ");
 
 			switch (i) {
 			case RTAX_FEATURES:
 				print_rtax_features(fp, val);
 				break;
 			default:
-				fprintf(fp, " %u", val);
+				fprintf(fp, "%u ", val);
 				break;
 
 			case RTAX_RTT:
@@ -602,18 +602,18 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 					val /= 4;
 
 				if (val >= 1000)
-					fprintf(fp, " %gs", val/1e3);
+					fprintf(fp, "%gs ", val/1e3);
 				else
-					fprintf(fp, " %ums", val);
+					fprintf(fp, "%ums ", val);
 				break;
 			case RTAX_CC_ALGO:
-				fprintf(fp, " %s", rta_getattr_str(mxrta[i]));
+				fprintf(fp, "%s ", rta_getattr_str(mxrta[i]));
 				break;
 			}
 		}
 	}
 	if (tb[RTA_IIF] && filter.iifmask != -1) {
-		fprintf(fp, " iif %s",
+		fprintf(fp, "iif %s ",
 			ll_index_to_name(rta_getattr_u32(tb[RTA_IIF])));
 	}
 	if (tb[RTA_MULTIPATH]) {
@@ -629,11 +629,11 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				break;
 			if (r->rtm_flags&RTM_F_CLONED && r->rtm_type == RTN_MULTICAST) {
 				if (first)
-					fprintf(fp, " Oifs:");
+					fprintf(fp, "Oifs: ");
 				else
 					fprintf(fp, " ");
 			} else
-				fprintf(fp, "%s\tnexthop", _SL_);
+				fprintf(fp, "%s\tnexthop ", _SL_);
 			if (nh->rtnh_len > sizeof(*nh)) {
 				parse_rtattr(tb, RTA_MAX, RTNH_DATA(nh), nh->rtnh_len - sizeof(*nh));
 
@@ -642,12 +642,12 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 							tb[RTA_ENCAP_TYPE],
 							tb[RTA_ENCAP]);
 				if (tb[RTA_NEWDST]) {
-					fprintf(fp, " as to %s ",
+					fprintf(fp, "as to %s ",
 						format_host_rta(r->rtm_family,
 								tb[RTA_NEWDST]));
 				}
 				if (tb[RTA_GATEWAY]) {
-					fprintf(fp, " via %s ",
+					fprintf(fp, "via %s ",
 						format_host_rta(r->rtm_family,
 								tb[RTA_GATEWAY]));
 				}
@@ -655,7 +655,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 					size_t len = RTA_PAYLOAD(tb[RTA_VIA]) - 2;
 					struct rtvia *via = RTA_DATA(tb[RTA_VIA]);
 
-					fprintf(fp, " via %s %s ",
+					fprintf(fp, "via %s %s ",
 						family_name(via->rtvia_family),
 						format_host(via->rtvia_family, len, via->rtvia_addr));
 				}
@@ -664,33 +664,34 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 					__u32 from = to>>16;
 
 					to &= 0xFFFF;
-					fprintf(fp, " realm%s ", from ? "s" : "");
+					fprintf(fp, "realm%s ", from ? "s" : "");
 					if (from) {
 						fprintf(fp, "%s/",
 							rtnl_rtrealm_n2a(from, b1, sizeof(b1)));
 					}
-					fprintf(fp, "%s",
+					fprintf(fp, "%s ",
 						rtnl_rtrealm_n2a(to, b1, sizeof(b1)));
 				}
 			}
 			if (r->rtm_flags&RTM_F_CLONED && r->rtm_type == RTN_MULTICAST) {
-				fprintf(fp, " %s", ll_index_to_name(nh->rtnh_ifindex));
+				fprintf(fp, "%s", ll_index_to_name(nh->rtnh_ifindex));
 				if (nh->rtnh_hops != 1)
 					fprintf(fp, "(ttl>%d)", nh->rtnh_hops);
+				fprintf(fp, " ");
 			} else {
-				fprintf(fp, " dev %s", ll_index_to_name(nh->rtnh_ifindex));
+				fprintf(fp, "dev %s ", ll_index_to_name(nh->rtnh_ifindex));
 				if (r->rtm_family != AF_MPLS)
-					fprintf(fp, " weight %d",
+					fprintf(fp, "weight %d ",
 						nh->rtnh_hops+1);
 			}
 			if (nh->rtnh_flags & RTNH_F_DEAD)
-				fprintf(fp, " dead");
+				fprintf(fp, "dead ");
 			if (nh->rtnh_flags & RTNH_F_ONLINK)
-				fprintf(fp, " onlink");
+				fprintf(fp, "onlink ");
 			if (nh->rtnh_flags & RTNH_F_PERVASIVE)
-				fprintf(fp, " pervasive");
+				fprintf(fp, "pervasive ");
 			if (nh->rtnh_flags & RTNH_F_LINKDOWN)
-				fprintf(fp, " linkdown");
+				fprintf(fp, "linkdown ");
 			len -= NLMSG_ALIGN(nh->rtnh_len);
 			nh = RTNH_NEXT(nh);
 		}
@@ -698,7 +699,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (tb[RTA_PREF]) {
 		unsigned int pref = rta_getattr_u8(tb[RTA_PREF]);
 
-		fprintf(fp, " pref ");
+		fprintf(fp, "pref ");
 
 		switch (pref) {
 		case ICMPV6_ROUTER_PREF_LOW:
-- 
2.9.3
