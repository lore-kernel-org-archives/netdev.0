From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] VSOCK: constify vmci_transport_notify_ops structures
Date: Sat, 21 Nov 2015 18:39:17 +0100
Message-ID: <1448127557-22280-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, Ray Jui <rjui@broadcom.com>,
	Scott Branden <sbranden@broadcom.com>,
	Jon Mason <jonmason@broadcom.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	bcm-kernel-feedback-list@broadcom.com, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The vmci_transport_notify_ops structures are never modified, so declare
them as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/vmw_vsock/vmci_transport.h               |    2 +-
 net/vmw_vsock/vmci_transport_notify.c        |    2 +-
 net/vmw_vsock/vmci_transport_notify.h        |    5 +++--
 net/vmw_vsock/vmci_transport_notify_qstate.c |    2 +-
 4 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/vmw_vsock/vmci_transport.h b/net/vmw_vsock/vmci_transport.h
index 2ad46f3..1820e74 100644
--- a/net/vmw_vsock/vmci_transport.h
+++ b/net/vmw_vsock/vmci_transport.h
@@ -121,7 +121,7 @@ struct vmci_transport {
 	u64 queue_pair_max_size;
 	u32 detach_sub_id;
 	union vmci_transport_notify notify;
-	struct vmci_transport_notify_ops *notify_ops;
+	const struct vmci_transport_notify_ops *notify_ops;
 	struct list_head elem;
 	struct sock *sk;
 	spinlock_t lock; /* protects sk. */
diff --git a/net/vmw_vsock/vmci_transport_notify.c b/net/vmw_vsock/vmci_transport_notify.c
index 9b7f207..fd8cf02 100644
--- a/net/vmw_vsock/vmci_transport_notify.c
+++ b/net/vmw_vsock/vmci_transport_notify.c
@@ -661,7 +661,7 @@ static void vmci_transport_notify_pkt_process_negotiate(struct sock *sk)
 }
 
 /* Socket control packet based operations. */
-struct vmci_transport_notify_ops vmci_transport_notify_pkt_ops = {
+const struct vmci_transport_notify_ops vmci_transport_notify_pkt_ops = {
 	vmci_transport_notify_pkt_socket_init,
 	vmci_transport_notify_pkt_socket_destruct,
 	vmci_transport_notify_pkt_poll_in,
diff --git a/net/vmw_vsock/vmci_transport_notify.h b/net/vmw_vsock/vmci_transport_notify.h
index 7df7932..3c464d3 100644
--- a/net/vmw_vsock/vmci_transport_notify.h
+++ b/net/vmw_vsock/vmci_transport_notify.h
@@ -77,7 +77,8 @@ struct vmci_transport_notify_ops {
 	void (*process_negotiate) (struct sock *sk);
 };
 
-extern struct vmci_transport_notify_ops vmci_transport_notify_pkt_ops;
-extern struct vmci_transport_notify_ops vmci_transport_notify_pkt_q_state_ops;
+extern const struct vmci_transport_notify_ops vmci_transport_notify_pkt_ops;
+extern const
+struct vmci_transport_notify_ops vmci_transport_notify_pkt_q_state_ops;
 
 #endif /* __VMCI_TRANSPORT_NOTIFY_H__ */
diff --git a/net/vmw_vsock/vmci_transport_notify_qstate.c b/net/vmw_vsock/vmci_transport_notify_qstate.c
index dc9c792..21e591d 100644
--- a/net/vmw_vsock/vmci_transport_notify_qstate.c
+++ b/net/vmw_vsock/vmci_transport_notify_qstate.c
@@ -419,7 +419,7 @@ vmci_transport_notify_pkt_send_pre_enqueue(
 }
 
 /* Socket always on control packet based operations. */
-struct vmci_transport_notify_ops vmci_transport_notify_pkt_q_state_ops = {
+const struct vmci_transport_notify_ops vmci_transport_notify_pkt_q_state_ops = {
 	vmci_transport_notify_pkt_socket_init,
 	vmci_transport_notify_pkt_socket_destruct,
 	vmci_transport_notify_pkt_poll_in,

