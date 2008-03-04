From: akpm@linux-foundation.org
Subject: [patch 1/2] bluetooth: Make hci_sock_cleanup() return void
Date: Tue, 04 Mar 2008 15:18:22 -0800
Message-ID: <200803042318.m24NIMum002602@imap1.linux-foundation.org>
Cc: marcel@holtmann.org, hidave.darkstar@gmail.com,
	netdev@vger.kernel.org, linux-bluetooth@vger.kerenl.org,
	akpm@linux-foundation.org, tklauser@distanz.ch
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43559 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935039AbYCDXTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:19:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>

hci_sock_cleanup() always returns 0 and its return value isn't used
anywhere in the code.

Compile-tested with 'make allyesconfig && make net/bluetooth/bluetooth.ko'

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Dave Young <hidave.darkstar@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/net/bluetooth/bluetooth.h |    2 +-
 net/bluetooth/hci_sock.c          |    4 +---
 2 files changed, 2 insertions(+), 4 deletions(-)

diff -puN include/net/bluetooth/bluetooth.h~bluetooth-make-hci_sock_cleanup-return-void include/net/bluetooth/bluetooth.h
--- a/include/net/bluetooth/bluetooth.h~bluetooth-make-hci_sock_cleanup-return-void
+++ a/include/net/bluetooth/bluetooth.h
@@ -170,7 +170,7 @@ static inline int skb_frags_no(struct sk
 int bt_err(__u16 code);
 
 extern int hci_sock_init(void);
-extern int hci_sock_cleanup(void);
+extern void hci_sock_cleanup(void);
 
 extern int bt_sysfs_init(void);
 extern void bt_sysfs_cleanup(void);
diff -puN net/bluetooth/hci_sock.c~bluetooth-make-hci_sock_cleanup-return-void net/bluetooth/hci_sock.c
--- a/net/bluetooth/hci_sock.c~bluetooth-make-hci_sock_cleanup-return-void
+++ a/net/bluetooth/hci_sock.c
@@ -734,7 +734,7 @@ error:
 	return err;
 }
 
-int __exit hci_sock_cleanup(void)
+void __exit hci_sock_cleanup(void)
 {
 	if (bt_sock_unregister(BTPROTO_HCI) < 0)
 		BT_ERR("HCI socket unregistration failed");
@@ -742,6 +742,4 @@ int __exit hci_sock_cleanup(void)
 	hci_unregister_notifier(&hci_sock_nblock);
 
 	proto_unregister(&hci_sk_proto);
-
-	return 0;
 }
_
