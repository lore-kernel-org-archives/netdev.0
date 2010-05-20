From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 8/8] caif: Fixed splint warnings
Date: Thu, 20 May 2010 09:44:08 +0200
Message-ID: <1274341448-14924-9-git-send-email-sjur.brandeland@stericsson.com>
References: <1274341448-14924-1-git-send-email-sjur.brandeland@stericsson.com>
 <1274341448-14924-2-git-send-email-sjur.brandeland@stericsson.com>
 <1274341448-14924-3-git-send-email-sjur.brandeland@stericsson.com>
 <1274341448-14924-4-git-send-email-sjur.brandeland@stericsson.com>
 <1274341448-14924-5-git-send-email-sjur.brandeland@stericsson.com>
 <1274341448-14924-6-git-send-email-sjur.brandeland@stericsson.com>
 <1274341448-14924-7-git-send-email-sjur.brandeland@stericsson.com>
 <1274341448-14924-8-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: marcel@holtmann.org, daniel.martensson@stericsson.com,
	linus.walleji@stericsson.com, sjurbren@gmail.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:51603 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754254Ab0ETHow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 03:44:52 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2P00CF8K666ZD0@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Thu, 20 May 2010 09:44:30 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2P008F5K603V20@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Thu, 20 May 2010 09:44:30 +0200 (CEST)
In-reply-to: <1274341448-14924-8-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Compiled with splint and tested on 64bit x86.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_socket.c |   10 +++++-----
 net/caif/cfcnfg.c      |    2 +-
 net/caif/cfmuxl.c      |    3 ++-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 4bf2ed6..0fa614f 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -60,7 +60,7 @@ struct debug_fs_counter {
 	atomic_t num_rx_flow_off;
 	atomic_t num_rx_flow_on;
 };
-struct debug_fs_counter cnt;
+static struct debug_fs_counter cnt;
 #define	dbfs_atomic_inc(v) atomic_inc(v)
 #define	dbfs_atomic_dec(v) atomic_dec(v)
 #else
@@ -129,13 +129,13 @@ static void caif_read_unlock(struct sock *sk)
 	mutex_unlock(&cf_sk->readlock);
 }
 
-int sk_rcvbuf_lowwater(struct caifsock *cf_sk)
+static int sk_rcvbuf_lowwater(struct caifsock *cf_sk)
 {
 	/* A quarter of full buffer is used a low water mark */
 	return cf_sk->sk.sk_rcvbuf / 4;
 }
 
-void caif_flow_ctrl(struct sock *sk, int mode)
+static void caif_flow_ctrl(struct sock *sk, int mode)
 {
 	struct caifsock *cf_sk;
 	cf_sk = container_of(sk, struct caifsock, sk);
@@ -147,7 +147,7 @@ void caif_flow_ctrl(struct sock *sk, int mode)
  * Copied from sock.c:sock_queue_rcv_skb(), but changed so packets are
  * not dropped, but CAIF is sending flow off instead.
  */
-int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+static int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int err;
 	int skb_len;
@@ -1184,7 +1184,7 @@ static struct net_proto_family caif_family_ops = {
 	.owner = THIS_MODULE,
 };
 
-int af_caif_init(void)
+static int af_caif_init(void)
 {
 	int err = sock_register(&caif_family_ops);
 	if (!err)
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index ca4077c..4d5fe51 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -258,7 +258,7 @@ static void cfcnfg_linkdestroy_rsp(struct cflayer *layer, u8 channel_id)
 {
 }
 
-int protohead[CFCTRL_SRV_MASK] = {
+static int protohead[CFCTRL_SRV_MASK] = {
 	[CFCTRL_SRV_VEI] = 4,
 	[CFCTRL_SRV_DATAGRAM] = 7,
 	[CFCTRL_SRV_UTIL] = 4,
diff --git a/net/caif/cfmuxl.c b/net/caif/cfmuxl.c
index 7372f27..b029872 100644
--- a/net/caif/cfmuxl.c
+++ b/net/caif/cfmuxl.c
@@ -174,10 +174,11 @@ struct cflayer *cfmuxl_remove_uplayer(struct cflayer *layr, u8 id)
 	spin_lock(&muxl->receive_lock);
 	up = get_up(muxl, id);
 	if (up == NULL)
-		return NULL;
+		goto out;
 	memset(muxl->up_cache, 0, sizeof(muxl->up_cache));
 	list_del(&up->node);
 	cfsrvl_put(up);
+ out:
 	spin_unlock(&muxl->receive_lock);
 	return up;
 }
-- 
1.6.3.3

