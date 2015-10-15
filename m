From: Jiri Benc <jbenc@redhat.com>
Subject: [RFC PATCH net-next 2/9] netlink: remove unnecesary goto's
Date: Thu, 15 Oct 2015 18:39:07 +0200
Message-ID: <42d84b840891d129e2cb021cf8c104093e00a47f.1444926905.git.jbenc@redhat.com>
References: <cover.1444926905.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59180 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752486AbbJOQjh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 12:39:37 -0400
In-Reply-To: <cover.1444926905.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jumping to the return makes the code less readable. The compiler will
optimize this just fine.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 lib/nlattr.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/lib/nlattr.c b/lib/nlattr.c
index f5907d23272d..b35c3e6c8e81 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -128,12 +128,10 @@ int nla_validate(const struct nlattr *head, int len, int maxtype,
 	nla_for_each_attr(nla, head, len, rem) {
 		err = validate_nla(nla, maxtype, policy);
 		if (err < 0)
-			goto errout;
+			return err;
 	}
 
-	err = 0;
-errout:
-	return err;
+	return 0;
 }
 EXPORT_SYMBOL(nla_validate);
 
@@ -194,7 +192,7 @@ int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
 			if (policy) {
 				err = validate_nla(nla, maxtype, policy);
 				if (err < 0)
-					goto errout;
+					return err;
 			}
 
 			tb[type] = (struct nlattr *)nla;
@@ -205,9 +203,7 @@ int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
 		pr_warn_ratelimited("netlink: %d bytes leftover after parsing attributes in process `%s'.\n",
 				    rem, current->comm);
 
-	err = 0;
-errout:
-	return err;
+	return 0;
 }
 EXPORT_SYMBOL(nla_parse);
 
-- 
1.8.3.1
