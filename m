From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 03/21] userns: Convert sock_i_uid to return a kuid_t
Date: Mon, 13 Aug 2012 13:18:17 -0700
Message-ID: <1344889115-21610-3-git-send-email-ebiederm@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
	<1344889115-21610-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1344889115-21610-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/net/sock.h |    2 +-
 net/core/sock.c    |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index b373023..65c3d62 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1668,7 +1668,7 @@ static inline void sock_graft(struct sock *sk, struct socket *parent)
 	write_unlock_bh(&sk->sk_callback_lock);
 }
 
-extern int sock_i_uid(struct sock *sk);
+extern kuid_t sock_i_uid(struct sock *sk);
 extern unsigned long sock_i_ino(struct sock *sk);
 
 static inline struct dst_entry *
diff --git a/net/core/sock.c b/net/core/sock.c
index 9c7fe4f..5c6a435 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1526,12 +1526,12 @@ void sock_edemux(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sock_edemux);
 
-int sock_i_uid(struct sock *sk)
+kuid_t sock_i_uid(struct sock *sk)
 {
-	int uid;
+	kuid_t uid;
 
 	read_lock_bh(&sk->sk_callback_lock);
-	uid = sk->sk_socket ? SOCK_INODE(sk->sk_socket)->i_uid : 0;
+	uid = sk->sk_socket ? SOCK_INODE(sk->sk_socket)->i_uid : GLOBAL_ROOT_UID;
 	read_unlock_bh(&sk->sk_callback_lock);
 	return uid;
 }
-- 
1.7.5.4
