From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next-2.6 PATCH 1/2] enic: bug fix: sprintf UUID to string as
	u8[] rather than u16[] array
Date: Sat, 22 May 2010 20:29:52 -0700
Message-ID: <20100523032952.20200.30148.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:4913 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193Ab0EWD3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 23:29:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>



Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic_main.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index e125113..7e97323 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1034,9 +1034,10 @@ static int enic_set_port_profile(struct enic *enic, u8 request, u8 *mac,
 {
 	struct vic_provinfo *vp;
 	u8 oui[3] = VIC_PROVINFO_CISCO_OUI;
-	unsigned short *uuid;
+	u8 *uuid;
 	char uuid_str[38];
-	static char *uuid_fmt = "%04X%04X-%04X-%04X-%04X-%04X%04X%04X";
+	static char *uuid_fmt = "%02X%02X%02X%02X-%02X%02X-%02X%02X-"
+		"%02X%02X-%02X%02X%02X%02X%0X%02X";
 	int err;
 
 	if (!name)
@@ -1058,20 +1059,24 @@ static int enic_set_port_profile(struct enic *enic, u8 request, u8 *mac,
 		ETH_ALEN, mac);
 
 	if (instance_uuid) {
-		uuid = (unsigned short *)instance_uuid;
+		uuid = instance_uuid;
 		sprintf(uuid_str, uuid_fmt,
-			uuid[0], uuid[1], uuid[2], uuid[3],
-			uuid[4], uuid[5], uuid[6], uuid[7]);
+			uuid[0],  uuid[1],  uuid[2],  uuid[3],
+			uuid[4],  uuid[5],  uuid[6],  uuid[7],
+			uuid[8],  uuid[9],  uuid[10], uuid[11],
+			uuid[12], uuid[13], uuid[14], uuid[15]);
 		vic_provinfo_add_tlv(vp,
 			VIC_LINUX_PROV_TLV_CLIENT_UUID_STR,
 			sizeof(uuid_str), uuid_str);
 	}
 
 	if (host_uuid) {
-		uuid = (unsigned short *)host_uuid;
+		uuid = host_uuid;
 		sprintf(uuid_str, uuid_fmt,
-			uuid[0], uuid[1], uuid[2], uuid[3],
-			uuid[4], uuid[5], uuid[6], uuid[7]);
+			uuid[0],  uuid[1],  uuid[2],  uuid[3],
+			uuid[4],  uuid[5],  uuid[6],  uuid[7],
+			uuid[8],  uuid[9],  uuid[10], uuid[11],
+			uuid[12], uuid[13], uuid[14], uuid[15]);
 		vic_provinfo_add_tlv(vp,
 			VIC_LINUX_PROV_TLV_HOST_UUID_STR,
 			sizeof(uuid_str), uuid_str);

