From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 3/4] enic: Cleanups in port profile helper code
Date: Tue, 29 Mar 2011 23:36:02 -0700
Message-ID: <20110330063602.7187.55953.stgit@savbu-pc100.cisco.com>
References: <20110330063533.7187.80458.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:14662 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754339Ab1C3GgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 02:36:02 -0400
In-Reply-To: <20110330063533.7187.80458.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch does the following:
- Introduces a new macro VIC_PROVINFO_ADD_TLV
- Adds a new OS type in vic_generic_prov_os_type
- Changes some vic_provinfo* helper routine args to constants

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 drivers/net/enic/vnic_vic.c |    5 +++--
 drivers/net/enic/vnic_vic.h |   13 +++++++++++--
 2 files changed, 14 insertions(+), 4 deletions(-)


diff --git a/drivers/net/enic/vnic_vic.c b/drivers/net/enic/vnic_vic.c
index 4725b79..24ef8cd 100644
--- a/drivers/net/enic/vnic_vic.c
+++ b/drivers/net/enic/vnic_vic.c
@@ -23,7 +23,8 @@
 
 #include "vnic_vic.h"
 
-struct vic_provinfo *vic_provinfo_alloc(gfp_t flags, u8 *oui, u8 type)
+struct vic_provinfo *vic_provinfo_alloc(gfp_t flags, const u8 *oui,
+	const u8 type)
 {
 	struct vic_provinfo *vp;
 
@@ -47,7 +48,7 @@ void vic_provinfo_free(struct vic_provinfo *vp)
 }
 
 int vic_provinfo_add_tlv(struct vic_provinfo *vp, u16 type, u16 length,
-	void *value)
+	const void *value)
 {
 	struct vic_provinfo_tlv *tlv;
 
diff --git a/drivers/net/enic/vnic_vic.h b/drivers/net/enic/vnic_vic.h
index f700f5d..9ef81f1 100644
--- a/drivers/net/enic/vnic_vic.h
+++ b/drivers/net/enic/vnic_vic.h
@@ -47,6 +47,7 @@ enum vic_generic_prov_os_type {
 	VIC_GENERIC_PROV_OS_TYPE_ESX = 1,
 	VIC_GENERIC_PROV_OS_TYPE_LINUX = 2,
 	VIC_GENERIC_PROV_OS_TYPE_WINDOWS = 3,
+	VIC_GENERIC_PROV_OS_TYPE_SOLARIS = 4,
 };
 
 struct vic_provinfo {
@@ -61,14 +62,22 @@ struct vic_provinfo {
 	} tlv[0];
 } __packed;
 
+#define VIC_PROVINFO_ADD_TLV(vp, tlvtype, tlvlen, data) \
+	do { \
+		err = vic_provinfo_add_tlv(vp, tlvtype, tlvlen, data); \
+		if (err) \
+			goto add_tlv_failure; \
+	} while (0)
+
 #define VIC_PROVINFO_MAX_DATA		1385
 #define VIC_PROVINFO_MAX_TLV_DATA (VIC_PROVINFO_MAX_DATA - \
 	sizeof(struct vic_provinfo))
 
-struct vic_provinfo *vic_provinfo_alloc(gfp_t flags, u8 *oui, u8 type);
+struct vic_provinfo *vic_provinfo_alloc(gfp_t flags, const u8 *oui,
+	const u8 type);
 void vic_provinfo_free(struct vic_provinfo *vp);
 int vic_provinfo_add_tlv(struct vic_provinfo *vp, u16 type, u16 length,
-	void *value);
+	const void *value);
 size_t vic_provinfo_size(struct vic_provinfo *vp);
 
 #endif	/* _VNIC_VIC_H_ */

