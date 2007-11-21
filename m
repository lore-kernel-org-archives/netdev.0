From: akpm@linux-foundation.org
Subject: [patch 2/5] bluetooth: uninlining
Date: Wed, 21 Nov 2007 15:03:57 -0800
Message-ID: <200711212303.lALN3vqT013720@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55791 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753204AbXKUXET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 18:04:19 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

Remove all those inlines which were either a) unneeded or b) increased code
size.

          text    data     bss     dec     hex filename
before:   6997      74       8    7079    1ba7 net/bluetooth/hidp/core.o
after:    6492      74       8    6574    19ae net/bluetooth/hidp/core.o

Cc: Marcel Holtmann <marcel@holtmann.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/bluetooth/hidp/core.c |   30 +++++++++++++++++++-----------
 1 file changed, 19 insertions(+), 11 deletions(-)

diff -puN net/bluetooth/hidp/core.c~bluetooth-uninlining net/bluetooth/hidp/core.c
--- a/net/bluetooth/hidp/core.c~bluetooth-uninlining
+++ a/net/bluetooth/hidp/core.c
@@ -135,8 +135,8 @@ static void __hidp_copy_session(struct h
 	}
 }
 
-static inline int hidp_queue_event(struct hidp_session *session, struct input_dev *dev,
-					unsigned int type, unsigned int code, int value)
+static int hidp_queue_event(struct hidp_session *session, struct input_dev *dev,
+				unsigned int type, unsigned int code, int value)
 {
 	unsigned char newleds;
 	struct sk_buff *skb;
@@ -243,7 +243,8 @@ static void hidp_input_report(struct hid
 	input_sync(dev);
 }
 
-static inline int hidp_queue_report(struct hidp_session *session, unsigned char *data, int size)
+static int hidp_queue_report(struct hidp_session *session,
+				unsigned char *data, int size)
 {
 	struct sk_buff *skb;
 
@@ -287,7 +288,7 @@ static void hidp_idle_timeout(unsigned l
 	hidp_schedule(session);
 }
 
-static inline void hidp_set_timer(struct hidp_session *session)
+static void hidp_set_timer(struct hidp_session *session)
 {
 	if (session->idle_to > 0)
 		mod_timer(&session->timer, jiffies + HZ * session->idle_to);
@@ -332,7 +333,8 @@ static inline int hidp_send_ctrl_message
 	return err;
 }
 
-static inline void hidp_process_handshake(struct hidp_session *session, unsigned char param)
+static void hidp_process_handshake(struct hidp_session *session,
+					unsigned char param)
 {
 	BT_DBG("session %p param 0x%02x", session, param);
 
@@ -365,7 +367,8 @@ static inline void hidp_process_handshak
 	}
 }
 
-static inline void hidp_process_hid_control(struct hidp_session *session, unsigned char param)
+static void hidp_process_hid_control(struct hidp_session *session,
+					unsigned char param)
 {
 	BT_DBG("session %p param 0x%02x", session, param);
 
@@ -379,7 +382,8 @@ static inline void hidp_process_hid_cont
 	}
 }
 
-static inline void hidp_process_data(struct hidp_session *session, struct sk_buff *skb, unsigned char param)
+static void hidp_process_data(struct hidp_session *session, struct sk_buff *skb,
+				unsigned char param)
 {
 	BT_DBG("session %p skb %p len %d param 0x%02x", session, skb, skb->len, param);
 
@@ -406,7 +410,8 @@ static inline void hidp_process_data(str
 	}
 }
 
-static inline void hidp_recv_ctrl_frame(struct hidp_session *session, struct sk_buff *skb)
+static void hidp_recv_ctrl_frame(struct hidp_session *session,
+					struct sk_buff *skb)
 {
 	unsigned char hdr, type, param;
 
@@ -440,7 +445,8 @@ static inline void hidp_recv_ctrl_frame(
 	kfree_skb(skb);
 }
 
-static inline void hidp_recv_intr_frame(struct hidp_session *session, struct sk_buff *skb)
+static void hidp_recv_intr_frame(struct hidp_session *session,
+				struct sk_buff *skb)
 {
 	unsigned char hdr;
 
@@ -608,7 +614,8 @@ static struct device *hidp_get_device(st
 	return conn ? &conn->dev : NULL;
 }
 
-static inline int hidp_setup_input(struct hidp_session *session, struct hidp_connadd_req *req)
+static int hidp_setup_input(struct hidp_session *session,
+				struct hidp_connadd_req *req)
 {
 	struct input_dev *input = session->input;
 	int i;
@@ -685,7 +692,8 @@ static void hidp_setup_quirks(struct hid
 			hid->quirks = hidp_blacklist[n].quirks;
 }
 
-static inline void hidp_setup_hid(struct hidp_session *session, struct hidp_connadd_req *req)
+static void hidp_setup_hid(struct hidp_session *session,
+				struct hidp_connadd_req *req)
 {
 	struct hid_device *hid = session->hid;
 	struct hid_report *report;
_
