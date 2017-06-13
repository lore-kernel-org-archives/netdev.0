From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] nfc: nci: remove unnecessary null check
Date: Tue, 13 Jun 2017 11:37:18 -0500
Message-ID: <20170613163718.GA5375@embeddedgus>
References: <28317503-e721-2564-a9ff-82182aa0644a@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        Guenter Roeck <linux@roeck-us.net>
To: Samuel Ortiz <sameo@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <28317503-e721-2564-a9ff-82182aa0644a@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unnecessary NULL check for pointer conn_info.
conn_info is set in list_for_each_entry() using container_of(),
which is never NULL.

Addresses-Coverity-ID: 1362349
Cc: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/nfc/nci/core.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 61fff42..c15cb88 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -73,11 +73,10 @@ int nci_get_conn_info_by_dest_type_params(struct nci_dev *ndev, u8 dest_type,
 		if (conn_info->dest_type == dest_type) {
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
