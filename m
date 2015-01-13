From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 1/2] Add define for nlmsg_types with timestamp
Date: Tue, 13 Jan 2015 20:14:23 +0200
Message-ID: <1421172864-20853-2-git-send-email-vadim4j@gmail.com>
References: <1421172864-20853-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:42126 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbbAMSY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 13:24:57 -0500
Received: by mail-lb0-f182.google.com with SMTP id u10so4000521lbd.13
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 10:24:56 -0800 (PST)
In-Reply-To: <1421172864-20853-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Add #define for nlmsg_type = 15

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 bridge/monitor.c     | 4 +---
 include/libnetlink.h | 4 ++++
 ip/ipmonitor.c       | 2 +-
 ip/rtmon.c           | 2 +-
 4 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/bridge/monitor.c b/bridge/monitor.c
index 76e7d47..f00e0a6 100644
--- a/bridge/monitor.c
+++ b/bridge/monitor.c
@@ -74,14 +74,12 @@ static int accept_msg(const struct sockaddr_nl *who,
 			fprintf(fp, "[MDB]");
 		return print_mdb(who, n, arg);
 
-	case 15:
+	case NLMSG_TSTAMP:
 		return show_mark(fp, n);
 
 	default:
 		return 0;
 	}
-
-
 }
 
 int do_monitor(int argc, char **argv)
diff --git a/include/libnetlink.h b/include/libnetlink.h
index de7c85f..d081e54 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -158,5 +158,9 @@ extern int rtnl_from_file(FILE *, rtnl_filter_t handler,
 #define NDTA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ndtmsg))
 #endif
 
+/* User defined nlmsg_type which is used mostly for logging netlink
+ * messages from dump file */
+#define NLMSG_TSTAMP	15
+
 #endif /* __LIBNETLINK_H__ */
 
diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 4708e54..f40daac 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -125,7 +125,7 @@ static int accept_msg(const struct sockaddr_nl *who,
 		print_netconf(who, n, arg);
 		return 0;
 	}
-	if (n->nlmsg_type == 15) {
+	if (n->nlmsg_type == NLMSG_TSTAMP) {
 		char *tstr;
 		time_t secs = ((__u32*)NLMSG_DATA(n))[0];
 		long usecs = ((__u32*)NLMSG_DATA(n))[1];
diff --git a/ip/rtmon.c b/ip/rtmon.c
index 9227eac..ff685e5 100644
--- a/ip/rtmon.c
+++ b/ip/rtmon.c
@@ -34,7 +34,7 @@ static void write_stamp(FILE *fp)
 	struct nlmsghdr *n1 = (void*)buf;
 	struct timeval tv;
 
-	n1->nlmsg_type = 15;
+	n1->nlmsg_type = NLMSG_TSTAMP;
 	n1->nlmsg_flags = 0;
 	n1->nlmsg_seq = 0;
 	n1->nlmsg_pid = 0;
-- 
2.1.3
