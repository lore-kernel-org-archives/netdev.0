From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 2/8] enic: fix return value in _vnic_dev_cmd
Date: Tue, 10 Jun 2014 00:02:47 +0530
Message-ID: <1402338773-5996-3-git-send-email-_govind@gmx.com>
References: <1402338773-5996-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, gvaradar@cisco.com, benve@cisco.com,
	_govind@gmx.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:53113 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754320AbaFISd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 14:33:58 -0400
In-Reply-To: <1402338773-5996-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardware (in readq(&devcmd->args[0])) returns positive number in case of error.
But _vnic_dev_cmd should return a negative value in case of error.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/vnic_dev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index e86a45c..263081b 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -312,12 +312,12 @@ static int _vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 				err = (int)readq(&devcmd->args[0]);
 				if (err == ERR_EINVAL &&
 				    cmd == CMD_CAPABILITY)
-					return err;
+					return -err;
 				if (err != ERR_ECMDUNKNOWN ||
 				    cmd != CMD_CAPABILITY)
 					pr_err("Error %d devcmd %d\n",
 						err, _CMD_N(cmd));
-				return err;
+				return -err;
 			}
 
 			if (_CMD_DIR(cmd) & _CMD_DIR_READ) {
-- 
2.0.0
