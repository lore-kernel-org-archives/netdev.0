From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH 2/5] VSOCK: export __vsock_in_bound/connected_table()
Date: Tue,  3 Oct 2017 11:39:40 -0400
Message-ID: <20171003153943.23159-3-stefanha@redhat.com>
References: <20171003153943.23159-1-stefanha@redhat.com>
Cc: Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43248 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752427AbdJCPkD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 11:40:03 -0400
In-Reply-To: <20171003153943.23159-1-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vsock_diag.ko module will need to check socket table membership.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/net/af_vsock.h   | 2 ++
 net/vmw_vsock/af_vsock.c | 6 ++++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index 30cba806e344..88149d580975 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -187,6 +187,8 @@ void vsock_enqueue_accept(struct sock *listener, struct sock *connected);
 void vsock_insert_connected(struct vsock_sock *vsk);
 void vsock_remove_bound(struct vsock_sock *vsk);
 void vsock_remove_connected(struct vsock_sock *vsk);
+bool __vsock_in_bound_table(struct vsock_sock *vsk);
+bool __vsock_in_connected_table(struct vsock_sock *vsk);
 struct sock *vsock_find_bound_socket(struct sockaddr_vm *addr);
 struct sock *vsock_find_connected_socket(struct sockaddr_vm *src,
 					 struct sockaddr_vm *dst);
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 9afe4da8c67d..f2d0fb593908 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -250,15 +250,17 @@ static struct sock *__vsock_find_connected_socket(struct sockaddr_vm *src,
 	return NULL;
 }
 
-static bool __vsock_in_bound_table(struct vsock_sock *vsk)
+bool __vsock_in_bound_table(struct vsock_sock *vsk)
 {
 	return !list_empty(&vsk->bound_table);
 }
+EXPORT_SYMBOL_GPL(__vsock_in_bound_table);
 
-static bool __vsock_in_connected_table(struct vsock_sock *vsk)
+bool __vsock_in_connected_table(struct vsock_sock *vsk)
 {
 	return !list_empty(&vsk->connected_table);
 }
+EXPORT_SYMBOL_GPL(__vsock_in_connected_table);
 
 static void vsock_insert_unbound(struct vsock_sock *vsk)
 {
-- 
2.13.6
