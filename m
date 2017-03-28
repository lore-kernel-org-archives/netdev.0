From: Colin King <colin.king@canonical.com>
Subject: [PATCH] VSOCK: remove unnecessary ternary operator on return value
Date: Tue, 28 Mar 2017 16:54:24 +0100
Message-ID: <20170328155424.22873-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Jorgen Hansen <jhansen@vmware.com>,
        Adit Ranadive <aditr@vmware.com>,
        Julia Lawall <julia.lawall@lip6.fr>,
        Stefan Hajnoczi <stefanha@redhat.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Rather than assign the positive errno values to ret and then
checking if it is positive and flip the sign, just set ret to
be the -ve errno value.

Detected by CoverityScan, CID#986649 ("Logically Dead Code")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/vmw_vsock/vmci_transport.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index 4be4fbbc0b50..a68cd6b0fb72 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -100,27 +100,27 @@ static s32 vmci_transport_error_to_vsock_error(s32 vmci_error)
 
 	switch (vmci_error) {
 	case VMCI_ERROR_NO_MEM:
-		err = ENOMEM;
+		err = -ENOMEM;
 		break;
 	case VMCI_ERROR_DUPLICATE_ENTRY:
 	case VMCI_ERROR_ALREADY_EXISTS:
-		err = EADDRINUSE;
+		err = -EADDRINUSE;
 		break;
 	case VMCI_ERROR_NO_ACCESS:
-		err = EPERM;
+		err = -EPERM;
 		break;
 	case VMCI_ERROR_NO_RESOURCES:
-		err = ENOBUFS;
+		err = -ENOBUFS;
 		break;
 	case VMCI_ERROR_INVALID_RESOURCE:
-		err = EHOSTUNREACH;
+		err = -EHOSTUNREACH;
 		break;
 	case VMCI_ERROR_INVALID_ARGS:
 	default:
-		err = EINVAL;
+		err = -EINVAL;
 	}
 
-	return err > 0 ? -err : err;
+	return err;
 }
 
 static u32 vmci_transport_peer_rid(u32 peer_cid)
-- 
2.11.0
