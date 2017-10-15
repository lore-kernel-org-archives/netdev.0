From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: ceph: mark expected switch fall-throughs
Date: Sun, 15 Oct 2017 12:55:23 -0500
Message-ID: <20171015175523.GA4705@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ceph-devel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>,
        Sage Weil <sage@redhat.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/ceph/ceph_hash.c  | 12 +++++++++++-
 net/ceph/messenger.c  |  1 +
 net/ceph/mon_client.c |  1 +
 3 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/ceph/ceph_hash.c b/net/ceph/ceph_hash.c
index 67bb1f1..9a5850f2 100644
--- a/net/ceph/ceph_hash.c
+++ b/net/ceph/ceph_hash.c
@@ -47,28 +47,38 @@ unsigned int ceph_str_hash_rjenkins(const char *str, unsigned int length)
 
 	/* handle the last 11 bytes */
 	c = c + length;
-	switch (len) {            /* all the case statements fall through */
+	switch (len) {
 	case 11:
 		c = c + ((__u32)k[10] << 24);
+		/* fall through */
 	case 10:
 		c = c + ((__u32)k[9] << 16);
+		/* fall through */
 	case 9:
 		c = c + ((__u32)k[8] << 8);
 		/* the first byte of c is reserved for the length */
+		/* fall through */
 	case 8:
 		b = b + ((__u32)k[7] << 24);
+		/* fall through */
 	case 7:
 		b = b + ((__u32)k[6] << 16);
+		/* fall through */
 	case 6:
 		b = b + ((__u32)k[5] << 8);
+		/* fall through */
 	case 5:
 		b = b + k[4];
+		/* fall through */
 	case 4:
 		a = a + ((__u32)k[3] << 24);
+		/* fall through */
 	case 3:
 		a = a + ((__u32)k[2] << 16);
+		/* fall through */
 	case 2:
 		a = a + ((__u32)k[1] << 8);
+		/* fall through */
 	case 1:
 		a = a + k[0];
 		/* case 0: nothing left to add */
diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index a67298c..73dac9d 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -429,6 +429,7 @@ static void ceph_sock_state_change(struct sock *sk)
 	switch (sk->sk_state) {
 	case TCP_CLOSE:
 		dout("%s TCP_CLOSE\n", __func__);
+		/* fall through */
 	case TCP_CLOSE_WAIT:
 		dout("%s TCP_CLOSE_WAIT\n", __func__);
 		con_sock_state_closing(con);
diff --git a/net/ceph/mon_client.c b/net/ceph/mon_client.c
index 63edc6e..b97c047 100644
--- a/net/ceph/mon_client.c
+++ b/net/ceph/mon_client.c
@@ -1281,6 +1281,7 @@ static struct ceph_msg *mon_alloc_msg(struct ceph_connection *con,
 		 * request had a non-zero tid.  Workaround this weirdness
 		 * by falling through to the allocate case.
 		 */
+		/* fall through */
 	case CEPH_MSG_MON_MAP:
 	case CEPH_MSG_MDS_MAP:
 	case CEPH_MSG_OSD_MAP:
-- 
2.7.4
