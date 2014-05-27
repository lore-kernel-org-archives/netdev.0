From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH] netlink: downgrade warning about leftover bytes to debug level
Date: Tue, 27 May 2014 15:16:03 +0200
Message-ID: <1401196563-6999-1-git-send-email-mschmidt@redhat.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19363 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752108AbaE0NQF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 09:16:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any process is able to send netlink messages with leftover bytes, so
downgrade the warning message to pr_debug in order to avoid possible
kernel log spam.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 lib/nlattr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/nlattr.c b/lib/nlattr.c
index fc67547..fbadde6 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -201,8 +201,8 @@ int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
 	}
 
 	if (unlikely(rem > 0))
-		printk(KERN_WARNING "netlink: %d bytes leftover after parsing "
-		       "attributes.\n", rem);
+		pr_debug("netlink: %d bytes leftover after parsing attributes.\n",
+			 rem);
 
 	err = 0;
 errout:
-- 
1.9.3
