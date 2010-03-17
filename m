From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch] netpoll: warn when there are spaces in parameters
Date: Wed, 17 Mar 2010 06:12:55 -0400
Message-ID: <20100317101635.5948.23485.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Amerigo Wang <amwang@redhat.com>,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Currently, if we leave spaces before dst port,
netconsole will silently accept it as 0. Warn about this.

Also, when spaces appear in other places, make them
visible in error messages.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: David Miller <davem@davemloft.net>

---

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 7aa6972..6df1863 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -614,7 +614,7 @@ void netpoll_print_options(struct netpoll *np)
 			 np->name, np->local_port);
 	printk(KERN_INFO "%s: local IP %pI4\n",
 			 np->name, &np->local_ip);
-	printk(KERN_INFO "%s: interface %s\n",
+	printk(KERN_INFO "%s: interface '%s'\n",
 			 np->name, np->dev_name);
 	printk(KERN_INFO "%s: remote port %d\n",
 			 np->name, np->remote_port);
@@ -661,6 +661,9 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 		if ((delim = strchr(cur, '@')) == NULL)
 			goto parse_failed;
 		*delim = 0;
+		if (*cur == ' ' || *cur == '\t')
+			printk(KERN_INFO "%s: warning: white spaces"
+					"are not allowed.\n", np->name);
 		np->remote_port = simple_strtol(cur, NULL, 10);
 		cur = delim;
 	}
@@ -708,7 +711,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 	return 0;
 
  parse_failed:
-	printk(KERN_INFO "%s: couldn't parse config at %s!\n",
+	printk(KERN_INFO "%s: couldn't parse config at '%s'!\n",
 	       np->name, cur);
 	return -1;
 }
