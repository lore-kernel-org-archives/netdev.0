From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next] be2net: remove local variable 'status'
Date: Wed, 18 Nov 2015 14:06:34 +0100
Message-ID: <1447851994-12075-1-git-send-email-ivecera@redhat.com>
Cc: sriharsha.basavapatna@avagotech.com, sathya.perla@avagotech.com,
	ajit.khaparde@avagotech.com, padmanabh.ratnakar@avagotech.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47991 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753953AbbKRNGi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 08:06:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lancer_cmd_get_file_len() uses lancer_cmd_read_object() to get
the current size of registers for ethtool registers dump. Returned status
value is stored but not checked. The check itself is not necessary as
the data_read output variable is initialized to 0 and status variable
can be removed.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 734f655..d2a5baf 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -241,13 +241,11 @@ static u32 lancer_cmd_get_file_len(struct be_adapter *adapter, u8 *file_name)
 	u32 data_read = 0, eof;
 	u8 addn_status;
 	struct be_dma_mem data_len_cmd;
-	int status;
 
 	memset(&data_len_cmd, 0, sizeof(data_len_cmd));
 	/* data_offset and data_size should be 0 to get reg len */
-	status = lancer_cmd_read_object(adapter, &data_len_cmd, 0, 0,
-					file_name, &data_read, &eof,
-					&addn_status);
+	lancer_cmd_read_object(adapter, &data_len_cmd, 0, 0, file_name,
+			       &data_read, &eof, &addn_status);
 
 	return data_read;
 }
-- 
2.4.10
