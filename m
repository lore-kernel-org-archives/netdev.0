From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 2/4 linux-next] bna: use container_of to resolve bufdesc_ex from bufdesc
Date: Sat, 13 Sep 2014 22:38:27 +0200
Message-ID: <1410640709-18295-3-git-send-email-fabf@skynet.be>
References: <1410640709-18295-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Fabian Frederick <fabf@skynet.be>,
	Rasesh Mody <rmody@brocade.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410640709-18295-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use container_of instead of casting first structure member.

Compiled but untested.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/brocade/bna/bna_enet.c  | 9 ++++++---
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c | 4 ++--
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna_enet.c b/drivers/net/ethernet/brocade/bna/bna_enet.c
index 13f9636..903466e 100644
--- a/drivers/net/ethernet/brocade/bna/bna_enet.c
+++ b/drivers/net/ethernet/brocade/bna/bna_enet.c
@@ -107,7 +107,8 @@ bna_bfi_ethport_admin_rsp(struct bna_ethport *ethport,
 {
 	struct bfi_enet_enable_req *admin_req =
 		&ethport->bfi_enet_cmd.admin_req;
-	struct bfi_enet_rsp *rsp = (struct bfi_enet_rsp *)msghdr;
+	struct bfi_enet_rsp *rsp =
+		container_of(msghdr, struct bfi_enet_rsp, mh);
 
 	switch (admin_req->enable) {
 	case BNA_STATUS_T_ENABLED:
@@ -133,7 +134,8 @@ bna_bfi_ethport_lpbk_rsp(struct bna_ethport *ethport,
 {
 	struct bfi_enet_diag_lb_req *diag_lb_req =
 		&ethport->bfi_enet_cmd.lpbk_req;
-	struct bfi_enet_rsp *rsp = (struct bfi_enet_rsp *)msghdr;
+	struct bfi_enet_rsp *rsp =
+		container_of(msghdr, struct bfi_enet_rsp, mh);
 
 	switch (diag_lb_req->enable) {
 	case BNA_STATUS_T_ENABLED:
@@ -161,7 +163,8 @@ static void
 bna_bfi_attr_get_rsp(struct bna_ioceth *ioceth,
 			struct bfi_msgq_mhdr *msghdr)
 {
-	struct bfi_enet_attr_rsp *rsp = (struct bfi_enet_attr_rsp *)msghdr;
+	struct bfi_enet_attr_rsp *rsp =
+		container_of(msghdr, struct bfi_enet_attr_rsp, mh);
 
 	/**
 	 * Store only if not set earlier, since BNAD can override the HW
diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 85e6354..8ee3fdc 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -715,7 +715,7 @@ bna_bfi_rxf_ucast_set_rsp(struct bna_rxf *rxf,
 			struct bfi_msgq_mhdr *msghdr)
 {
 	struct bfi_enet_rsp *rsp =
-		(struct bfi_enet_rsp *)msghdr;
+		container_of(msghdr, struct bfi_enet_rsp, mh);
 
 	if (rsp->error) {
 		/* Clear ucast from cache */
@@ -732,7 +732,7 @@ bna_bfi_rxf_mcast_add_rsp(struct bna_rxf *rxf,
 	struct bfi_enet_mcast_add_req *req =
 		&rxf->bfi_enet_cmd.mcast_add_req;
 	struct bfi_enet_mcast_add_rsp *rsp =
-		(struct bfi_enet_mcast_add_rsp *)msghdr;
+		container_of(msghdr, struct bfi_enet_mcast_add_rsp, mh);
 
 	bna_rxf_mchandle_attach(rxf, (u8 *)&req->mac_addr,
 		ntohs(rsp->handle));
-- 
1.8.4.5
