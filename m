From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v2 2/5] VSOCK: move __vsock_in_bound/connected_table() to af_vsock.h
Date: Wed,  4 Oct 2017 12:37:13 -0400
Message-ID: <20171004163716.3964-3-stefanha@redhat.com>
References: <20171004163716.3964-1-stefanha@redhat.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49364 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751427AbdJDQhh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Oct 2017 12:37:37 -0400
In-Reply-To: <20171004163716.3964-1-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vsock_diag.ko module will need to check socket table membership.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/net/af_vsock.h   | 12 ++++++++++++
 net/vmw_vsock/af_vsock.c | 10 ----------
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index 30cba806e344..3dd217718a2f 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -180,6 +180,18 @@ const struct vsock_transport *vsock_core_get_transport(void);
 
 /**** UTILS ****/
 
+/* vsock_table_lock must be held */
+static inline bool __vsock_in_bound_table(struct vsock_sock *vsk)
+{
+	return !list_empty(&vsk->bound_table);
+}
+
+/* vsock_table_lock must be held */
+static inline bool __vsock_in_connected_table(struct vsock_sock *vsk)
+{
+	return !list_empty(&vsk->connected_table);
+}
+
 void vsock_release_pending(struct sock *pending);
 void vsock_add_pending(struct sock *listener, struct sock *pending);
 void vsock_remove_pending(struct sock *listener, struct sock *pending);
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 9afe4da8c67d..9b179a0081b3 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -250,16 +250,6 @@ static struct sock *__vsock_find_connected_socket(struct sockaddr_vm *src,
 	return NULL;
 }
 
-static bool __vsock_in_bound_table(struct vsock_sock *vsk)
-{
-	return !list_empty(&vsk->bound_table);
-}
-
-static bool __vsock_in_connected_table(struct vsock_sock *vsk)
-{
-	return !list_empty(&vsk->connected_table);
-}
-
 static void vsock_insert_unbound(struct vsock_sock *vsk)
 {
 	spin_lock_bh(&vsock_table_lock);
-- 
2.13.6
