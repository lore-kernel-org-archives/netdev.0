From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net] netdev: remove potentially harmful checks
Date: Mon,  7 Apr 2014 11:25:12 +0200
Message-ID: <1396862712-5225-1-git-send-email-vfalico@redhat.com>
Cc: dborkman@redhat.com, Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Jiri Pirko <jiri@resnulli.us>,
	stephen hemminger <stephen@networkplumber.org>,
	Jerry Chu <hkchu@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39011 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753408AbaDGJ3X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2014 05:29:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we're checking a variable for != NULL after actually
dereferencing it, in netdev_lower_get_next_private*().

It's counter-intuitive at best, and can lead to faulty usage (as it implies
that the variable can be NULL), so fix it by removing the useless checks.

Reported-by: Daniel Borkmann <dborkman@redhat.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: stephen hemminger <stephen@networkplumber.org>
CC: Jerry Chu <hkchu@google.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 net/core/dev.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5777018..14dac06 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4589,8 +4589,7 @@ void *netdev_lower_get_next_private(struct net_device *dev,
 	if (&lower->list == &dev->adj_list.lower)
 		return NULL;
 
-	if (iter)
-		*iter = lower->list.next;
+	*iter = lower->list.next;
 
 	return lower->private;
 }
@@ -4618,8 +4617,7 @@ void *netdev_lower_get_next_private_rcu(struct net_device *dev,
 	if (&lower->list == &dev->adj_list.lower)
 		return NULL;
 
-	if (iter)
-		*iter = &lower->list;
+	*iter = &lower->list;
 
 	return lower->private;
 }
-- 
1.8.4
