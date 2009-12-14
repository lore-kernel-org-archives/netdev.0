From: andrew hendry <andrew.hendry@gmail.com>
Subject: [RESEND PATCH 2/3] X25: Check for errors in x25_init
Date: Tue, 15 Dec 2009 09:02:55 +1100
Message-ID: <d45a3acc0912141402j69fea90ew9a28f535b5d9cee1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758557AbZLNWDH@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds error checking to x25_init.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

diff -uprN -X a/Documentation/dontdiff a/net/x25/af_x25.c b/net/x25/af_x25.c
--- a/net/x25/af_x25.c  2009-11-25 10:21:17.000000000 +1100
+++ b/net/x25/af_x25.c  2009-11-25 10:22:06.000000000 +1100
@@ -1659,18 +1659,31 @@ static int __init x25_init(void)
 	if (rc != 0)
 		goto out;

-	sock_register(&x25_family_ops);
+	rc = sock_register(&x25_family_ops);
+	if (rc != 0)
+		goto out_proto;

 	dev_add_pack(&x25_packet_type);

-	register_netdevice_notifier(&x25_dev_notifier);
+	rc = register_netdevice_notifier(&x25_dev_notifier);
+	if (rc != 0)
+		goto out_sock;

 	printk(KERN_INFO "X.25 for Linux Version 0.2\n");

 	x25_register_sysctl();
-	x25_proc_init();
+	rc = x25_proc_init();
+	if (rc != 0)
+		goto out_dev;
 out:
 	return rc;
+out_dev:
+	unregister_netdevice_notifier(&x25_dev_notifier);
+out_sock:
+	sock_unregister(AF_X25);
+out_proto:
+	proto_unregister(&x25_proto);
+	goto out;
 }
 module_init(x25_init);
