From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH] fcoe: correct checking for bonding
Date: Mon, 28 Feb 2011 14:32:45 +0100
Message-ID: <20110228133245.GB7096@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@open-fcoe.org, robert.w.love@intel.com,
	James.Bottomley@HansenPartnership.com, netdev@vger.kernel.org
To: linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check for IFF_BONDING as this flag is set-up for all bonding devices.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/scsi/fcoe/fcoe.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 9f9600b..67714a4 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -285,9 +285,7 @@ static int fcoe_interface_setup(struct fcoe_interface *fcoe,
 	}
 
 	/* Do not support for bonding device */
-	if ((netdev->priv_flags & IFF_MASTER_ALB) ||
-	    (netdev->priv_flags & IFF_SLAVE_INACTIVE) ||
-	    (netdev->priv_flags & IFF_MASTER_8023AD)) {
+	if (netdev->priv_flags & IFF_BONDING) {
 		FCOE_NETDEV_DBG(netdev, "Bonded interfaces not supported\n");
 		return -EOPNOTSUPP;
 	}
-- 
1.7.3.4

