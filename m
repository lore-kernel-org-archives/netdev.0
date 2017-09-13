From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH stable-3.16 2/3] VSOCK: Fix lockdep issue.
Date: Wed, 13 Sep 2017 17:23:06 +0200
Message-ID: <20170913152307.20317-2-mhocko@kernel.org>
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

commit 8566b86ab9f0f45bc6f7dd422b21de9d0cf5415a upstream.

The recent fix for the vsock sock_put issue used the wrong
initializer for the transport spin_lock causing an issue when
running with lockdep checking.

Testing: Verified fix on kernel with lockdep enabled.

Reviewed-by: Thomas Hellstrom <thellstrom@vmware.com>
Signed-off-by: Jorgen Hansen <jhansen@vmware.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 net/vmw_vsock/vmci_transport.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index aed136d27b01..314312272e08 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -1570,7 +1570,7 @@ static int vmci_transport_socket_init(struct vsock_sock *vsk,
 	vmci_trans(vsk)->notify_ops = NULL;
 	INIT_LIST_HEAD(&vmci_trans(vsk)->elem);
 	vmci_trans(vsk)->sk = &vsk->sk;
-	vmci_trans(vsk)->lock = __SPIN_LOCK_UNLOCKED(vmci_trans(vsk)->lock);
+	spin_lock_init(&vmci_trans(vsk)->lock);
 	if (psk) {
 		vmci_trans(vsk)->queue_pair_size =
 			vmci_trans(psk)->queue_pair_size;
-- 
2.14.1
