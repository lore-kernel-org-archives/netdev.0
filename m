From: Shailabh Nagar <nagar@watson.ibm.com>
Subject: [Patch 4/8] Utilities for genetlink usage
Date: Fri, 21 Apr 2006 22:35:42 -0400
Message-ID: <4449967E.2050604@watson.ibm.com>
References: <444991EF.3080708@watson.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LSE <lse-tech@lists.sourceforge.net>,
	Jay Lan <jlan@engr.sgi.com>, Jamal <hadi@cyberus.ca>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>
Return-path: <lse-tech-admin@lists.sourceforge.net>
To: linux-kernel <linux-kernel@vger.kernel.org>
In-Reply-To: <444991EF.3080708@watson.ibm.com>
Sender: lse-tech-admin@lists.sourceforge.net
Errors-To: lse-tech-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/lse-tech>,
	<mailto:lse-tech-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:lse-tech@lists.sourceforge.net>
List-Help: <mailto:lse-tech-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/lse-tech>,
	<mailto:lse-tech-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=lse-tech>
List-Id: netdev.vger.kernel.org

genetlink-utils.patch

Two utilities for simplifying usage of NETLINK_GENERIC
interface.

Signed-off-by: Balbir Singh <balbir@in.ibm.com>
Signed-off-by: Shailabh Nagar <nagar@watson.ibm.com>

 include/net/genetlink.h |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+)

Index: linux-2.6.17-rc1/include/net/genetlink.h
===================================================================
--- linux-2.6.17-rc1.orig/include/net/genetlink.h	2006-04-21 19:39:29.000000000 -0400
+++ linux-2.6.17-rc1/include/net/genetlink.h	2006-04-21 20:29:19.000000000 -0400
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


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
