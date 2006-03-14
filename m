From: Shailabh Nagar <nagar@watson.ibm.com>
Subject: [Patch 8/9] generic netlink utility functions
Date: Mon, 13 Mar 2006 19:55:05 -0500
Message-ID: <1142297705.5858.28.camel@elinux04.optonline.net>
References: <1142296834.5858.3.camel@elinux04.optonline.net>
Reply-To: nagar@watson.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jamal <hadi@cyberus.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932526AbWCNAzM@vger.kernel.org>
To: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
In-Reply-To: <1142296834.5858.3.camel@elinux04.optonline.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

genetlink-utils.patch

Two utilities for simplifying usage of NETLINK_GENERIC
interface.

Signed-off-by: Balbir Singh <balbir@in.ibm.com>
Signed-off-by: Shailabh Nagar <nagar@watson.ibm.com>

 include/net/genetlink.h |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+)

Index: linux-2.6.16-rc5/include/net/genetlink.h
===================================================================
--- linux-2.6.16-rc5.orig/include/net/genetlink.h	2006-03-11 07:41:32.000000000 -0500
+++ linux-2.6.16-rc5/include/net/genetlink.h	2006-03-11 07:41:41.000000000 -0500
@@ -150,4 +150,24 @@ static inline int genlmsg_unicast(struct
 	return nlmsg_unicast(genl_sock, skb, pid);
 }
 
+/**
+ * gennlmsg_data - head of message payload
+ * @gnlh: genetlink messsage header
+ */
+static inline void *genlmsg_data(const struct genlmsghdr *gnlh)
+{
+       return ((unsigned char *) gnlh + GENL_HDRLEN);
+}
+
+/**
+ * genlmsg_len - length of message payload
+ * @gnlh: genetlink message header
+ */
+static inline int genlmsg_len(const struct genlmsghdr *gnlh)
+{
+       struct nlmsghdr *nlh = (struct nlmsghdr *)((unsigned char *)gnlh -
+                                                   NLMSG_HDRLEN);
+       return (nlh->nlmsg_len - GENL_HDRLEN - NLMSG_HDRLEN);
+}
+
 #endif	/* __NET_GENERIC_NETLINK_H */
