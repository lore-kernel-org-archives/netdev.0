From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking update: kconfig (1/5)
Date: Fri, 7 Feb 2003 02:13:09 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0302070211250.2174-100000@blackbird.intercode.com.au>
References: <Pine.LNX.4.44.0302070142050.2174-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-security-module@wirex.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
In-Reply-To: <Pine.LNX.4.44.0302070142050.2174-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 include/linux/security.h |   13 +++++++++----
 security/Kconfig         |    9 +++++++++
 security/dummy.c         |    5 +++++
 3 files changed, 23 insertions(+), 4 deletions(-)

diff -urN -X dontdiff linux-2.5.59.w0/include/linux/security.h linux-2.5.59.w1/include/linux/security.h
--- linux-2.5.59.w0/include/linux/security.h	Thu Jan 16 22:51:34 2003
+++ linux-2.5.59.w1/include/linux/security.h	Fri Feb  7 01:13:34 2003
@@ -63,16 +63,14 @@
 /* setfsuid or setfsgid, id0 == fsuid or fsgid */
 #define LSM_SETID_FS	8
 
-
-#ifdef CONFIG_SECURITY
-
 /* forward declares to avoid warnings */
 struct sk_buff;
-struct net_device;
 struct nfsctl_arg;
 struct sched_param;
 struct swap_info_struct;
 
+#ifdef CONFIG_SECURITY
+
 /**
  * struct security_operations - main security structure
  *
@@ -952,6 +950,9 @@
 	                          struct security_operations *ops);
 	int (*unregister_security) (const char *name,
 	                            struct security_operations *ops);
+
+#ifdef CONFIG_SECURITY_NETWORK
+#endif	/* CONFIG_SECURITY_NETWORK */
 };
 
 /* global variables */
@@ -2106,5 +2107,9 @@
 
 #endif	/* CONFIG_SECURITY */
 
+#ifdef CONFIG_SECURITY_NETWORK
+#else	/* CONFIG_SECURITY_NETWORK */
+#endif	/* CONFIG_SECURITY_NETWORK */
+
 #endif /* ! __LINUX_SECURITY_H */
 
diff -urN -X dontdiff linux-2.5.59.w0/security/Kconfig linux-2.5.59.w1/security/Kconfig
--- linux-2.5.59.w0/security/Kconfig	Tue Dec 24 23:31:09 2002
+++ linux-2.5.59.w1/security/Kconfig	Fri Feb  7 01:13:34 2003
@@ -15,6 +15,15 @@
 
 	  If you are unsure how to answer this question, answer N.
 
+config SECURITY_NETWORK
+	bool "Socket and Networking Security Hooks"
+	depends on SECURITY
+	help
+	  This enables the socket and networking security hooks.
+	  If enabled, a security module can use these hooks to
+	  implement socket and networking access controls.
+	  If you are unsure how to answer this question, answer N.
+
 config SECURITY_CAPABILITIES
 	tristate "Default Linux Capabilities"
 	depends on SECURITY!=n
diff -urN -X dontdiff linux-2.5.59.w0/security/dummy.c linux-2.5.59.w1/security/dummy.c
--- linux-2.5.59.w0/security/dummy.c	Thu Jan 16 22:51:35 2003
+++ linux-2.5.59.w1/security/dummy.c	Fri Feb  7 01:13:34 2003
@@ -597,6 +597,9 @@
 	return 0;
 }
 
+#ifdef CONFIG_SECURITY_NETWORK
+#endif	/* CONFIG_SECURITY_NETWORK */
+
 static int dummy_register_security (const char *name, struct security_operations *ops)
 {
 	return -EINVAL;
@@ -725,5 +728,7 @@
 	set_to_dummy_if_null(ops, sem_semop);
 	set_to_dummy_if_null(ops, register_security);
 	set_to_dummy_if_null(ops, unregister_security);
+#ifdef CONFIG_SECURITY_NETWORK
+#endif	/* CONFIG_SECURITY_NETWORK */
 }
 
