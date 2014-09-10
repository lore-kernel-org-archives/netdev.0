From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/5] ceph: Convert pr_warning to pr_warn
Date: Tue,  9 Sep 2014 21:17:29 -0700
Message-ID: <714b7551f5a6ea5e721fed705568a39eeae4623b.1410322181.git.joe@perches.com>
References: <cover.1410322181.git.joe@perches.com>
Cc: Sage Weil <sage@inktank.com>,
	"David S. Miller" <davem@davemloft.net>,
	ceph-devel@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1410322181.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the more common pr_warn.

Other miscellanea:

o Coalesce formats
o Realign arguments

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ceph/ceph_common.c | 15 +++++++++------
 net/ceph/messenger.c   | 19 ++++++++++---------
 net/ceph/osd_client.c  | 15 +++++++--------
 net/ceph/osdmap.c      | 20 ++++++++++----------
 4 files changed, 36 insertions(+), 33 deletions(-)

diff --git a/net/ceph/ceph_common.c b/net/ceph/ceph_common.c
index 1675021..58fbfe1 100644
--- a/net/ceph/ceph_common.c
+++ b/net/ceph/ceph_common.c
@@ -293,17 +293,20 @@ static int get_secret(struct ceph_crypto_key *dst, const char *name) {
 		key_err = PTR_ERR(ukey);
 		switch (key_err) {
 		case -ENOKEY:
-			pr_warning("ceph: Mount failed due to key not found: %s\n", name);
+			pr_warn("ceph: Mount failed due to key not found: %s\n",
+				name);
 			break;
 		case -EKEYEXPIRED:
-			pr_warning("ceph: Mount failed due to expired key: %s\n", name);
+			pr_warn("ceph: Mount failed due to expired key: %s\n",
+				name);
 			break;
 		case -EKEYREVOKED:
-			pr_warning("ceph: Mount failed due to revoked key: %s\n", name);
+			pr_warn("ceph: Mount failed due to revoked key: %s\n",
+				name);
 			break;
 		default:
-			pr_warning("ceph: Mount failed due to unknown key error"
-			       " %d: %s\n", key_err, name);
+			pr_warn("ceph: Mount failed due to unknown key error %d: %s\n",
+				key_err, name);
 		}
 		err = -EPERM;
 		goto out;
@@ -433,7 +436,7 @@ ceph_parse_options(char *options, const char *dev_name,
 
 			/* misc */
 		case Opt_osdtimeout:
-			pr_warning("ignoring deprecated osdtimeout option\n");
+			pr_warn("ignoring deprecated osdtimeout option\n");
 			break;
 		case Opt_osdkeepalivetimeout:
 			opt->osd_keepalive_timeout = intval;
diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index b2f571d..a7203be 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -1937,11 +1937,11 @@ static int process_banner(struct ceph_connection *con)
 		   sizeof(con->peer_addr)) != 0 &&
 	    !(addr_is_blank(&con->actual_peer_addr.in_addr) &&
 	      con->actual_peer_addr.nonce == con->peer_addr.nonce)) {
-		pr_warning("wrong peer, want %s/%d, got %s/%d\n",
-			   ceph_pr_addr(&con->peer_addr.in_addr),
-			   (int)le32_to_cpu(con->peer_addr.nonce),
-			   ceph_pr_addr(&con->actual_peer_addr.in_addr),
-			   (int)le32_to_cpu(con->actual_peer_addr.nonce));
+		pr_warn("wrong peer, want %s/%d, got %s/%d\n",
+			ceph_pr_addr(&con->peer_addr.in_addr),
+			(int)le32_to_cpu(con->peer_addr.nonce),
+			ceph_pr_addr(&con->actual_peer_addr.in_addr),
+			(int)le32_to_cpu(con->actual_peer_addr.nonce));
 		con->error_msg = "wrong peer at address";
 		return -1;
 	}
@@ -2302,7 +2302,7 @@ static int read_partial_message(struct ceph_connection *con)
 
 		BUG_ON(!con->in_msg ^ skip);
 		if (con->in_msg && data_len > con->in_msg->data_length) {
-			pr_warning("%s skipping long message (%u > %zd)\n",
+			pr_warn("%s skipping long message (%u > %zd)\n",
 				__func__, data_len, con->in_msg->data_length);
 			ceph_msg_put(con->in_msg);
 			con->in_msg = NULL;
@@ -2712,7 +2712,7 @@ static bool con_sock_closed(struct ceph_connection *con)
 	CASE(OPEN);
 	CASE(STANDBY);
 	default:
-		pr_warning("%s con %p unrecognized state %lu\n",
+		pr_warn("%s con %p unrecognized state %lu\n",
 			__func__, con, con->state);
 		con->error_msg = "unrecognized con state";
 		BUG();
@@ -2828,8 +2828,9 @@ static void con_work(struct work_struct *work)
  */
 static void con_fault(struct ceph_connection *con)
 {
-	pr_warning("%s%lld %s %s\n", ENTITY_NAME(con->peer_name),
-	       ceph_pr_addr(&con->peer_addr.in_addr), con->error_msg);
+	pr_warn("%s%lld %s %s\n",
+		ENTITY_NAME(con->peer_name),
+		ceph_pr_addr(&con->peer_addr.in_addr), con->error_msg);
 	dout("fault %p state %lu to peer %s\n",
 	     con, con->state, ceph_pr_addr(&con->peer_addr.in_addr));
 
diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
index 30f6faf..8ebb748 100644
--- a/net/ceph/osd_client.c
+++ b/net/ceph/osd_client.c
@@ -1774,8 +1774,8 @@ static void handle_reply(struct ceph_osd_client *osdc, struct ceph_msg *msg,
 	}
 	bytes = le32_to_cpu(msg->hdr.data_len);
 	if (payload_len != bytes) {
-		pr_warning("sum of op payload lens %d != data_len %d",
-			   payload_len, bytes);
+		pr_warn("sum of op payload lens %d != data_len %d\n",
+			payload_len, bytes);
 		goto bad_put;
 	}
 
@@ -2797,10 +2797,10 @@ static struct ceph_msg *get_reply(struct ceph_connection *con,
 	ceph_msg_revoke_incoming(req->r_reply);
 
 	if (front_len > req->r_reply->front_alloc_len) {
-		pr_warning("get_reply front %d > preallocated %d (%u#%llu)\n",
-			   front_len, req->r_reply->front_alloc_len,
-			   (unsigned int)con->peer_name.type,
-			   le64_to_cpu(con->peer_name.num));
+		pr_warn("get_reply front %d > preallocated %d (%u#%llu)\n",
+			front_len, req->r_reply->front_alloc_len,
+			(unsigned int)con->peer_name.type,
+			le64_to_cpu(con->peer_name.num));
 		m = ceph_msg_new(CEPH_MSG_OSD_OPREPLY, front_len, GFP_NOFS,
 				 false);
 		if (!m)
@@ -2823,8 +2823,7 @@ static struct ceph_msg *get_reply(struct ceph_connection *con,
 			if (osd_data->pages &&
 				unlikely(osd_data->length < data_len)) {
 
-				pr_warning("tid %lld reply has %d bytes "
-					"we had only %llu bytes ready\n",
+				pr_warn("tid %lld reply has %d bytes we had only %llu bytes ready\n",
 					tid, data_len, osd_data->length);
 				*skip = 1;
 				ceph_msg_put(m);
diff --git a/net/ceph/osdmap.c b/net/ceph/osdmap.c
index c547e46..ae5a507 100644
--- a/net/ceph/osdmap.c
+++ b/net/ceph/osdmap.c
@@ -521,11 +521,11 @@ static int decode_pool(void **p, void *end, struct ceph_pg_pool_info *pi)
 	ev = ceph_decode_8(p);  /* encoding version */
 	cv = ceph_decode_8(p); /* compat version */
 	if (ev < 5) {
-		pr_warning("got v %d < 5 cv %d of ceph_pg_pool\n", ev, cv);
+		pr_warn("got v %d < 5 cv %d of ceph_pg_pool\n", ev, cv);
 		return -EINVAL;
 	}
 	if (cv > 9) {
-		pr_warning("got v %d cv %d > 9 of ceph_pg_pool\n", ev, cv);
+		pr_warn("got v %d cv %d > 9 of ceph_pg_pool\n", ev, cv);
 		return -EINVAL;
 	}
 	len = ceph_decode_32(p);
@@ -729,9 +729,9 @@ static int get_osdmap_client_data_v(void **p, void *end,
 
 		ceph_decode_8_safe(p, end, struct_compat, e_inval);
 		if (struct_compat > OSDMAP_WRAPPER_COMPAT_VER) {
-			pr_warning("got v %d cv %d > %d of %s ceph_osdmap\n",
-				   struct_v, struct_compat,
-				   OSDMAP_WRAPPER_COMPAT_VER, prefix);
+			pr_warn("got v %d cv %d > %d of %s ceph_osdmap\n",
+				struct_v, struct_compat,
+				OSDMAP_WRAPPER_COMPAT_VER, prefix);
 			return -EINVAL;
 		}
 		*p += 4; /* ignore wrapper struct_len */
@@ -739,9 +739,9 @@ static int get_osdmap_client_data_v(void **p, void *end,
 		ceph_decode_8_safe(p, end, struct_v, e_inval);
 		ceph_decode_8_safe(p, end, struct_compat, e_inval);
 		if (struct_compat > OSDMAP_CLIENT_DATA_COMPAT_VER) {
-			pr_warning("got v %d cv %d > %d of %s ceph_osdmap client data\n",
-				   struct_v, struct_compat,
-				   OSDMAP_CLIENT_DATA_COMPAT_VER, prefix);
+			pr_warn("got v %d cv %d > %d of %s ceph_osdmap client data\n",
+				struct_v, struct_compat,
+				OSDMAP_CLIENT_DATA_COMPAT_VER, prefix);
 			return -EINVAL;
 		}
 		*p += 4; /* ignore client data struct_len */
@@ -751,8 +751,8 @@ static int get_osdmap_client_data_v(void **p, void *end,
 		*p -= 1;
 		ceph_decode_16_safe(p, end, version, e_inval);
 		if (version < 6) {
-			pr_warning("got v %d < 6 of %s ceph_osdmap\n", version,
-				   prefix);
+			pr_warn("got v %d < 6 of %s ceph_osdmap\n",
+				version, prefix);
 			return -EINVAL;
 		}
 
-- 
1.8.1.2.459.gbcd45b4.dirty
