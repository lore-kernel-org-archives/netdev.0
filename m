From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net-next v13 4/5] genetlink: Add genlmsg_parse() helper function.
Date: Tue, 20 Jan 2015 10:32:51 -0800
Message-ID: <1421778772-11879-5-git-send-email-joestringer@nicira.com>
References: <1421778772-11879-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, dev@openvswitch.org,
	pshelar@nicira.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421778772-11879-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The first user will be the next patch.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 include/net/genetlink.h |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index f24aa83..d5a9a8b 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -206,6 +206,23 @@ static inline struct nlmsghdr *genlmsg_nlhdr(void *user_hdr,
 }
 
 /**
+ * genlmsg_parse - parse attributes of a genetlink message
+ * @nlh: netlink message header
+ * @family: genetlink message family
+ * @tb: destination array with maxtype+1 elements
+ * @maxtype: maximum attribute type to be expected
+ * @policy: validation policy
+ * */
+static inline int genlmsg_parse(const struct nlmsghdr *nlh,
+				const struct genl_family *family,
+				struct nlattr *tb[], int maxtype,
+				const struct nla_policy *policy)
+{
+	return nlmsg_parse(nlh, family->hdrsize + GENL_HDRLEN, tb, maxtype,
+			   policy);
+}
+
+/**
  * genl_dump_check_consistent - check if sequence is consistent and advertise if not
  * @cb: netlink callback structure that stores the sequence number
  * @user_hdr: user header as returned from genlmsg_put()
-- 
1.7.10.4
