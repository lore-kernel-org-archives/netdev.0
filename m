From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/3] [RTNETLINK] Cleanup rtnetlink_link tables
Date: Sat, 30 Apr 2005 21:52:43 +0200
Message-ID: <20050430195243.GE577@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Converts remaining rtnetlink_link tables to use c99 designated
initializers to make greping a little bit easier.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru -X dontdiff linux-2.6.12-rc3.orig/include/linux/rtnetlink.h linux-2.6.12-rc3/include/linux/rtnetlink.h
--- linux-2.6.12-rc3.orig/include/linux/rtnetlink.h	2005-04-30 20:37:50.000000000 +0200
+++ linux-2.6.12-rc3/include/linux/rtnetlink.h	2005-04-30 20:38:30.000000000 +0200
@@ -93,6 +93,8 @@
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
 
+#define RTM_NR_MSGTYPES	(RTM_MAX + 1 - RTM_BASE)
+#define RTM_NR_FAMILIES	(RTM_NR_MSGTYPES >> 2)
 #define RTM_FAM(cmd)	(((cmd) - RTM_BASE) >> 2)
 
 /* 
diff -Nru -X dontdiff linux-2.6.12-rc3.orig/net/core/rtnetlink.c linux-2.6.12-rc3/net/core/rtnetlink.c
--- linux-2.6.12-rc3.orig/net/core/rtnetlink.c	2005-04-30 20:37:50.000000000 +0200
+++ linux-2.6.12-rc3/net/core/rtnetlink.c	2005-04-30 20:38:30.000000000 +0200
@@ -87,7 +87,7 @@
 
 struct rtnetlink_link * rtnetlink_links[NPROTO];
 
-static const int rtm_min[(RTM_MAX+1-RTM_BASE)/4] =
+static const int rtm_min[RTM_NR_FAMILIES] =
 {
 	[RTM_FAM(RTM_NEWLINK)]      = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
 	[RTM_FAM(RTM_NEWADDR)]      = NLMSG_LENGTH(sizeof(struct ifaddrmsg)),
@@ -103,7 +103,7 @@
 	[RTM_FAM(RTM_GETANYCAST)]   = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
 };
 
-static const int rta_max[(RTM_MAX+1-RTM_BASE)/4] =
+static const int rta_max[RTM_NR_FAMILIES] =
 {
 	[RTM_FAM(RTM_NEWLINK)]      = IFLA_MAX,
 	[RTM_FAM(RTM_NEWADDR)]      = IFA_MAX,
@@ -642,7 +642,7 @@
 	} while (rtnl && rtnl->sk_receive_queue.qlen);
 }
 
-static struct rtnetlink_link link_rtnetlink_table[RTM_MAX-RTM_BASE+1] =
+static struct rtnetlink_link link_rtnetlink_table[RTM_NR_MSGTYPES] =
 {
 	[RTM_GETLINK  - RTM_BASE] = { .dumpit = rtnetlink_dump_ifinfo },
 	[RTM_SETLINK  - RTM_BASE] = { .doit   = do_setlink	      },
diff -Nru -X dontdiff linux-2.6.12-rc3.orig/net/decnet/dn_dev.c linux-2.6.12-rc3/net/decnet/dn_dev.c
--- linux-2.6.12-rc3.orig/net/decnet/dn_dev.c	2005-04-30 20:22:26.000000000 +0200
+++ linux-2.6.12-rc3/net/decnet/dn_dev.c	2005-04-30 20:38:30.000000000 +0200
@@ -1411,21 +1411,22 @@
 
 #endif /* CONFIG_PROC_FS */
 
-static struct rtnetlink_link dnet_rtnetlink_table[RTM_MAX-RTM_BASE+1] = 
+static struct rtnetlink_link dnet_rtnetlink_table[RTM_NR_MSGTYPES] =
 {
-	 [4] = { .doit   = dn_dev_rtm_newaddr,	},
-	 [5] = { .doit   = dn_dev_rtm_deladdr,	},
-	 [6] = { .dumpit = dn_dev_dump_ifaddr,	},
-
+	[RTM_NEWADDR  - RTM_BASE] = { .doit	= dn_dev_rtm_newaddr,	},
+	[RTM_DELADDR  - RTM_BASE] = { .doit	= dn_dev_rtm_deladdr,	},
+	[RTM_GETADDR  - RTM_BASE] = { .dumpit	= dn_dev_dump_ifaddr,	},
 #ifdef CONFIG_DECNET_ROUTER
-	 [8] = { .doit   = dn_fib_rtm_newroute,	},
-	 [9] = { .doit   = dn_fib_rtm_delroute,	},
-	[10] = { .doit   = dn_cache_getroute, .dumpit = dn_fib_dump, },
-	[16] = { .doit   = dn_fib_rtm_newrule, },
-	[17] = { .doit   = dn_fib_rtm_delrule, },
-	[18] = { .dumpit = dn_fib_dump_rules,  },
+	[RTM_NEWROUTE - RTM_BASE] = { .doit	= dn_fib_rtm_newroute,	},
+	[RTM_DELROUTE - RTM_BASE] = { .doit	= dn_fib_rtm_delroute,	},
+	[RTM_GETROUTE - RTM_BASE] = { .doit	= dn_cache_getroute,
+				      .dumpit	= dn_fib_dump,		},
+	[RTM_NEWRULE  - RTM_BASE] = { .doit	= dn_fib_rtm_newrule,	},
+	[RTM_DELRULE  - RTM_BASE] = { .doit	= dn_fib_rtm_delrule,	},
+	[RTM_GETRULE  - RTM_BASE] = { .dumpit	= dn_fib_dump_rules,	},
 #else
-	[10] = { .doit   = dn_cache_getroute, .dumpit = dn_cache_dump, },
+	[RTM_GETROUTE - RTM_BASE] = { .doit	= dn_cache_getroute,
+				      .dumpit	= dn_cache_dump,	
 #endif
 
 };
diff -Nru -X dontdiff linux-2.6.12-rc3.orig/net/ipv4/devinet.c linux-2.6.12-rc3/net/ipv4/devinet.c
--- linux-2.6.12-rc3.orig/net/ipv4/devinet.c	2005-04-30 20:22:24.000000000 +0200
+++ linux-2.6.12-rc3/net/ipv4/devinet.c	2005-04-30 20:38:30.000000000 +0200
@@ -1107,17 +1107,18 @@
 	}
 }
 
-static struct rtnetlink_link inet_rtnetlink_table[RTM_MAX - RTM_BASE + 1] = {
-	 [4] = { .doit	 = inet_rtm_newaddr,  },
-	 [5] = { .doit	 = inet_rtm_deladdr,  },
-	 [6] = { .dumpit = inet_dump_ifaddr,  },
-	 [8] = { .doit	 = inet_rtm_newroute, },
-	 [9] = { .doit	 = inet_rtm_delroute, },
-	[10] = { .doit	 = inet_rtm_getroute, .dumpit = inet_dump_fib, },
+static struct rtnetlink_link inet_rtnetlink_table[RTM_NR_MSGTYPES] = {
+	[RTM_NEWADDR  - RTM_BASE] = { .doit	= inet_rtm_newaddr,	},
+	[RTM_DELADDR  - RTM_BASE] = { .doit	= inet_rtm_deladdr,	},
+	[RTM_GETADDR  - RTM_BASE] = { .dumpit	= inet_dump_ifaddr,	},
+	[RTM_NEWROUTE - RTM_BASE] = { .doit	= inet_rtm_newroute,	},
+	[RTM_DELROUTE - RTM_BASE] = { .doit	= inet_rtm_delroute,	},
+	[RTM_GETROUTE - RTM_BASE] = { .doit	= inet_rtm_getroute,
+				      .dumpit	= inet_dump_fib,	},
 #ifdef CONFIG_IP_MULTIPLE_TABLES
-	[16] = { .doit	 = inet_rtm_newrule, },
-	[17] = { .doit	 = inet_rtm_delrule, },
-	[18] = { .dumpit = inet_dump_rules,  },
+	[RTM_NEWRULE  - RTM_BASE] = { .doit	= inet_rtm_newrule,	},
+	[RTM_DELRULE  - RTM_BASE] = { .doit	= inet_rtm_delrule,	},
+	[RTM_GETRULE  - RTM_BASE] = { .dumpit	= inet_dump_rules,	},
 #endif
 };
 
diff -Nru -X dontdiff linux-2.6.12-rc3.orig/net/ipv6/addrconf.c linux-2.6.12-rc3/net/ipv6/addrconf.c
--- linux-2.6.12-rc3.orig/net/ipv6/addrconf.c	2005-04-30 20:22:26.000000000 +0200
+++ linux-2.6.12-rc3/net/ipv6/addrconf.c	2005-04-30 20:38:30.000000000 +0200
@@ -3076,7 +3076,7 @@
 	netlink_broadcast(rtnl, skb, 0, RTMGRP_IPV6_PREFIX, GFP_ATOMIC);
 }
 
-static struct rtnetlink_link inet6_rtnetlink_table[RTM_MAX - RTM_BASE + 1] = {
+static struct rtnetlink_link inet6_rtnetlink_table[RTM_NR_MSGTYPES] = {
 	[RTM_GETLINK - RTM_BASE] = { .dumpit	= inet6_dump_ifinfo, },
 	[RTM_NEWADDR - RTM_BASE] = { .doit	= inet6_rtm_newaddr, },
 	[RTM_DELADDR - RTM_BASE] = { .doit	= inet6_rtm_deladdr, },
