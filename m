From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] remove concat. with __FUNCTION__ (net/)
Date: Tue, 6 Apr 2004 14:46:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040406144610.2471dcf7.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Tony Breeds <tony@bakeyournoodle.com>

"concatenation of string literals with __FUNCTION__ is deprecated"


---

 linux-265-kj1-rddunlap/net/8021q/vlan.h                       |    4 ++--
 linux-265-kj1-rddunlap/net/8021q/vlanproc.c                   |    2 +-
 linux-265-kj1-rddunlap/net/ipv4/netfilter/ip_conntrack_irc.c  |    4 ++--
 linux-265-kj1-rddunlap/net/ipv4/netfilter/ip_conntrack_tftp.c |    4 ++--
 linux-265-kj1-rddunlap/net/ipv4/netfilter/ip_nat_tftp.c       |    4 ++--
 linux-265-kj1-rddunlap/net/ipv4/netfilter/ipt_ULOG.c          |    6 +++---
 6 files changed, 12 insertions(+), 12 deletions(-)


diff -puN net/8021q/vlan.h~remove_concat_FUNCTION_net net/8021q/vlan.h
--- linux-265-kj1/net/8021q/vlan.h~remove_concat_FUNCTION_net	2004-04-05 13:31:51.000000000 -0700
+++ linux-265-kj1-rddunlap/net/8021q/vlan.h	2004-04-05 13:31:51.000000000 -0700
@@ -19,8 +19,8 @@ I never found it..and the problem seems 
 I'll bet they might prove useful again... --Ben
 
 
-#define VLAN_MEM_DBG(x, y, z) printk(VLAN_DBG __FUNCTION__ ":  "  x, y, z);
-#define VLAN_FMEM_DBG(x, y) printk(VLAN_DBG __FUNCTION__  ":  " x, y);
+#define VLAN_MEM_DBG(x, y, z) printk(VLAN_DBG "%s:  "  x, __FUNCTION__, y, z);
+#define VLAN_FMEM_DBG(x, y) printk(VLAN_DBG "%s:  " x, __FUNCTION__, y);
 */
 
 /* This way they don't do anything! */
diff -puN net/8021q/vlanproc.c~remove_concat_FUNCTION_net net/8021q/vlanproc.c
--- linux-265-kj1/net/8021q/vlanproc.c~remove_concat_FUNCTION_net	2004-04-05 13:31:51.000000000 -0700
+++ linux-265-kj1-rddunlap/net/8021q/vlanproc.c	2004-04-05 13:31:51.000000000 -0700
@@ -220,7 +220,7 @@ int vlan_proc_rem_dev(struct net_device 
 	}
 
 #ifdef VLAN_DEBUG
-	printk(VLAN_DBG __FUNCTION__ ": dev: %p\n", vlandev);
+	printk(VLAN_DBG "%s: dev: %p\n", __FUNCTION__, vlandev);
 #endif
 
 	/** NOTE:  This will consume the memory pointed to by dent, it seems. */
diff -puN net/ipv4/netfilter/ip_conntrack_irc.c~remove_concat_FUNCTION_net net/ipv4/netfilter/ip_conntrack_irc.c
--- linux-265-kj1/net/ipv4/netfilter/ip_conntrack_irc.c~remove_concat_FUNCTION_net	2004-04-05 13:31:51.000000000 -0700
+++ linux-265-kj1-rddunlap/net/ipv4/netfilter/ip_conntrack_irc.c	2004-04-05 13:31:51.000000000 -0700
@@ -60,8 +60,8 @@ DECLARE_LOCK(ip_irc_lock);
 struct module *ip_conntrack_irc = THIS_MODULE;
 
 #if 0
-#define DEBUGP(format, args...) printk(KERN_DEBUG __FILE__ ":" __FUNCTION__ \
-					":" format, ## args)
+#define DEBUGP(format, args...) printk(KERN_DEBUG "%s:%s:" format, \
+                                       __FILE__, __FUNCTION__ , ## args)
 #else
 #define DEBUGP(format, args...)
 #endif
diff -puN net/ipv4/netfilter/ip_conntrack_tftp.c~remove_concat_FUNCTION_net net/ipv4/netfilter/ip_conntrack_tftp.c
--- linux-265-kj1/net/ipv4/netfilter/ip_conntrack_tftp.c~remove_concat_FUNCTION_net	2004-04-05 13:31:51.000000000 -0700
+++ linux-265-kj1-rddunlap/net/ipv4/netfilter/ip_conntrack_tftp.c	2004-04-05 13:31:51.000000000 -0700
@@ -33,8 +33,8 @@ MODULE_PARM_DESC(ports, "port numbers of
 #endif
 
 #if 0
-#define DEBUGP(format, args...) printk(__FILE__ ":" __FUNCTION__ ": " \
-				       format, ## args)
+#define DEBUGP(format, args...) printk("%s:%s:" format, \
+                                       __FILE__, __FUNCTION__ , ## args)
 #else
 #define DEBUGP(format, args...)
 #endif
diff -puN net/ipv4/netfilter/ip_nat_tftp.c~remove_concat_FUNCTION_net net/ipv4/netfilter/ip_nat_tftp.c
--- linux-265-kj1/net/ipv4/netfilter/ip_nat_tftp.c~remove_concat_FUNCTION_net	2004-04-05 13:31:51.000000000 -0700
+++ linux-265-kj1-rddunlap/net/ipv4/netfilter/ip_nat_tftp.c	2004-04-05 13:31:51.000000000 -0700
@@ -47,8 +47,8 @@ MODULE_PARM_DESC(ports, "port numbers of
 #endif
 
 #if 0
-#define DEBUGP(format, args...) printk(__FILE__ ":" __FUNCTION__ ": " \
-				       format, ## args)
+#define DEBUGP(format, args...) printk("%s:%s:" format, \
+                                       __FILE__, __FUNCTION__ , ## args)
 #else
 #define DEBUGP(format, args...)
 #endif
diff -puN net/ipv4/netfilter/ipt_ULOG.c~remove_concat_FUNCTION_net net/ipv4/netfilter/ipt_ULOG.c
--- linux-265-kj1/net/ipv4/netfilter/ipt_ULOG.c~remove_concat_FUNCTION_net	2004-04-05 13:31:51.000000000 -0700
+++ linux-265-kj1-rddunlap/net/ipv4/netfilter/ipt_ULOG.c	2004-04-05 13:31:51.000000000 -0700
@@ -64,13 +64,13 @@ MODULE_DESCRIPTION("iptables userspace l
 #define ULOG_MAXNLGROUPS	32		/* numer of nlgroups */
 
 #if 0
-#define DEBUGP(format, args...)	printk(__FILE__ ":" __FUNCTION__ ":" \
-				       format, ## args)
+#define DEBUGP(format, args...) printk("%s:%s:" format, \
+                                       __FILE__, __FUNCTION__ , ## args)
 #else
 #define DEBUGP(format, args...)
 #endif
 
-#define PRINTR(format, args...) do { if (net_ratelimit()) printk(format, ## args); } while (0)
+#define PRINTR(format, args...) do { if (net_ratelimit()) printk(format , ## args); } while (0)
 
 static unsigned int nlbufsiz = 4096;
 MODULE_PARM(nlbufsiz, "i");

_
