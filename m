From: akpm@linux-foundation.org
Subject: [patch 4/4] bluetooth: replace deprecated RW_LOCK_UNLOCKED macros
Date: Fri, 28 Mar 2008 14:37:31 -0700
Message-ID: <200803282137.m2SLbVuZ011635@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	rpjday@crashcourse.ca, hidave.darkstar@gmail.com,
	marcel@holtmann.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38398 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755141AbYC1Vhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:37:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Robert P. J. Day" <rpjday@crashcourse.ca>

The older RW_LOCK_UNLOCKED macros defeat lockdep state tracing so replace them
with the newer __RW_LOCK_UNLOCKED macros.

Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>
Acked-by: Marcel Holtmann <marcel@holtmann.org>
Cc: Dave Young <hidave.darkstar@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/bluetooth/hci_sock.c    |    2 +-
 net/bluetooth/l2cap.c       |    2 +-
 net/bluetooth/rfcomm/sock.c |    2 +-
 net/bluetooth/sco.c         |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff -puN net/bluetooth/hci_sock.c~bluetooth-replace-deprecated-rw_lock_unlocked-macros net/bluetooth/hci_sock.c
--- a/net/bluetooth/hci_sock.c~bluetooth-replace-deprecated-rw_lock_unlocked-macros
+++ a/net/bluetooth/hci_sock.c
@@ -84,7 +84,7 @@ static struct hci_sec_filter hci_sec_fil
 };
 
 static struct bt_sock_list hci_sk_list = {
-	.lock = RW_LOCK_UNLOCKED
+	.lock = __RW_LOCK_UNLOCKED(hci_sk_list.lock)
 };
 
 /* Send frame to RAW socket */
diff -puN net/bluetooth/l2cap.c~bluetooth-replace-deprecated-rw_lock_unlocked-macros net/bluetooth/l2cap.c
--- a/net/bluetooth/l2cap.c~bluetooth-replace-deprecated-rw_lock_unlocked-macros
+++ a/net/bluetooth/l2cap.c
@@ -62,7 +62,7 @@ static u32 l2cap_feat_mask = 0x0000;
 static const struct proto_ops l2cap_sock_ops;
 
 static struct bt_sock_list l2cap_sk_list = {
-	.lock = RW_LOCK_UNLOCKED
+	.lock = __RW_LOCK_UNLOCKED(l2cap_sk_list.lock)
 };
 
 static void __l2cap_sock_close(struct sock *sk, int reason);
diff -puN net/bluetooth/rfcomm/sock.c~bluetooth-replace-deprecated-rw_lock_unlocked-macros net/bluetooth/rfcomm/sock.c
--- a/net/bluetooth/rfcomm/sock.c~bluetooth-replace-deprecated-rw_lock_unlocked-macros
+++ a/net/bluetooth/rfcomm/sock.c
@@ -60,7 +60,7 @@
 static const struct proto_ops rfcomm_sock_ops;
 
 static struct bt_sock_list rfcomm_sk_list = {
-	.lock = RW_LOCK_UNLOCKED
+	.lock = __RW_LOCK_UNLOCKED(rfcomm_sk_list.lock)
 };
 
 static void rfcomm_sock_close(struct sock *sk);
diff -puN net/bluetooth/sco.c~bluetooth-replace-deprecated-rw_lock_unlocked-macros net/bluetooth/sco.c
--- a/net/bluetooth/sco.c~bluetooth-replace-deprecated-rw_lock_unlocked-macros
+++ a/net/bluetooth/sco.c
@@ -58,7 +58,7 @@
 static const struct proto_ops sco_sock_ops;
 
 static struct bt_sock_list sco_sk_list = {
-	.lock = RW_LOCK_UNLOCKED
+	.lock = __RW_LOCK_UNLOCKED(sco_sk_list.lock)
 };
 
 static void __sco_chan_add(struct sco_conn *conn, struct sock *sk, struct sock *parent);
_
