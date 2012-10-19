From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 08/21] scsi: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
Date: Thu, 18 Oct 2012 21:14:12 -0700
Message-ID: <b5ad6d77f2921477697d3a316d8a07ab6710646b.1350618011.git.joe@perches.com>
References: <cover.1350618006.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1350618006.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the old ether_addr tests to eth_addr_<foo>.
Adds api consistency.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/scsi/bnx2fc/bnx2fc_els.c  |    4 ++--
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c |    2 +-
 drivers/scsi/fcoe/fcoe.c          |   12 ++++++------
 drivers/scsi/fcoe/fcoe_ctlr.c     |    8 ++++----
 drivers/scsi/fnic/fnic_fcs.c      |    6 +++---
 5 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/scsi/bnx2fc/bnx2fc_els.c b/drivers/scsi/bnx2fc/bnx2fc_els.c
index bdbbb13..e611fe5 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_els.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_els.c
@@ -860,7 +860,7 @@ static void bnx2fc_flogi_resp(struct fc_seq *seq, struct fc_frame *fp,
 		goto done;
 
 	mac = fr_cb(fp)->granted_mac;
-	if (is_zero_ether_addr(mac)) {
+	if (eth_addr_zero(mac)) {
 		op = fc_frame_payload_op(fp);
 		if (lport->vport) {
 			if (op == ELS_LS_RJT) {
@@ -872,7 +872,7 @@ static void bnx2fc_flogi_resp(struct fc_seq *seq, struct fc_frame *fp,
 		}
 		fcoe_ctlr_recv_flogi(fip, lport, fp);
 	}
-	if (!is_zero_ether_addr(mac))
+	if (!eth_addr_zero(mac))
 		fip->update_mac(lport, mac);
 done:
 	fc_lport_flogi_resp(seq, fp, lport);
diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
index e055865..e888418 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -1216,7 +1216,7 @@ static int bnx2fc_interface_setup(struct bnx2fc_interface *interface)
 				ha->addr[4], ha->addr[5]);
 
 		if ((ha->type == NETDEV_HW_ADDR_T_SAN) &&
-		    (is_valid_ether_addr(ha->addr))) {
+		    (eth_addr_valid(ha->addr))) {
 			memcpy(ctlr->ctl_src_addr, ha->addr,
 			       ETH_ALEN);
 			sel_san_mac = 1;
diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 666b7ac..876b99c 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -328,7 +328,7 @@ static int fcoe_interface_setup(struct fcoe_interface *fcoe,
 	rcu_read_lock();
 	for_each_dev_addr(real_dev, ha) {
 		if ((ha->type == NETDEV_HW_ADDR_T_SAN) &&
-		    (is_valid_ether_addr(ha->addr))) {
+		    (eth_addr_valid(ha->addr))) {
 			memcpy(fip->ctl_src_addr, ha->addr, ETH_ALEN);
 			fip->spma = 1;
 			break;
@@ -563,9 +563,9 @@ static void fcoe_update_src_mac(struct fc_lport *lport, u8 *addr)
 	struct fcoe_port *port = lport_priv(lport);
 	struct fcoe_interface *fcoe = port->priv;
 
-	if (!is_zero_ether_addr(port->data_src_addr))
+	if (!eth_addr_zero(port->data_src_addr))
 		dev_uc_del(fcoe->netdev, port->data_src_addr);
-	if (!is_zero_ether_addr(addr))
+	if (!eth_addr_zero(addr))
 		dev_uc_add(fcoe->netdev, addr);
 	memcpy(port->data_src_addr, addr, ETH_ALEN);
 }
@@ -980,7 +980,7 @@ static void fcoe_if_destroy(struct fc_lport *lport)
 	fcoe_clean_pending_queue(lport);
 
 	rtnl_lock();
-	if (!is_zero_ether_addr(port->data_src_addr))
+	if (!eth_addr_zero(port->data_src_addr))
 		dev_uc_del(netdev, port->data_src_addr);
 	if (lport->vport)
 		synchronize_net();
@@ -2587,9 +2587,9 @@ static void fcoe_flogi_resp(struct fc_seq *seq, struct fc_frame *fp, void *arg)
 
 	mac = fr_cb(fp)->granted_mac;
 	/* pre-FIP */
-	if (is_zero_ether_addr(mac))
+	if (eth_addr_zero(mac))
 		fcoe_ctlr_recv_flogi(fip, lport, fp);
-	if (!is_zero_ether_addr(mac))
+	if (!eth_addr_zero(mac))
 		fcoe_update_src_mac(lport, mac);
 done:
 	fc_lport_flogi_resp(seq, fp, lport);
diff --git a/drivers/scsi/fcoe/fcoe_ctlr.c b/drivers/scsi/fcoe/fcoe_ctlr.c
index 2ebe03a..5f230a0 100644
--- a/drivers/scsi/fcoe/fcoe_ctlr.c
+++ b/drivers/scsi/fcoe/fcoe_ctlr.c
@@ -302,7 +302,7 @@ static void fcoe_ctlr_announce(struct fcoe_ctlr *fip)
 
 	if (sel && !compare_ether_addr(sel->fcf_mac, fip->dest_addr))
 		goto unlock;
-	if (!is_zero_ether_addr(fip->dest_addr)) {
+	if (!eth_addr_zero(fip->dest_addr)) {
 		printk(KERN_NOTICE "libfcoe: host%d: "
 		       "FIP Fibre-Channel Forwarder MAC %pM deselected\n",
 		       fip->lp->host->host_no, fip->dest_addr);
@@ -907,7 +907,7 @@ static int fcoe_ctlr_parse_adv(struct fcoe_ctlr *fip,
 			       ((struct fip_mac_desc *)desc)->fd_mac,
 			       ETH_ALEN);
 			memcpy(fcf->fcoe_mac, fcf->fcf_mac, ETH_ALEN);
-			if (!is_valid_ether_addr(fcf->fcf_mac)) {
+			if (!eth_addr_valid(fcf->fcf_mac)) {
 				LIBFCOE_FIP_DBG(fip,
 					"Invalid MAC addr %pM in FIP adv\n",
 					fcf->fcf_mac);
@@ -1212,7 +1212,7 @@ static void fcoe_ctlr_recv_els(struct fcoe_ctlr *fip, struct sk_buff *skb)
 	if ((els_dtype == FIP_DT_FLOGI || els_dtype == FIP_DT_FDISC) &&
 	    sub == FIP_SC_REP && fip->mode != FIP_MODE_VN2VN) {
 		if (els_op == ELS_LS_ACC) {
-			if (!is_valid_ether_addr(granted_mac)) {
+			if (!eth_addr_valid(granted_mac)) {
 				LIBFCOE_FIP_DBG(fip,
 					"Invalid MAC address %pM in FIP ELS\n",
 					granted_mac);
@@ -2252,7 +2252,7 @@ static int fcoe_ctlr_vn_parse(struct fcoe_ctlr *fip,
 			if (dlen != sizeof(struct fip_mac_desc))
 				goto len_err;
 			macd = (struct fip_mac_desc *)desc;
-			if (!is_valid_ether_addr(macd->fd_mac)) {
+			if (!eth_addr_valid(macd->fd_mac)) {
 				LIBFCOE_FIP_DBG(fip,
 					"Invalid MAC addr %pM in FIP VN2VN\n",
 					 macd->fd_mac);
diff --git a/drivers/scsi/fnic/fnic_fcs.c b/drivers/scsi/fnic/fnic_fcs.c
index 3c53c34..792df19 100644
--- a/drivers/scsi/fnic/fnic_fcs.c
+++ b/drivers/scsi/fnic/fnic_fcs.c
@@ -190,12 +190,12 @@ void fnic_update_mac_locked(struct fnic *fnic, u8 *new)
 	u8 *ctl = fnic->ctlr.ctl_src_addr;
 	u8 *data = fnic->data_src_addr;
 
-	if (is_zero_ether_addr(new))
+	if (eth_addr_zero(new))
 		new = ctl;
 	if (!compare_ether_addr(data, new))
 		return;
 	FNIC_FCS_DBG(KERN_DEBUG, fnic->lport->host, "update_mac %pM\n", new);
-	if (!is_zero_ether_addr(data) && compare_ether_addr(data, ctl))
+	if (!eth_addr_zero(data) && compare_ether_addr(data, ctl))
 		vnic_dev_del_addr(fnic->vdev, data);
 	memcpy(data, new, ETH_ALEN);
 	if (compare_ether_addr(new, ctl))
@@ -251,7 +251,7 @@ void fnic_set_port_id(struct fc_lport *lport, u32 port_id, struct fc_frame *fp)
 
 	if (fp) {
 		mac = fr_cb(fp)->granted_mac;
-		if (is_zero_ether_addr(mac)) {
+		if (eth_addr_zero(mac)) {
 			/* non-FIP - FLOGI already accepted - ignore return */
 			fcoe_ctlr_recv_flogi(&fnic->ctlr, lport, fp);
 		}
-- 
1.7.8.111.gad25c.dirty
