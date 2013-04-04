From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next] enic: be less verbose about non-critical firmware errors
Date: Thu,  4 Apr 2013 18:57:08 +0200
Message-ID: <1365094628-21520-1-git-send-email-sassmann@kpanic.de>
Cc: davem@davemloft.net, neepatel@cisco.com, sassmann@kpanic.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51978 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763132Ab3DDQ6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 12:58:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a feature is not supported by firmware no need to print an error message.
This surpresses the following harmless message on boot up and ethtool query.
enic: Error 1 devcmd 36

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/cisco/enic/vnic_dev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index 605b222..97455c5 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -308,6 +308,9 @@ static int _vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 
 			if (status & STAT_ERROR) {
 				err = (int)readq(&devcmd->args[0]);
+				if (err == ERR_EINVAL &&
+				    cmd == CMD_CAPABILITY)
+					return err;
 				if (err != ERR_ECMDUNKNOWN ||
 				    cmd != CMD_CAPABILITY)
 					pr_err("Error %d devcmd %d\n",
-- 
1.8.1.4
