From: andrew hendry <andrew.hendry@gmail.com>
Subject: [RESEND PATCH 1/3] X25: Move SYSCTL ifdefs into header
Date: Tue, 15 Dec 2009 09:02:11 +1100
Message-ID: <d45a3acc0912141402v69ea4ccet143f8ef7bc04e585@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932611AbZLNWCO@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Moves the CONFIG_SYSCTL ifdefs in x25_init into header.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

diff -uprN -X a/Documentation/dontdiff a/include/net/x25.h b/include/net/x25.h
--- a/include/net/x25.h	2009-11-10 11:32:31.000000000 +1100
+++ b/include/net/x25.h	2009-11-25 09:05:21.000000000 +1100
@@ -287,8 +287,14 @@ extern unsigned long x25_display_timer(s
 extern void x25_check_rbuf(struct sock *);

 /* sysctl_net_x25.c */
+#ifdef CONFIG_SYSCTL
 extern void x25_register_sysctl(void);
 extern void x25_unregister_sysctl(void);
+#else
+static inline void x25_register_sysctl(void) {};
+static inline void x25_unregister_sysctl(void) {};
+#endif /* CONFIG_SYSCTL */
+
 struct x25_skb_cb {
 	unsigned flags;
 };
diff -uprN -X a/Documentation/dontdiff a/net/x25/af_x25.c b/net/x25/af_x25.c
--- a/net/x25/af_x25.c	2009-11-17 10:30:18.000000000 +1100
+++ b/net/x25/af_x25.c	2009-11-25 09:04:25.000000000 +1100
@@ -1667,9 +1667,7 @@ static int __init x25_init(void)

 	printk(KERN_INFO "X.25 for Linux Version 0.2\n");

-#ifdef CONFIG_SYSCTL
 	x25_register_sysctl();
-#endif
 	x25_proc_init();
 out:
 	return rc;
@@ -1682,9 +1680,7 @@ static void __exit x25_exit(void)
 	x25_link_free();
 	x25_route_free();

-#ifdef CONFIG_SYSCTL
 	x25_unregister_sysctl();
-#endif

 	unregister_netdevice_notifier(&x25_dev_notifier);
