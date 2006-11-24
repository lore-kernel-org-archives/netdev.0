From: nakam@linux-ipv6.org
Subject: [PATCH 4/7] [IP] ADDR: Define 0xFFFFFFFFU as INFINITY_LIFE_TIME regarding to the kernel.
Date: Fri, 24 Nov 2006 12:27:01 +0900
Message-ID: <11643388213683-git-send-email-nakam@linux-ipv6.org>
Cc: takamiya@po.ntts.co.jp, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:6541 "EHLO
	neptune.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S934178AbWKXDbo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 22:31:44 -0500
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Signed-off-by: TAKAMIYA Noriaki <takamiya@po.ntts.co.jp>
Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 ip/ip_common.h |    4 ++++
 ip/ipaddress.c |   10 +++++-----
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index bc6a7cd..8f790e1 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -43,3 +43,7 @@ static inline int rtm_get_table(struct r
 }
 
 extern struct rtnl_handle rth;
+
+#ifndef	INFINITY_LIFE_TIME
+#define     INFINITY_LIFE_TIME      0xFFFFFFFFU
+#endif
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 1437658..3729892 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -283,7 +283,7 @@ static int flush_update(void)
 static int set_lifetime(unsigned int *lifetime, char *argv)
 {
 	if (strcmp(argv, "forever") == 0)
-		*lifetime = 0xFFFFFFFFU;
+		*lifetime = INFINITY_LIFE_TIME;
 	else if (get_u32(lifetime, argv, 0))
 		return -1;
 
@@ -439,11 +439,11 @@ int print_addrinfo(const struct sockaddr
 		struct ifa_cacheinfo *ci = RTA_DATA(rta_tb[IFA_CACHEINFO]);
 		char buf[128];
 		fprintf(fp, "%s", _SL_);
-		if (ci->ifa_valid == 0xFFFFFFFFU)
+		if (ci->ifa_valid == INFINITY_LIFE_TIME)
 			sprintf(buf, "valid_lft forever");
 		else
 			sprintf(buf, "valid_lft %usec", ci->ifa_valid);
-		if (ci->ifa_prefered == 0xFFFFFFFFU)
+		if (ci->ifa_prefered == INFINITY_LIFE_TIME)
 			sprintf(buf+strlen(buf), " preferred_lft forever");
 		else
 			sprintf(buf+strlen(buf), " preferred_lft %usec",
@@ -765,8 +765,8 @@ int ipaddr_modify(int cmd, int flags, in
 	int brd_len = 0;
 	int any_len = 0;
 	int scoped = 0;
-	__u32 preferred_lft = 0xFFFFFFFFU;
-	__u32 valid_lft = 0xFFFFFFFFU;
+	__u32 preferred_lft = INFINITY_LIFE_TIME;
+	__u32 valid_lft = INFINITY_LIFE_TIME;
 	struct ifa_cacheinfo cinfo;
 
 	memset(&req, 0, sizeof(req));
-- 
1.4.2

