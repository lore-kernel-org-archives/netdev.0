From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] Changed action labels to [action ] format
Date: Fri, 10 Oct 2014 19:51:56 +0300
Message-ID: <1412959916-32169-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:46822 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbaJJRAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 13:00:41 -0400
Received: by mail-lb0-f169.google.com with SMTP id 10so3479545lbg.0
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 10:00:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reasons for this change were:
    - different ip utils uses different labels for action: Deleted/delete
    - make an action labels to be easy found in logs

ip monitor:

[DELETED] 192.168.2.0/24 dev winbr0  proto kernel  scope link  src 192.168.2.100  metric 205
[DELETED] default via 192.168.2.1 dev winbr0  metric 205
[DELETED] 5: winbr0    inet 192.168.2.100/24 brd 192.168.2.255 scope global winbr0
       valid_lft forever preferred_lft forever
[DELETED] broadcast 192.168.2.255 dev winbr0  table local  proto kernel  scope link  src 192.168.2.100
[DELETED] broadcast 192.168.2.0 dev winbr0  table local  proto kernel  scope link  src 192.168.2.100
[DELETED] local 192.168.2.100 dev winbr0  table local  proto kernel  scope host  src 192.168.2.100
[DELETED] 224.0.0.251 dev winbr0 lladdr XX:XX:XX:XX:XX:XX NOARP
[DELETED] 224.0.0.22 dev winbr0 lladdr XX:XX:XX:XX:XX:XX NOARP
[DELETED] 192.168.2.1 dev winbr0 lladdr XX:XX:XX:XX:XX:XX REACHABLE

tc monitor:

[DELETED] qdisc dsmark 10: dev lo root indices 0x0040 default_index 0x0001 set_tc_index
qdisc cbq 10: dev lo root rate 100Mbit (bounded,isolated) prio no-transmit
class cbq 10:12 dev lo parent 10: rate 100Mbit (bounded) prio 3
[DELETED] qdisc cbq 10: dev lo root rate 100Mbit (bounded,isolated) prio no-transmit
qdisc htb 10: dev lo root r2q 10 default 0 direct_packets_stat 0 direct_qlen 2
class htb 10:12 dev lo root prio 0 rate 100Mbit ceil 100Mbit burst 1600b cburst 1600b
[DELETED] qdisc htb 10: dev lo root r2q 10 default 0 direct_packets_stat 0 direct_qlen 2
qdisc dsmark 20: dev lo root indices 0x0040 default_index 0x0001 set_tc_index
class dsmark 20:12 dev lo parent 20: mask 0xff value 0x02
[DELETED] qdisc pfifo 0: dev lo parent 20: limit 1p
qdisc prio 10: dev lo parent 20: bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 bridge/fdb.c     | 2 +-
 bridge/link.c    | 2 +-
 ip/ipaddress.c   | 4 ++--
 ip/ipaddrlabel.c | 2 +-
 ip/ipmroute.c    | 2 +-
 ip/ipneigh.c     | 4 ++--
 ip/ipnetns.c     | 4 ++--
 ip/iproute.c     | 2 +-
 ip/iprule.c      | 2 +-
 ip/tcp_metrics.c | 2 +-
 ip/xfrm_policy.c | 6 +++---
 ip/xfrm_state.c  | 6 +++---
 tc/m_action.c    | 6 +++---
 tc/tc_class.c    | 2 +-
 tc/tc_filter.c   | 2 +-
 tc/tc_qdisc.c    | 2 +-
 16 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index a55fac1..26cff05 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -88,7 +88,7 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		     n->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
 	if (n->nlmsg_type == RTM_DELNEIGH)
-		fprintf(fp, "Deleted ");
+		fprintf(fp, "[DELETED] ");
 
 	if (tb[NDA_LLADDR]) {
 		SPRINT_BUF(b1);
diff --git a/bridge/link.c b/bridge/link.c
index 90d9e7f..6eb5887 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -125,7 +125,7 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	}
 
 	if (n->nlmsg_type == RTM_DELLINK)
-		fprintf(fp, "Deleted ");
+		fprintf(fp, "[DELETED] ");
 
 	fprintf(fp, "%d: %s ", ifi->ifi_index,
 		tb[IFLA_IFNAME] ? rta_getattr_str(tb[IFLA_IFNAME]) : "<nil>");
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 45729d8..5c3d5f1 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -481,7 +481,7 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	}
 
 	if (n->nlmsg_type == RTM_DELLINK)
-		fprintf(fp, "Deleted ");
+		fprintf(fp, "[DELETED] ");
 
 	fprintf(fp, "%d: %s", ifi->ifi_index,
 		tb[IFLA_IFNAME] ? rta_getattr_str(tb[IFLA_IFNAME]) : "<nil>");
@@ -694,7 +694,7 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	}
 
 	if (n->nlmsg_type == RTM_DELADDR)
-		fprintf(fp, "Deleted ");
+		fprintf(fp, "[DELETED] ");
 
 	if (filter.oneline || filter.flushb)
 		fprintf(fp, "%u: %s", ifa->ifa_index, ll_index_to_name(ifa->ifa_index));
diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
index b34dd8b..1386586 100644
--- a/ip/ipaddrlabel.c
+++ b/ip/ipaddrlabel.c
@@ -71,7 +71,7 @@ int print_addrlabel(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg
 	parse_rtattr(tb, IFAL_MAX, IFAL_RTA(ifal), len);
 
 	if (n->nlmsg_type == RTM_DELADDRLABEL)
-		fprintf(fp, "Deleted ");
+		fprintf(fp, "[DELETED] ");
 
 	if (tb[IFAL_ADDRESS]) {
 		fprintf(fp, "prefix %s/%u ",
diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index be93a98..6c6eb75 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -111,7 +111,7 @@ int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	family = r->rtm_family == RTNL_FAMILY_IPMR ? AF_INET : AF_INET6;
 
 	if (n->nlmsg_type == RTM_DELROUTE)
-		fprintf(fp, "Deleted ");
+		fprintf(fp, "[DELETED] ");
 
 	if (tb[RTA_SRC])
 		len = snprintf(obuf, sizeof(obuf),
diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index 71a4100..a15ae10 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -251,9 +251,9 @@ int print_neigh(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	}
 
 	if (n->nlmsg_type == RTM_DELNEIGH)
-		fprintf(fp, "delete ");
+		fprintf(fp, "[DELETED] ");
 	else if (n->nlmsg_type == RTM_GETNEIGH)
-		fprintf(fp, "miss ");
+		fprintf(fp, "[MISS] ");
 	if (tb[NDA_DST]) {
 		fprintf(fp, "%s ",
 			format_host(r->ndm_family,
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 90a496f..d8f217f 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -504,9 +504,9 @@ static int netns_monitor(int argc, char **argv)
 		     (char *)event < &buf[len];
 		     event = (struct inotify_event *)((char *)event + sizeof(*event) + event->len)) {
 			if (event->mask & IN_CREATE)
-				printf("add %s\n", event->name);
+				printf("[NEW] %s\n", event->name);
 			if (event->mask & IN_DELETE)
-				printf("delete %s\n", event->name);
+				printf("[DELETED] %s\n", event->name);
 		}
 	}
 	return 0;
diff --git a/ip/iproute.c b/ip/iproute.c
index d77b1e3..5288a5d 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -331,7 +331,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	}
 
 	if (n->nlmsg_type == RTM_DELROUTE)
-		fprintf(fp, "Deleted ");
+		fprintf(fp, "[DELETED] ");
 	if ((r->rtm_type != RTN_UNICAST || show_details > 0) && !filter.type)
 		fprintf(fp, "%s ", rtnl_rtntype_n2a(r->rtm_type, b1, sizeof(b1)));
 
diff --git a/ip/iprule.c b/ip/iprule.c
index 366878e..ff65f58 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -76,7 +76,7 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		host_len = 80;
 
 	if (n->nlmsg_type == RTM_DELRULE)
-		fprintf(fp, "Deleted ");
+		fprintf(fp, "[DELETED] ");
 
 	if (tb[FRA_PRIORITY])
 		fprintf(fp, "%u:\t", *(unsigned*)RTA_DATA(tb[FRA_PRIORITY]));
diff --git a/ip/tcp_metrics.c b/ip/tcp_metrics.c
index bbbb4cc..58d35fb 100644
--- a/ip/tcp_metrics.c
+++ b/ip/tcp_metrics.c
@@ -190,7 +190,7 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	}
 
 	if (f.cmd & (CMD_DEL | CMD_FLUSH))
-		fprintf(fp, "Deleted ");
+		fprintf(fp, "[DELETED] ");
 
 	fprintf(fp, "%s",
 		format_host(family, dlen, &daddr.data, abuf, sizeof(abuf)));
diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 2337d35..3547abe 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -519,11 +519,11 @@ int xfrm_policy_print(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		return 0;
 
 	if (n->nlmsg_type == XFRM_MSG_DELPOLICY)
-		fprintf(fp, "Deleted ");
+		fprintf(fp, "[DELETED] ");
 	else if (n->nlmsg_type == XFRM_MSG_UPDPOLICY)
-		fprintf(fp, "Updated ");
+		fprintf(fp, "[UPDATED] ");
 	else if (n->nlmsg_type == XFRM_MSG_POLEXPIRE)
-		fprintf(fp, "Expired ");
+		fprintf(fp, "[EXPIRED] ");
 
 	if (n->nlmsg_type == XFRM_MSG_DELPOLICY) {
 		//xfrm_policy_id_print();
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index fe7708e..4748292 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -864,11 +864,11 @@ int xfrm_state_print(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		return 0;
 
 	if (n->nlmsg_type == XFRM_MSG_DELSA)
-		fprintf(fp, "Deleted ");
+		fprintf(fp, "[DELETED] ");
 	else if (n->nlmsg_type == XFRM_MSG_UPDSA)
-		fprintf(fp, "Updated ");
+		fprintf(fp, "[UPDATED] ");
 	else if (n->nlmsg_type == XFRM_MSG_EXPIRE)
-		fprintf(fp, "Expired ");
+		fprintf(fp, "[EXPIRED] ");
 
 	if (n->nlmsg_type == XFRM_MSG_DELSA)
 		rta = XFRMSID_RTA(xsid);
diff --git a/tc/m_action.c b/tc/m_action.c
index 486123e..0e8cc74 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -362,15 +362,15 @@ int print_action(const struct sockaddr_nl *who,
 
 	if (n->nlmsg_type == RTM_DELACTION) {
 		if (n->nlmsg_flags & NLM_F_ROOT) {
-			fprintf(fp, "Flushed table ");
+			fprintf(fp, "[FLUSHED] table ");
 			tab_flush = 1;
 		} else {
-			fprintf(fp, "deleted action ");
+			fprintf(fp, "[DELETED] action ");
 		}
 	}
 
 	if (n->nlmsg_type == RTM_NEWACTION)
-		fprintf(fp, "Added action ");
+		fprintf(fp, "[NEW] action ");
 	tc_print_action(fp, tb[TCA_ACT_TAB]);
 
 	return 0;
diff --git a/tc/tc_class.c b/tc/tc_class.c
index e56bf07..66c989b 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -182,7 +182,7 @@ int print_class(const struct sockaddr_nl *who,
 	}
 
 	if (n->nlmsg_type == RTM_DELTCLASS)
-		fprintf(fp, "deleted ");
+		fprintf(fp, "[DELETED] ");
 
 	abuf[0] = 0;
 	if (t->tcm_handle) {
diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index c3f2d5f..aee1f53 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -211,7 +211,7 @@ int print_filter(const struct sockaddr_nl *who,
 	}
 
 	if (n->nlmsg_type == RTM_DELTFILTER)
-		fprintf(fp, "deleted ");
+		fprintf(fp, "[DELETED] ");
 
 	fprintf(fp, "filter ");
 	if (!filter_ifindex || filter_ifindex != t->tcm_ifindex)
diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index e304858..193e720 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -228,7 +228,7 @@ int print_qdisc(const struct sockaddr_nl *who,
 	}
 
 	if (n->nlmsg_type == RTM_DELQDISC)
-		fprintf(fp, "deleted ");
+		fprintf(fp, "[DELETED] ");
 
 	fprintf(fp, "qdisc %s %x: ", rta_getattr_str(tb[TCA_KIND]), t->tcm_handle>>16);
 	if (filter_ifindex == 0)
-- 
2.1.0
