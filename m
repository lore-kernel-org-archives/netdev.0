From: Jorgen Hansen <jhansen@vmware.com>
Subject: [PATCH] VSOCK: Detach QP check should filter out non matching QPs.
Date: Tue,  5 Apr 2016 01:59:32 -0700
Message-ID: <1459846772-14521-1-git-send-email-jhansen@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, gregkh@linuxfoundation.org, davem@davemloft.net,
	Jorgen Hansen <jhansen@vmware.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

The check in vmci_transport_peer_detach_cb should only allow a
detach when the qp handle of the transport matches the one in
the detach message.

Testing: Before this change, a detach from a peer on a different
socket would cause an active stream socket to register a detach.

Reviewed-by: George Zhang <georgezhang@vmware.com>
Signed-off-by: Jorgen Hansen <jhansen@vmware.com>
---
 net/vmw_vsock/vmci_transport.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index 0a369bb..662bdd2 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -842,7 +842,7 @@ static void vmci_transport_peer_detach_cb(u32 sub_id,
 	 * qp_handle.
 	 */
 	if (vmci_handle_is_invalid(e_payload->handle) ||
-	    vmci_handle_is_equal(trans->qp_handle, e_payload->handle))
+	    !vmci_handle_is_equal(trans->qp_handle, e_payload->handle))
 		return;
 
 	/* We don't ask for delayed CBs when we subscribe to this event (we
@@ -2154,7 +2154,7 @@ module_exit(vmci_transport_exit);
 
 MODULE_AUTHOR("VMware, Inc.");
 MODULE_DESCRIPTION("VMCI transport for Virtual Sockets");
-MODULE_VERSION("1.0.2.0-k");
+MODULE_VERSION("1.0.3.0-k");
 MODULE_LICENSE("GPL v2");
 MODULE_ALIAS("vmware_vsock");
 MODULE_ALIAS_NETPROTO(PF_VSOCK);
-- 
1.7.0
