From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] be2net: check properly status in lancer_cmd_get_file_len()
Date: Fri, 13 Nov 2015 10:52:41 +0100
Message-ID: <1447408361-7498-1-git-send-email-ivecera@redhat.com>
Cc: sriharsha.basavapatna@avagotech.com, sathya.perla@avagotech.com,
	ajit.khaparde@avagotech.com, padmanabh.ratnakar@avagotech.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754748AbbKMJwo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 04:52:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lancer_cmd_get_file_len() calls lancer_cmd_read_object() to get
the current size of registers for ethtool registers dump. The size
is stored in data_read but only when the returned status is 0 otherwise
it is uninitialized thus random.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index f4cb8e4..26b6192 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -248,6 +248,8 @@ static u32 lancer_cmd_get_file_len(struct be_adapter *adapter, u8 *file_name)
 	status = lancer_cmd_read_object(adapter, &data_len_cmd, 0, 0,
 					file_name, &data_read, &eof,
 					&addn_status);
+	if (status)
+		return 0;
 
 	return data_read;
 }
-- 
2.4.10
