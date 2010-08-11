From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 4/7] enic: Use offsetof macro in vic tlv length
	calculation
Date: Tue, 10 Aug 2010 21:55:10 -0700
Message-ID: <20100811045510.3877.69037.stgit@savbu-pc100.cisco.com>
References: <20100811045436.3877.51650.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:9745 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950Ab0HKEzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 00:55:11 -0400
In-Reply-To: <20100811045436.3877.51650.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>



Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
---
 drivers/net/enic/vnic_vic.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)


diff --git a/drivers/net/enic/vnic_vic.c b/drivers/net/enic/vnic_vic.c
index 197c9d2..4725b79 100644
--- a/drivers/net/enic/vnic_vic.c
+++ b/drivers/net/enic/vnic_vic.c
@@ -54,8 +54,8 @@ int vic_provinfo_add_tlv(struct vic_provinfo *vp, u16 type, u16 length,
 	if (!vp || !value)
 		return -EINVAL;
 
-	if (ntohl(vp->length) + sizeof(*tlv) + length >
-		VIC_PROVINFO_MAX_TLV_DATA)
+	if (ntohl(vp->length) + offsetof(struct vic_provinfo_tlv, value) +
+		length > VIC_PROVINFO_MAX_TLV_DATA)
 		return -ENOMEM;
 
 	tlv = (struct vic_provinfo_tlv *)((u8 *)vp->tlv +
@@ -66,7 +66,8 @@ int vic_provinfo_add_tlv(struct vic_provinfo *vp, u16 type, u16 length,
 	memcpy(tlv->value, value, length);
 
 	vp->num_tlvs = htonl(ntohl(vp->num_tlvs) + 1);
-	vp->length = htonl(ntohl(vp->length) + sizeof(*tlv) + length);
+	vp->length = htonl(ntohl(vp->length) +
+		offsetof(struct vic_provinfo_tlv, value) + length);
 
 	return 0;
 }

