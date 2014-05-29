From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e/i40evf: Remove reserved PCTYPE defines
Date: Thu, 29 May 2014 08:10:07 -0700
Message-ID: <1401376216-12531-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kevin Scott <kevin.c.scott@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51814 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932940AbaE2PKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:10:38 -0400
In-Reply-To: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Scott <kevin.c.scott@intel.com>

Patch to remove PCTYPE definitions which are now reserved.

Change-ID: I66c1c16a45a16f4894b2983101ab2a48ce03f1f4
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 24 +++++++--------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    | 29 +++++++++++---------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h    |  5 -----
 drivers/net/ethernet/intel/i40e/i40e_type.h    | 10 +++------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h  |  5 -----
 drivers/net/ethernet/intel/i40evf/i40e_type.h  | 10 +++------
 6 files changed, 26 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index a7bf149..8a6fef2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1288,16 +1288,12 @@ static int i40e_set_rss_hash_opt(struct i40e_pf *pf, struct ethtool_rxnfc *nfc)
 	case UDP_V4_FLOW:
 		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
 		case 0:
-			hena &=
-			~(((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) |
-			((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP) |
-			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV4));
+			hena &= ~(((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_UDP) |
+				  ((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV4));
 			break;
 		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
-			hena |=
-			(((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP)  |
-			((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP) |
-			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV4));
+			hena |= (((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_UDP) |
+				  ((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV4));
 			break;
 		default:
 			return -EINVAL;
@@ -1306,16 +1302,12 @@ static int i40e_set_rss_hash_opt(struct i40e_pf *pf, struct ethtool_rxnfc *nfc)
 	case UDP_V6_FLOW:
 		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
 		case 0:
-			hena &=
-			~(((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP) |
-			((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP) |
-			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV6));
+			hena &= ~(((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_UDP) |
+				  ((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV6));
 			break;
 		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
-			hena |=
-			(((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP)  |
-			((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP) |
-			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV6));
+			hena |= (((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_UDP) |
+				 ((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV6));
 			break;
 		default:
 			return -EINVAL;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 8d0ef44..1ecd9aa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -184,7 +184,6 @@ static int i40e_add_del_fdir_udpv4(struct i40e_vsi *vsi,
 	struct iphdr *ip;
 	bool err = false;
 	int ret;
-	int i;
 	static char packet[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x08, 0,
 		0x45, 0, 0, 0x1c, 0, 0, 0x40, 0, 0x40, 0x11, 0, 0, 0, 0, 0, 0,
 		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
@@ -200,21 +199,17 @@ static int i40e_add_del_fdir_udpv4(struct i40e_vsi *vsi,
 	ip->saddr = fd_data->src_ip[0];
 	udp->source = fd_data->src_port;
 
-	for (i = I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP;
-	     i <= I40E_FILTER_PCTYPE_NONF_IPV4_UDP; i++) {
-		fd_data->pctype = i;
-		ret = i40e_program_fdir_filter(fd_data, raw_packet, pf, add);
-
-		if (ret) {
-			dev_info(&pf->pdev->dev,
-				 "Filter command send failed for PCTYPE %d (ret = %d)\n",
-				 fd_data->pctype, ret);
-			err = true;
-		} else {
-			dev_info(&pf->pdev->dev,
-				 "Filter OK for PCTYPE %d (ret = %d)\n",
-				 fd_data->pctype, ret);
-		}
+	fd_data->pctype = I40E_FILTER_PCTYPE_NONF_IPV4_UDP;
+	ret = i40e_program_fdir_filter(fd_data, raw_packet, pf, add);
+	if (ret) {
+		dev_info(&pf->pdev->dev,
+			 "Filter command send failed for PCTYPE %d (ret = %d)\n",
+			 fd_data->pctype, ret);
+		err = true;
+	} else {
+		dev_info(&pf->pdev->dev,
+			 "Filter OK for PCTYPE %d (ret = %d)\n",
+			 fd_data->pctype, ret);
 	}
 
 	return err ? -EOPNOTSUPP : 0;
@@ -263,7 +258,7 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 		}
 	}
 
-	fd_data->pctype = I40E_FILTER_PCTYPE_NONF_IPV4_TCP_SYN;
+	fd_data->pctype = I40E_FILTER_PCTYPE_NONF_IPV4_TCP;
 	ret = i40e_program_fdir_filter(fd_data, raw_packet, pf, add);
 
 	if (ret) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index d534969..71fbba9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -69,16 +69,11 @@ enum i40e_dyn_idx_t {
 
 /* Supported RSS offloads */
 #define I40E_DEFAULT_RSS_HENA ( \
-	((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) | \
-	((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_UDP) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_SCTP) | \
-	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_TCP_SYN) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_TCP) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_OTHER) | \
 	((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV4) | \
-	((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP) | \
-	((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_UDP) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_TCP_SYN) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_TCP) | \
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index c4df8ba..0fe158c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -866,18 +866,14 @@ struct i40e_filter_program_desc {
 
 /* Packet Classifier Types for filters */
 enum i40e_filter_pctype {
-	/* Note: Values 0-28 are reserved for future use */
-	I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP	= 29,
-	I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP	= 30,
+	/* Note: Values 0-30 are reserved for future use */
 	I40E_FILTER_PCTYPE_NONF_IPV4_UDP		= 31,
-	I40E_FILTER_PCTYPE_NONF_IPV4_TCP_SYN		= 32,
+	/* Note: Value 32 is reserved for future use */
 	I40E_FILTER_PCTYPE_NONF_IPV4_TCP		= 33,
 	I40E_FILTER_PCTYPE_NONF_IPV4_SCTP		= 34,
 	I40E_FILTER_PCTYPE_NONF_IPV4_OTHER		= 35,
 	I40E_FILTER_PCTYPE_FRAG_IPV4			= 36,
-	/* Note: Values 37-38 are reserved for future use */
-	I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP	= 39,
-	I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP	= 40,
+	/* Note: Values 37-40 are reserved for future use */
 	I40E_FILTER_PCTYPE_NONF_IPV6_UDP		= 41,
 	I40E_FILTER_PCTYPE_NONF_IPV6_TCP_SYN		= 42,
 	I40E_FILTER_PCTYPE_NONF_IPV6_TCP		= 43,
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index d0119d0..a23c34e 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -69,16 +69,11 @@ enum i40e_dyn_idx_t {
 
 /* Supported RSS offloads */
 #define I40E_DEFAULT_RSS_HENA ( \
-	((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) | \
-	((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_UDP) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_SCTP) | \
-	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_TCP_SYN) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_TCP) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_OTHER) | \
 	((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV4) | \
-	((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP) | \
-	((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_UDP) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_TCP_SYN) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_TCP) | \
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index fb5371a..c854cca 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -866,18 +866,14 @@ struct i40e_filter_program_desc {
 
 /* Packet Classifier Types for filters */
 enum i40e_filter_pctype {
-	/* Note: Values 0-28 are reserved for future use */
-	I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP	= 29,
-	I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP	= 30,
+	/* Note: Values 0-30 are reserved for future use */
 	I40E_FILTER_PCTYPE_NONF_IPV4_UDP		= 31,
-	I40E_FILTER_PCTYPE_NONF_IPV4_TCP_SYN		= 32,
+	/* Note: Value 32 is reserved for future use */
 	I40E_FILTER_PCTYPE_NONF_IPV4_TCP		= 33,
 	I40E_FILTER_PCTYPE_NONF_IPV4_SCTP		= 34,
 	I40E_FILTER_PCTYPE_NONF_IPV4_OTHER		= 35,
 	I40E_FILTER_PCTYPE_FRAG_IPV4			= 36,
-	/* Note: Values 37-38 are reserved for future use */
-	I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP	= 39,
-	I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP	= 40,
+	/* Note: Values 37-40 are reserved for future use */
 	I40E_FILTER_PCTYPE_NONF_IPV6_UDP		= 41,
 	I40E_FILTER_PCTYPE_NONF_IPV6_TCP_SYN		= 42,
 	I40E_FILTER_PCTYPE_NONF_IPV6_TCP		= 43,
-- 
1.9.3
