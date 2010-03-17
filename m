From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch] netpoll: allow spaces in its parameter
Date: Wed, 17 Mar 2010 01:53:26 -0400
Message-ID: <20100317055707.5013.72217.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Amerigo Wang <amwang@redhat.com>,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It would be nice if we allow spaces in netconsole parameters,
otherwise we get weird results if there are spaces in it.

After this patch, we will allow things like:
 "netconsole= @192.168.0.1/eth0 , 66666@192.168.0.2/".

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: David Miller <davem@davemloft.net>

---
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 7aa6972..bf3b2f0 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -629,6 +629,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 	char *cur=opt, *delim;
 
 	if (*cur != '@') {
+		cur = skip_spaces(cur);
 		if ((delim = strchr(cur, '@')) == NULL)
 			goto parse_failed;
 		*delim = 0;
@@ -651,12 +652,14 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 		if ((delim = strchr(cur, ',')) == NULL)
 			goto parse_failed;
 		*delim = 0;
+		strim(cur);
 		strlcpy(np->dev_name, cur, sizeof(np->dev_name));
 		cur = delim;
 	}
 	cur++;
 
 	if (*cur != '@') {
+		cur = skip_spaces(cur);
 		/* dst port */
 		if ((delim = strchr(cur, '@')) == NULL)
 			goto parse_failed;
