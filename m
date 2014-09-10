From: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v2 1/2] skb: Add documentation for skb_clone_sk
Date: Wed, 10 Sep 2014 18:05:26 -0400
Message-ID: <20140910220448.23225.39224.stgit@ahduyck-bv4.jf.intel.com>
References: <20140910215837.23225.39149.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140910215837.23225.39149.stgit-+uVpp3jiz/QKn9AQLGuxw7vm/XP+8Wra@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This change adds some documentation to the call skb_clone_sk.  This is
meant to help clarify the purpose of the function for other developers.

Signed-off-by: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---

v2: Updated comments to specifically call out need for sock_hold/sock_put

 net/core/skbuff.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a18dfb0..c9da77a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3511,6 +3511,19 @@ struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
 }
 EXPORT_SYMBOL(sock_dequeue_err_skb);
 
+/**
+ * skb_clone_sk - create clone of skb, and take reference to socket
+ * @skb: the skb to clone
+ *
+ * This function creates a clone of a buffer that holds a reference on
+ * sk_refcnt.  Buffers created via this function are meant to be
+ * returned using sock_queue_err_skb, or free via kfree_skb.
+ *
+ * When passing buffers allocated with this function to sock_queue_err_skb
+ * it is necessary to wrap the call with sock_hold/sock_put in order to
+ * prevent the socket from being released prior to being enqueued on
+ * the sk_error_queue.
+ */
 struct sk_buff *skb_clone_sk(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
