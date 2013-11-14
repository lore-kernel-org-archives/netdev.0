From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 9/9] genetlink: make genl_ops flags a u8 and move to end
Date: Thu, 14 Nov 2013 17:14:47 +0100
Message-ID: <1384445687-30948-10-git-send-email-johannes@sipsolutions.net>
References: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
 <1384445687-30948-1-git-send-email-johannes@sipsolutions.net>
Cc: linux-wimax@intel.com, Balbir Singh <bsingharora@gmail.com>,
	netfilter-devel@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1384445687-30948-1-git-send-email-johannes@sipsolutions.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg@intel.com>

To save some space in the struct on 32-bit systems,
make the flags a u8 (only 4 bits are used) and also
move them to the end of the struct.

This has no impact on 64-bit systems as alignment of
the struct in an array uses up the space anyway.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index d87486a..0b6a144 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -112,15 +112,15 @@ static inline void genl_info_net_set(struct genl_info *info, struct net *net)
  * @ops_list: operations list
  */
 struct genl_ops {
-	u8			cmd;
-	u8			internal_flags;
-	unsigned int		flags;
 	const struct nla_policy	*policy;
 	int		       (*doit)(struct sk_buff *skb,
 				       struct genl_info *info);
 	int		       (*dumpit)(struct sk_buff *skb,
 					 struct netlink_callback *cb);
 	int		       (*done)(struct netlink_callback *cb);
+	u8			cmd;
+	u8			internal_flags;
+	u8			flags;
 };
 
 int __genl_register_family(struct genl_family *family);
-- 
1.8.4.rc3

