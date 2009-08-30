From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 39/47] Bluetooth: Fix rejected connection not disconnecting ACL link
Date: Sun, 30 Aug 2009 01:50:53 -0700
Message-ID: <9e726b17422bade75fba94e625cd35fd1353e682.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
 <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
 <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
 <789221ecc870117b77e354d488d5d29f15410de8.1251621661.git.marcel@holtmann.org>
 <fb784f0508d5aa39a23e72879a8dfb517c6f6e7f.1251621661.git.marcel@holtmann.org>
 <196be0cd018068d545e1d764094c7b07aaf0bcfe.1251621661.git.marcel@holtmann.org>
 <e7a25f9839fd392ec2c96e7e2b3734501d761a24.1251621661.git.marcel@holtmann.org>
 <08b0b0ce8c609b0e2284b134f0614e211374a038.1251621661.git.marcel@holtmann.org>
 <944fe798c6a48336e82bbc0d4e280587325a4d95.1251621661.git.marcel@holtmann.org>
 <542399037d0cb2b2e96dfb8ced35b07dfb1c3706.1251621661.git.marcel@holtmann.org>
 <4271e08d8b799171af18d7864908ec444282efe5.1251621661.git.marcel@holtmann.org>
 <dcf47f3bc798888f9ea40b9f626d669dc62086bf.1251621661.git.marcel@holtmann.org>
 <9666fb356da78a5ec28403197d72e8cd6aa16424.1251621661.git.marcel@holtmann.org>
 <60dee5ccd789ee8a380eee802b6cb24c52123428.1251621661.git.marcel@holtmann.org>
 <91d697302b291205171840bfe84c1563e171acb2.1251621661.git.marcel@holtmann.org>
 <e0721f99ba33d13a88746732be2d74ca805abf55.1251621661.git.marcel@holtmann.org>
 <9374253ffe609f2d70dd5ae280182cb6f08fef08.1251621661.git.marcel@holtmann.org>
 <3318b2362bf0528be77123c480249663557dfbfc.1251621661.git.marcel@holtmann.org>
 <5959809ded86e267c1a95fb44738a224c30d3434.1251621661.git.marcel@holtmann.org>
 <a6a67efd7088702fdbbb780c5a3f8e1a74e77b63.1251621661.git.marcel@holtmann.org>
 <52d18347dfb61519aa0f58fe1759edd3ad8c4e36.1251621661.git.marcel@holtmann.org>
 <44dd46de325c4d47abfd1361e5d84a548edb8e42.1251621661.git.marcel@holtmann.org>
 <c6b03cf986eab00e20d0dbc852b233bb83472138.1251621661.git.marcel@holtmann.org>
 <65c7c4918450f8c4545ccb02a9c7a3d77e073535.1251621661.git.marcel@holtmann.org>
 <f2fcfcd670257236ebf2088bbdf26f6a8ef459fe.1251621661.git.marcel@holtmann.org>
 <22121fc9152ca8f25a2d790860832ccb6a414c4d.1251621661.git.marcel@holtmann.org>
 <1c2acffb76d4bc5fd27c4ea55cc27ad8ead10f9a.1251621661.git.marcel@holtmann.org>
 <c74e560cd0101455f1889515e1527e4c2e266113.1251621661.git.marcel@holtmann.org>
 <30afb5b2aa83adf4f69e5090d48e1bb04b64c58a.1251621661.git.marcel@holtmann.org>
 <e90bac061b17cd81bd0df30606c64f4543bf5ca0.1251621661.git.marcel@holtmann.org>
 <6840ed0770d79b9bb0800e5e026a067040ef18f5.1251621661.git.marcel@holtmann.org>
 <fcc203c30d72dde82692f6b761a80e5ca5fdd8fa.1251621661.git.marcel@holtmann.org>
 <8f17154f1f70fcc6faa31ac82164fcf7f0599f38.1251621661.git.marcel@holtmann.org>
 <ef54fd937fbd5ebaeb023818524565bd526a5f36.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53333 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbZH3Iwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:37 -0400
In-Reply-To: <ef54fd937fbd5ebaeb023818524565bd526a5f36.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luiz Augusto von Dentz <luiz.dentz@openbossa.org>

When using DEFER_SETUP on a RFCOMM socket, a SABM frame triggers
authorization which when rejected send a DM response. This is fine
according to the RFCOMM spec:

    the responding implementation may replace the "proper" response
    on the Multiplexer Control channel with a DM frame, sent on the
    referenced DLCI to indicate that the DLCI is not open, and that
    the responder would not grant a request to open it later either.

But some stacks doesn't seems to cope with this leaving DLCI 0 open after
receiving DM frame.

To fix it properly a timer was introduced to rfcomm_session which is used
to set a timeout when the last active DLC of a session is unlinked, this
will give the remote stack some time to reply with a proper DISC frame on
DLCI 0 avoiding both sides sending DISC to each other on stacks that
follow the specification and taking care of those who don't by taking
down DLCI 0.

Signed-off-by: Luiz Augusto von Dentz <luiz.dentz@openbossa.org>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/rfcomm.h |    2 +
 net/bluetooth/rfcomm/core.c    |   41 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/include/net/bluetooth/rfcomm.h b/include/net/bluetooth/rfcomm.h
index c274993..921d7b3 100644
--- a/include/net/bluetooth/rfcomm.h
+++ b/include/net/bluetooth/rfcomm.h
@@ -29,6 +29,7 @@
 #define RFCOMM_CONN_TIMEOUT (HZ * 30)
 #define RFCOMM_DISC_TIMEOUT (HZ * 20)
 #define RFCOMM_AUTH_TIMEOUT (HZ * 25)
+#define RFCOMM_IDLE_TIMEOUT (HZ * 2)
 
 #define RFCOMM_DEFAULT_MTU	127
 #define RFCOMM_DEFAULT_CREDITS	7
@@ -154,6 +155,7 @@ struct rfcomm_msc {
 struct rfcomm_session {
 	struct list_head list;
 	struct socket   *sock;
+	struct timer_list timer;
 	unsigned long    state;
 	unsigned long    flags;
 	atomic_t         refcnt;
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 26af485..25692bc 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -244,6 +244,33 @@ static inline int rfcomm_check_security(struct rfcomm_dlc *d)
 								auth_type);
 }
 
+static void rfcomm_session_timeout(unsigned long arg)
+{
+	struct rfcomm_session *s = (void *) arg;
+
+	BT_DBG("session %p state %ld", s, s->state);
+
+	set_bit(RFCOMM_TIMED_OUT, &s->flags);
+	rfcomm_session_put(s);
+	rfcomm_schedule(RFCOMM_SCHED_TIMEO);
+}
+
+static void rfcomm_session_set_timer(struct rfcomm_session *s, long timeout)
+{
+	BT_DBG("session %p state %ld timeout %ld", s, s->state, timeout);
+
+	if (!mod_timer(&s->timer, jiffies + timeout))
+		rfcomm_session_hold(s);
+}
+
+static void rfcomm_session_clear_timer(struct rfcomm_session *s)
+{
+	BT_DBG("session %p state %ld", s, s->state);
+
+	if (timer_pending(&s->timer) && del_timer(&s->timer))
+		rfcomm_session_put(s);
+}
+
 /* ---- RFCOMM DLCs ---- */
 static void rfcomm_dlc_timeout(unsigned long arg)
 {
@@ -320,6 +347,7 @@ static void rfcomm_dlc_link(struct rfcomm_session *s, struct rfcomm_dlc *d)
 
 	rfcomm_session_hold(s);
 
+	rfcomm_session_clear_timer(s);
 	rfcomm_dlc_hold(d);
 	list_add(&d->list, &s->dlcs);
 	d->session = s;
@@ -335,6 +363,9 @@ static void rfcomm_dlc_unlink(struct rfcomm_dlc *d)
 	d->session = NULL;
 	rfcomm_dlc_put(d);
 
+	if (list_empty(&s->dlcs))
+		rfcomm_session_set_timer(s, RFCOMM_IDLE_TIMEOUT);
+
 	rfcomm_session_put(s);
 }
 
@@ -567,6 +598,8 @@ static struct rfcomm_session *rfcomm_session_add(struct socket *sock, int state)
 
 	BT_DBG("session %p sock %p", s, sock);
 
+	setup_timer(&s->timer, rfcomm_session_timeout, (unsigned long) s);
+
 	INIT_LIST_HEAD(&s->dlcs);
 	s->state = state;
 	s->sock  = sock;
@@ -598,6 +631,7 @@ static void rfcomm_session_del(struct rfcomm_session *s)
 	if (state == BT_CONNECTED)
 		rfcomm_send_disc(s, 0);
 
+	rfcomm_session_clear_timer(s);
 	sock_release(s->sock);
 	kfree(s);
 
@@ -639,6 +673,7 @@ static void rfcomm_session_close(struct rfcomm_session *s, int err)
 		__rfcomm_dlc_close(d, err);
 	}
 
+	rfcomm_session_clear_timer(s);
 	rfcomm_session_put(s);
 }
 
@@ -1879,6 +1914,12 @@ static inline void rfcomm_process_sessions(void)
 		struct rfcomm_session *s;
 		s = list_entry(p, struct rfcomm_session, list);
 
+		if (test_and_clear_bit(RFCOMM_TIMED_OUT, &s->flags)) {
+			s->state = BT_DISCONN;
+			rfcomm_send_disc(s, 0);
+			continue;
+		}
+
 		if (s->state == BT_LISTEN) {
 			rfcomm_accept_connection(s);
 			continue;
-- 
1.6.2.5

