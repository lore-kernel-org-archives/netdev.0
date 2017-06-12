From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] nfc: nci: fix potential NULL pointer dereference
Date: Mon, 12 Jun 2017 17:02:23 -0500
Message-ID: <20170612220223.GA6326@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Samuel Ortiz <sameo@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NULL check at line 76: if (conn_info) {, implies that pointer conn_info
might be NULL, but this pointer is being previously dereferenced,
which might cause a NULL pointer dereference.

Add NULL check before dereferencing pointer conn_info in order to
avoid a potential NULL pointer dereference.

Addresses-Coverity-ID: 1362349
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/nfc/nci/core.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 61fff42..d2198ce 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -70,14 +70,13 @@ int nci_get_conn_info_by_dest_type_params(struct nci_dev *ndev, u8 dest_type,
 	struct nci_conn_info *conn_info;
 
 	list_for_each_entry(conn_info, &ndev->conn_info_list, list) {
-		if (conn_info->dest_type == dest_type) {
+		if (conn_info && conn_info->dest_type == dest_type) {
 			if (!params)
 				return conn_info->conn_id;
-			if (conn_info) {
-				if (params->id == conn_info->dest_params->id &&
-				    params->protocol == conn_info->dest_params->protocol)
-					return conn_info->conn_id;
-			}
+
+			if (params->id == conn_info->dest_params->id &&
+			    params->protocol == conn_info->dest_params->protocol)
+				return conn_info->conn_id;
 		}
 	}
 
-- 
2.5.0
