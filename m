From: santosh nayak <santoshprasadnayak@gmail.com>
Subject: [PATCH] Bluetooth: Silence static checker warning.
Date: Wed, 29 Feb 2012 22:36:57 +0530
Message-ID: <1330535217-26785-1-git-send-email-santoshprasadnayak@gmail.com>
Cc: padovan@profusion.mobi, davem@davemloft.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Santosh Nayak <santoshprasadnayak@gmail.com>
To: marcel@holtmann.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Nayak <santoshprasadnayak@gmail.com>

Silencing Static checker warning.
1. Endian warning
2. variable dereferenced before check 'sk' .

Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
---
 net/bluetooth/l2cap_sock.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 401d942..d206321 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -82,7 +82,7 @@ static int l2cap_sock_bind(struct socket *sock, struct sockaddr *addr, int alen)
 	}
 
 	if (la.l2_cid)
-		err = l2cap_add_scid(chan, la.l2_cid);
+		err = l2cap_add_scid(chan, __le16_to_cpu(la.l2_cid));
 	else
 		err = l2cap_add_psm(chan, &la.l2_bdaddr, la.l2_psm);
 
@@ -123,7 +123,8 @@ static int l2cap_sock_connect(struct socket *sock, struct sockaddr *addr, int al
 	if (la.l2_cid && la.l2_psm)
 		return -EINVAL;
 
-	err = l2cap_chan_connect(chan, la.l2_psm, la.l2_cid, &la.l2_bdaddr);
+	err = l2cap_chan_connect(chan, la.l2_psm, __le16_to_cpu(la.l2_cid),
+				&la.l2_bdaddr);
 	if (err)
 		goto done;
 
@@ -795,7 +796,7 @@ static void l2cap_sock_kill(struct sock *sk)
 static int l2cap_sock_shutdown(struct socket *sock, int how)
 {
 	struct sock *sk = sock->sk;
-	struct l2cap_chan *chan = l2cap_pi(sk)->chan;
+	struct l2cap_chan *chan;
 	int err = 0;
 
 	BT_DBG("sock %p, sk %p", sock, sk);
@@ -803,6 +804,8 @@ static int l2cap_sock_shutdown(struct socket *sock, int how)
 	if (!sk)
 		return 0;
 
+	chan = l2cap_pi(sk)->chan;
+
 	lock_sock(sk);
 	if (!sk->sk_shutdown) {
 		if (chan->mode == L2CAP_MODE_ERTM)
-- 
1.7.4.4
