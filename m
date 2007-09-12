From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] [IPROUTE2] Add support for moving links between network namespaces
Date: Wed, 12 Sep 2007 07:05:42 -0600
Message-ID: <m1ir6gava1.fsf_-_@ebiederm.dsl.xmission.com>
References: <m14pi0cac5.fsf@ebiederm.dsl.xmission.com>
	<m1zlzsavla.fsf@ebiederm.dsl.xmission.com>
	<m1veagavjr.fsf_-_@ebiederm.dsl.xmission.com>
	<m1r6l4avhp.fsf_-_@ebiederm.dsl.xmission.com>
	<m1myvsavdn.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Pavel Emelyanov <xemul@openvz.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:42620 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280AbXILNGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 09:06:11 -0400
In-Reply-To: <m1myvsavdn.fsf_-_@ebiederm.dsl.xmission.com> (Eric
	W. Biederman's message of "Wed, 12 Sep 2007 07:03:32 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This adds support for setting the IFLA_NET_NS_PID attribute
on links allowing them to be moved between network namespaces.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/if_link.h |    1 +
 ip/iplink.c             |    9 +++++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 23b3a8e..c948395 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -78,6 +78,7 @@ enum
 	IFLA_LINKMODE,
 	IFLA_LINKINFO,
 #define IFLA_LINKINFO IFLA_LINKINFO
+	IFLA_NET_NS_PID,
 	__IFLA_MAX
 };
 
diff --git a/ip/iplink.c b/ip/iplink.c
index 541f3d6..624c784 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -158,6 +158,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 	char abuf[32];
 	int qlen = -1;
 	int mtu = -1;
+	pid_t netns_pid = -1;
 
 	ret = argc;
 
@@ -255,6 +256,14 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			} else
 				return on_off("dynamic");
 #endif
+		} else if (matches(*argv, "netnspid") == 0) {
+			NEXT_ARG();
+			if (netns_pid != -1)
+				duparg("netnspid", *argv);
+			if (get_integer(&netns_pid, *argv, 0))
+				invarg("Invalid \"netnspid\" value\n", *argv);
+			addattr_l(&req->n, sizeof(*req), IFLA_NET_NS_PID,
+				&netns_pid, sizeof(netns_pid));
 		} else if (matches(*argv, "type") == 0) {
 			NEXT_ARG();
 			*type = *argv;
-- 
1.5.3.rc6.17.g1911

