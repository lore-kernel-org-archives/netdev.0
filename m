From: akpm@linux-foundation.org
Subject: [patch 2/2] bluetooth: make bnep_sock_cleanup() return void
Date: Tue, 04 Mar 2008 15:18:24 -0800
Message-ID: <200803042318.m24NIOc3002607@imap1.linux-foundation.org>
Cc: marcel@holtmann.org, hidave.darkstar@gmail.com,
	netdev@vger.kernel.org, linux-bluetooth@vger.kerenl.org,
	akpm@linux-foundation.org, tklauser@distanz.ch
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41960 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935030AbYCDXTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:19:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>

bnep_sock_cleanup() always returns 0 and its return value isn't used
anywhere in the code.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Dave Young <hidave.darkstar@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/bluetooth/bnep/bnep.h |    2 +-
 net/bluetooth/bnep/sock.c |    4 +---
 2 files changed, 2 insertions(+), 4 deletions(-)

diff -puN net/bluetooth/bnep/bnep.h~bluetooth-make-bnep_sock_cleanup-return-void net/bluetooth/bnep/bnep.h
--- a/net/bluetooth/bnep/bnep.h~bluetooth-make-bnep_sock_cleanup-return-void
+++ a/net/bluetooth/bnep/bnep.h
@@ -174,7 +174,7 @@ struct bnep_session {
 
 void bnep_net_setup(struct net_device *dev);
 int bnep_sock_init(void);
-int bnep_sock_cleanup(void);
+void bnep_sock_cleanup(void);
 
 static inline int bnep_mc_hash(__u8 *addr)
 {
diff -puN net/bluetooth/bnep/sock.c~bluetooth-make-bnep_sock_cleanup-return-void net/bluetooth/bnep/sock.c
--- a/net/bluetooth/bnep/sock.c~bluetooth-make-bnep_sock_cleanup-return-void
+++ a/net/bluetooth/bnep/sock.c
@@ -257,12 +257,10 @@ error:
 	return err;
 }
 
-int __exit bnep_sock_cleanup(void)
+void __exit bnep_sock_cleanup(void)
 {
 	if (bt_sock_unregister(BTPROTO_BNEP) < 0)
 		BT_ERR("Can't unregister BNEP socket");
 
 	proto_unregister(&bnep_proto);
-
-	return 0;
 }
_
