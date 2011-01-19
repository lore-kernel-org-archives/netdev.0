From: Ian Molton <ian.molton@collabora.co.uk>
Subject: [PATCH] af_unix: coding style: remove one level of indentation in unix_shutdown()
Date: Wed, 19 Jan 2011 14:56:36 +0000
Message-ID: <1295448997-9432-1-git-send-email-ian.molton@collabora.co.uk>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, ebiederm@xmission.com,
	xemul@openvz.org, davidel@xmailserver.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ian.molton@collabora.co.uk,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alban Crequy <alban.crequy@collabora.co.uk>

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Ian Molton <ian.molton@collabora.co.uk>
---
 net/unix/af_unix.c |   60 ++++++++++++++++++++++++++-------------------------
 1 files changed, 31 insertions(+), 29 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index dd419d2..7c45b93 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1978,36 +1978,38 @@ static int unix_shutdown(struct socket *sock, int mode)
 
 	mode = (mode+1)&(RCV_SHUTDOWN|SEND_SHUTDOWN);
 
-	if (mode) {
-		unix_state_lock(sk);
-		sk->sk_shutdown |= mode;
-		other = unix_peer(sk);
-		if (other)
-			sock_hold(other);
-		unix_state_unlock(sk);
-		sk->sk_state_change(sk);
-
-		if (other &&
-			(sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET)) {
-
-			int peer_mode = 0;
-
-			if (mode&RCV_SHUTDOWN)
-				peer_mode |= SEND_SHUTDOWN;
-			if (mode&SEND_SHUTDOWN)
-				peer_mode |= RCV_SHUTDOWN;
-			unix_state_lock(other);
-			other->sk_shutdown |= peer_mode;
-			unix_state_unlock(other);
-			other->sk_state_change(other);
-			if (peer_mode == SHUTDOWN_MASK)
-				sk_wake_async(other, SOCK_WAKE_WAITD, POLL_HUP);
-			else if (peer_mode & RCV_SHUTDOWN)
-				sk_wake_async(other, SOCK_WAKE_WAITD, POLL_IN);
-		}
-		if (other)
-			sock_put(other);
+	if (!mode)
+		return 0;
+
+	unix_state_lock(sk);
+	sk->sk_shutdown |= mode;
+	other = unix_peer(sk);
+	if (other)
+		sock_hold(other);
+	unix_state_unlock(sk);
+	sk->sk_state_change(sk);
+
+	if (other &&
+		(sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET)) {
+
+		int peer_mode = 0;
+
+		if (mode&RCV_SHUTDOWN)
+			peer_mode |= SEND_SHUTDOWN;
+		if (mode&SEND_SHUTDOWN)
+			peer_mode |= RCV_SHUTDOWN;
+		unix_state_lock(other);
+		other->sk_shutdown |= peer_mode;
+		unix_state_unlock(other);
+		other->sk_state_change(other);
+		if (peer_mode == SHUTDOWN_MASK)
+			sk_wake_async(other, SOCK_WAKE_WAITD, POLL_HUP);
+		else if (peer_mode & RCV_SHUTDOWN)
+			sk_wake_async(other, SOCK_WAKE_WAITD, POLL_IN);
 	}
+	if (other)
+		sock_put(other);
+
 	return 0;
 }
 
-- 
1.7.2.3
