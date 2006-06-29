From: "Bryan O'Sullivan" <bos@pathscale.com>
Subject: [PATCH 11 of 39] IB/ipath - return an error
 for unknown multicast GID
Date: Thu, 29 Jun 2006 14:41:02 -0700
Message-ID: <1e1f3da0e78d32f2a733.1151617262@eng-12.pathscale.com>
References: <patchbomb.1151617251@eng-12.pathscale.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
In-Reply-To: <patchbomb.1151617251@eng-12.pathscale.com>
To: akpm@osdl.org,
	rdreier@cisco.com,
	mst@mellanox.co.il
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Robert Walsh <robert.walsh@qlogic.com>
Signed-off-by: Bryan O'Sullivan <bryan.osullivan@qlogic.com>

diff -r 160e5cf91761 -r 1e1f3da0e78d drivers/infiniband/hw/ipath/ipath_verbs_mcast.c
--- a/drivers/infiniband/hw/ipath/ipath_verbs_mcast.c	Thu Jun 29 14:33:25 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_verbs_mcast.c	Thu Jun 29 14:33:25 2006 -0700
@@ -273,7 +273,7 @@ int ipath_multicast_detach(struct ib_qp 
 	while (1) {
 		if (n == NULL) {
 			spin_unlock_irqrestore(&mcast_lock, flags);
-			ret = 0;
+			ret = -EINVAL;
 			goto bail;
 		}
 
