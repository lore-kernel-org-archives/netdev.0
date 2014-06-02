From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH v2] netlink: rate-limit leftover bytes warning and print process name
Date: Mon,  2 Jun 2014 18:25:02 +0200
Message-ID: <1401726302-21240-1-git-send-email-mschmidt@redhat.com>
References: <53889525.3080506@cogentembedded.com>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15606 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753036AbaFBQZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2014 12:25:08 -0400
In-Reply-To: <53889525.3080506@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any process is able to send netlink messages with leftover bytes.
Make the warning rate-limited to prevent too much log spam.

The warning is supposed to help find userspace bugs, so print the
triggering command name to implicate the buggy program.

[v2: Use pr_warn_ratelimited instead of printk_ratelimited.]

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 lib/nlattr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/nlattr.c b/lib/nlattr.c
index fc67547..10ad042 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -201,8 +201,8 @@ int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
 	}
 
 	if (unlikely(rem > 0))
-		printk(KERN_WARNING "netlink: %d bytes leftover after parsing "
-		       "attributes.\n", rem);
+		pr_warn_ratelimited("netlink: %d bytes leftover after parsing attributes in process `%s'.\n",
+				    rem, current->comm);
 
 	err = 0;
 errout:
-- 
1.9.3
