From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: [PATCH] BLUETOOTH:  Replace deprecated RW_LOCK_UNLOCKED macros.
Date: Thu, 20 Mar 2008 11:05:08 -0400 (EDT)
Message-ID: <alpine.LFD.1.00.0803201100440.6369@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Andrew Morton <akpm@osdl.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:55964 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825AbYCTPFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 11:05:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The older RW_LOCK_UNLOCKED macros defeat lockdep state tracing so
replace them with the newer __RW_LOCK_UNLOCKED macros.

Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>
Acked-by: Marcel Holtmann <marcel@holtmann.org>

---

  not compile tested, but the transformation seems pretty
straightforward.  also, marcel specifically told me to add his Ack and
post to netdev, as he's apparently swamped with bluez work, so whoever
is appropriate can deal with this however they see fit.

 net/bluetooth/hci_sock.c    |    2 +-
 net/bluetooth/l2cap.c       |    2 +-
 net/bluetooth/rfcomm/sock.c |    2 +-
 net/bluetooth/sco.c         |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index b5d4019..1d36c09 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -84,7 +84,7 @@ static struct hci_sec_filter hci_sec_filter = {
 };

 static struct bt_sock_list hci_sk_list = {
-	.lock = RW_LOCK_UNLOCKED
+	.lock = __RW_LOCK_UNLOCKED(hci_sk_list.lock)
 };

 /* Send frame to RAW socket */
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 34f8bf9..2957df4 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -62,7 +62,7 @@ static u32 l2cap_feat_mask = 0x0000;
 static const struct proto_ops l2cap_sock_ops;

 static struct bt_sock_list l2cap_sk_list = {
-	.lock = RW_LOCK_UNLOCKED
+	.lock = __RW_LOCK_UNLOCKED(l2cap_sk_list.lock)
 };

 static void __l2cap_sock_close(struct sock *sk, int reason);
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index c46d510..af4e393 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -60,7 +60,7 @@
 static const struct proto_ops rfcomm_sock_ops;

 static struct bt_sock_list rfcomm_sk_list = {
-	.lock = RW_LOCK_UNLOCKED
+	.lock = __RW_LOCK_UNLOCKED(rfcomm_sk_list.lock)
 };

 static void rfcomm_sock_close(struct sock *sk);
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index b91d3c8..cd887cd 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -58,7 +58,7 @@
 static const struct proto_ops sco_sock_ops;

 static struct bt_sock_list sco_sk_list = {
-	.lock = RW_LOCK_UNLOCKED
+	.lock = __RW_LOCK_UNLOCKED(sco_sk_list.lock)
 };

 static void __sco_chan_add(struct sco_conn *conn, struct sock *sk, struct sock *parent);


========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry:
    Have classroom, will lecture.

http://crashcourse.ca                          Waterloo, Ontario, CANADA
========================================================================
