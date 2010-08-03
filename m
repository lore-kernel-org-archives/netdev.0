From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net/enic: Use %pUB to format a UUID
Date: Tue, 03 Aug 2010 12:32:24 -0700
Message-ID: <1280863944.6088.2.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/enic/enic_main.c |   17 ++---------------
 1 files changed, 2 insertions(+), 15 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 77a7f87..9aab853 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1087,10 +1087,7 @@ static int enic_set_port_profile(struct enic *enic, u8 *mac)
 {
 	struct vic_provinfo *vp;
 	u8 oui[3] = VIC_PROVINFO_CISCO_OUI;
-	u8 *uuid;
 	char uuid_str[38];
-	static char *uuid_fmt = "%02X%02X%02X%02X-%02X%02X-%02X%02X-"
-		"%02X%02X-%02X%02X%02X%02X%0X%02X";
 	int err;
 
 	err = enic_vnic_dev_deinit(enic);
@@ -1121,24 +1118,14 @@ static int enic_set_port_profile(struct enic *enic, u8 *mac)
 			ETH_ALEN, mac);
 
 		if (enic->pp.set & ENIC_SET_INSTANCE) {
-			uuid = enic->pp.instance_uuid;
-			sprintf(uuid_str, uuid_fmt,
-				uuid[0],  uuid[1],  uuid[2],  uuid[3],
-				uuid[4],  uuid[5],  uuid[6],  uuid[7],
-				uuid[8],  uuid[9],  uuid[10], uuid[11],
-				uuid[12], uuid[13], uuid[14], uuid[15]);
+			sprintf(uuid_str, "%pUB", enic->pp.instance_uuid);
 			vic_provinfo_add_tlv(vp,
 				VIC_LINUX_PROV_TLV_CLIENT_UUID_STR,
 				sizeof(uuid_str), uuid_str);
 		}
 
 		if (enic->pp.set & ENIC_SET_HOST) {
-			uuid = enic->pp.host_uuid;
-			sprintf(uuid_str, uuid_fmt,
-				uuid[0],  uuid[1],  uuid[2],  uuid[3],
-				uuid[4],  uuid[5],  uuid[6],  uuid[7],
-				uuid[8],  uuid[9],  uuid[10], uuid[11],
-				uuid[12], uuid[13], uuid[14], uuid[15]);
+			sprintf(uuid_str, "%pUB", enic->pp.host_uuid);
 			vic_provinfo_add_tlv(vp,
 				VIC_LINUX_PROV_TLV_HOST_UUID_STR,
 				sizeof(uuid_str), uuid_str);
