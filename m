From: Jiri Pirko <jpirko@redhat.com>
Subject: fcoe: correct checking for bonding
Date: Wed, 2 Mar 2011 07:05:35 +0100
Message-ID: <20110302060535.GA2829@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@open-fcoe.org, robert.w.love@intel.com,
	netdev@vger.kernel.org, fubar@us.ibm.com, joe.eykholt@gmail.com
To: linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check for bonding master and refuse to use that.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/scsi/fcoe/fcoe.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 9f9600b..3becc6a 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -285,9 +285,7 @@ static int fcoe_interface_setup(struct fcoe_interface *fcoe,
 	}
 
 	/* Do not support for bonding device */
-	if ((netdev->priv_flags & IFF_MASTER_ALB) ||
-	    (netdev->priv_flags & IFF_SLAVE_INACTIVE) ||
-	    (netdev->priv_flags & IFF_MASTER_8023AD)) {
+	if (netdev->priv_flags & IFF_BONDING && netdev->flags & IFF_MASTER) {
 		FCOE_NETDEV_DBG(netdev, "Bonded interfaces not supported\n");
 		return -EOPNOTSUPP;
 	}
-- 
1.7.3.4

