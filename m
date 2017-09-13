From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH stable-3.16 3/3] VSOCK: Detach QP check should filter out non matching QPs.
Date: Wed, 13 Sep 2017 17:23:07 +0200
Message-ID: <20170913152307.20317-3-mhocko@kernel.org>
References: <20170913151939.gf7n6rvvjtz47tz7@dhcp22.suse.cz>
 <20170913152307.20317-1-mhocko@kernel.org>
Cc: Aditya Sarwade <asarwade@vmware.com>,
        Thomas Hellstrom <thellstrom@vmware.com>,
        Petr Masik <Petr.Masik@nudz.cz>,
        Ben Hutchings <ben@decadent.org.uk>,
        Sasha Levin <alexander.levin@verizon.com>,
        netdev@vger.kernel.org, Stable tree <stable@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: "Jorgen S. Hansen" <jhansen@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170913152307.20317-1-mhocko@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jorgen Hansen <jhansen@vmware.com>

commit 8ab18d71de8b07d2c4d6f984b718418c09ea45c5 upstream.

The check in vmci_transport_peer_detach_cb should only allow a
detach when the qp handle of the transport matches the one in
the detach message.

Testing: Before this change, a detach from a peer on a different
socket would cause an active stream socket to register a detach.

Reviewed-by: George Zhang <georgezhang@vmware.com>
Signed-off-by: Jorgen Hansen <jhansen@vmware.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 net/vmw_vsock/vmci_transport.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index 314312272e08..c69c990ec4a2 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -844,7 +844,7 @@ static void vmci_transport_peer_detach_cb(u32 sub_id,
 	 * qp_handle.
 	 */
 	if (vmci_handle_is_invalid(e_payload->handle) ||
-	    vmci_handle_is_equal(trans->qp_handle, e_payload->handle))
+	    !vmci_handle_is_equal(trans->qp_handle, e_payload->handle))
 		return;
 
 	/* We don't ask for delayed CBs when we subscribe to this event (we
@@ -2158,7 +2158,7 @@ module_exit(vmci_transport_exit);
 
 MODULE_AUTHOR("VMware, Inc.");
 MODULE_DESCRIPTION("VMCI transport for Virtual Sockets");
-MODULE_VERSION("1.0.2.0-k");
+MODULE_VERSION("1.0.3.0-k");
 MODULE_LICENSE("GPL v2");
 MODULE_ALIAS("vmware_vsock");
 MODULE_ALIAS_NETPROTO(PF_VSOCK);
-- 
2.14.1
