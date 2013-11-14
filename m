From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 9/7] genetlink: make genl_ops flags a u8 and move to end
Date: Thu, 14 Nov 2013 15:01:38 +0100
Message-ID: <1384437698.13941.24.camel@jlt4.sipsolutions.net>
References: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:48652 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753133Ab3KNOBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 09:01:42 -0500
Received: by sipsolutions.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:256)
	(Exim 4.80)
	(envelope-from <johannes@sipsolutions.net>)
	id 1VgxUL-00063R-84
	for netdev@vger.kernel.org; Thu, 14 Nov 2013 15:01:41 +0100
In-Reply-To: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
index 0b6b10b..eddcdf2 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -110,15 +110,15 @@ static inline void genl_info_net_set(struct genl_info *info, struct net *net)
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
