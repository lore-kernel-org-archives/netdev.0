From: santosh nayak <santoshprasadnayak@gmail.com>
Subject: [PATCH 1/2] enic: Fix endianness bug.
Date: Fri, 24 Feb 2012 22:26:39 +0530
Message-ID: <1330102599-1245-1-git-send-email-santoshprasadnayak@gmail.com>
Cc: roprabhu@cisco.com, neepatel@cisco.com, nistrive@cisco.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Santosh Nayak <santoshprasadnayak@gmail.com>
To: benve@cisco.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Nayak <santoshprasadnayak@gmail.com>

Sparse complaints the endian bug.

Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
---
 drivers/net/ethernet/cisco/enic/cq_enet_desc.h |    2 +-
 drivers/net/ethernet/cisco/enic/enic_pp.c      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/cq_enet_desc.h b/drivers/net/ethernet/cisco/enic/cq_enet_desc.h
index c2c0680..ac37cac 100644
--- a/drivers/net/ethernet/cisco/enic/cq_enet_desc.h
+++ b/drivers/net/ethernet/cisco/enic/cq_enet_desc.h
@@ -157,7 +157,7 @@ static inline void cq_enet_rq_desc_dec(struct cq_enet_rq_desc *desc,
 			CQ_ENET_RQ_DESC_FCOE_FC_CRC_OK) ? 1 : 0;
 		*fcoe_enc_error = (desc->flags &
 			CQ_ENET_RQ_DESC_FCOE_ENC_ERROR) ? 1 : 0;
-		*fcoe_eof = (u8)((desc->checksum_fcoe >>
+		*fcoe_eof = (u8)((le16_to_cpu(desc->checksum_fcoe) >>
 			CQ_ENET_RQ_DESC_FCOE_EOF_SHIFT) &
 			CQ_ENET_RQ_DESC_FCOE_EOF_MASK);
 		*checksum = 0;
diff --git a/drivers/net/ethernet/cisco/enic/enic_pp.c b/drivers/net/ethernet/cisco/enic/enic_pp.c
index c758674..dafea1e 100644
--- a/drivers/net/ethernet/cisco/enic/enic_pp.c
+++ b/drivers/net/ethernet/cisco/enic/enic_pp.c
@@ -72,7 +72,7 @@ static int enic_set_port_profile(struct enic *enic, int vf)
 	struct enic_port_profile *pp;
 	struct vic_provinfo *vp;
 	const u8 oui[3] = VIC_PROVINFO_CISCO_OUI;
-	const u16 os_type = htons(VIC_GENERIC_PROV_OS_TYPE_LINUX);
+	const __be16 os_type = htons(VIC_GENERIC_PROV_OS_TYPE_LINUX);
 	char uuid_str[38];
 	char client_mac_str[18];
 	u8 *client_mac;
-- 
1.7.4.4
