From: roopa@cumulusnetworks.com
Subject: [PATCH iproute2] rename RTNH_F_EXTERNAL to RTNH_F_OFFLOAD
Date: Wed, 13 May 2015 21:20:38 -0700
Message-ID: <1431577238-12604-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org, sfeldma@gmail.com, jiri@resnulli.us,
	gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:34941 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbbENEUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 00:20:48 -0400
Received: by pdbqd1 with SMTP id qd1so72351699pdb.2
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 21:20:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

RTNH_F_EXTERNAL is printed as "offload" in iproute2 output.

This patch renames the flag to be consistent with what the user sees.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
RTNH_F_EXTERNAL was introduced in 4.1 and is not out in 4.0 kernel.

This patch follows kernel patch with the same title
"rename RTNH_F_EXTERNAL to RTNH_F_OFFLOAD"

 include/linux/rtnetlink.h |    2 +-
 ip/iproute.c              |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 702b19b..90eeb4f 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -337,7 +337,7 @@ struct rtnexthop {
 #define RTNH_F_DEAD		1	/* Nexthop is dead (used by multipath)	*/
 #define RTNH_F_PERVASIVE	2	/* Do recursive gateway lookup	*/
 #define RTNH_F_ONLINK		4	/* Gateway is forced on link	*/
-#define RTNH_F_EXTERNAL		8	/* Route installed externally	*/
+#define RTNH_F_OFFLOAD		8	/* Offloaded route */
 
 /* Macros to handle hexthops */
 
diff --git a/ip/iproute.c b/ip/iproute.c
index 670a4c6..262d3a1 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -447,7 +447,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "onlink ");
 	if (r->rtm_flags & RTNH_F_PERVASIVE)
 		fprintf(fp, "pervasive ");
-	if (r->rtm_flags & RTNH_F_EXTERNAL)
+	if (r->rtm_flags & RTNH_F_OFFLOAD)
 		fprintf(fp, "offload ");
 	if (r->rtm_flags & RTM_F_NOTIFY)
 		fprintf(fp, "notify ");
-- 
1.7.10.4
