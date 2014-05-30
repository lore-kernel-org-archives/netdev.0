From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH] netlink: rate-limit leftover bytes warning and print process name
Date: Fri, 30 May 2014 14:57:27 +0200
Message-ID: <1401454647-28228-1-git-send-email-mschmidt@redhat.com>
References: <5385DAE5.2020009@6wind.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53758 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932663AbaE3M5d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2014 08:57:33 -0400
In-Reply-To: <5385DAE5.2020009@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any process is able to send netlink messages with leftover bytes.
Make the warning rate-limited to prevent too much log spam.

The warning is supposed to help find userspace bugs, so print the
triggering command name to implicate the buggy program.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 lib/nlattr.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/nlattr.c b/lib/nlattr.c
index fc67547..31047c4 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -201,8 +201,9 @@ int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
 	}
 
 	if (unlikely(rem > 0))
-		printk(KERN_WARNING "netlink: %d bytes leftover after parsing "
-		       "attributes.\n", rem);
+		printk_ratelimited(KERN_WARNING
+				   "netlink: %d bytes leftover after parsing attributes in process `%s'.\n",
+				   rem, current->comm);
 
 	err = 0;
 errout:
-- 
1.9.3
