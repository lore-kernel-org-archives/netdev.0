From: Shailabh Nagar <nagar@watson.ibm.com>
Subject: [Patch 4/8] generic netlink utility functions
Date: Wed, 29 Mar 2006 19:48:52 -0500
Message-ID: <442B2AF4.1020302@watson.ibm.com>
References: <442B271D.10208@watson.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	Jamal <hadi@cyberus.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751317AbWC3AtL@vger.kernel.org>
To: linux-kernel <linux-kernel@vger.kernel.org>
In-Reply-To: <442B271D.10208@watson.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

genetlink-utils.patch

Two utilities for simplifying usage of NETLINK_GENERIC
interface.

Signed-off-by: Balbir Singh <balbir@in.ibm.com>
Signed-off-by: Shailabh Nagar <nagar@watson.ibm.com>

 include/net/genetlink.h |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+)

Index: linux-2.6.16/include/net/genetlink.h
===================================================================
--- linux-2.6.16.orig/include/net/genetlink.h	2006-03-29 18:12:54.000000000 -0500
+++ linux-2.6.16/include/net/genetlink.h	2006-03-29 18:13:17.000000000 -0500
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
