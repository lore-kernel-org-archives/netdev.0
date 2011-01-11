From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH v2 iproute2 1/3] ip link: add support for setting device groups
Date: Tue, 11 Jan 2011 18:35:47 +0200
Message-ID: <1294763749-9997-2-git-send-email-ddvlad@rosedu.org>
References: <1294763749-9997-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>, jamal <hadi@cyberus.ca>,
	Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:60297 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932402Ab1AKQfx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jan 2011 11:35:53 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1294763749-9997-1-git-send-email-ddvlad@rosedu.org>
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the group keyword to specify what group the device should belong to:

  ip link set dev eth0 group 1

Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
---
 include/linux/if_link.h |    2 ++
 ip/iplink.c             |    8 ++++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f5bb2dc..1d789dd 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -116,6 +116,8 @@ enum {
 	IFLA_STATS64,
 	IFLA_VF_PORTS,
 	IFLA_PORT_SELF,
+	IFLA_AF_SPEC,
+	IFLA_GROUP,
 	__IFLA_MAX
 };
 
diff --git a/ip/iplink.c b/ip/iplink.c
index cb2c4f5..a7bad2c 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -252,6 +252,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 	int mtu = -1;
 	int netns = -1;
 	int vf = -1;
+	int group = -1;
 
 	ret = argc;
 
@@ -297,6 +298,13 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			if (get_integer(&mtu, *argv, 0))
 				invarg("Invalid \"mtu\" value\n", *argv);
 			addattr_l(&req->n, sizeof(*req), IFLA_MTU, &mtu, 4);
+		} else if (strcmp(*argv, "group") == 0) {
+			NEXT_ARG();
+			if (mtu != -1)
+				duparg("group", *argv);
+			if (get_integer(&group, *argv, 0))
+				invarg("Invalid \"group\" value\n", *argv);
+			addattr_l(&req->n, sizeof(*req), IFLA_GROUP, &group, 4);
                 } else if (strcmp(*argv, "netns") == 0) {
                         NEXT_ARG();
                         if (netns != -1)
-- 
1.7.1

