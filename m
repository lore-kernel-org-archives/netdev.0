From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc9420: handle magic field of ethtool_eeprom
Date: Mon, 16 Feb 2009 08:55:01 +0000
Message-ID: <1234774501-31978-1-git-send-email-steve.glendinning@smsc.com>
Cc: Vlad Lyalikov <vlad.lyalikov@smsc.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:58647 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754872AbZBPIyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 03:54:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool.h says the driver should set the magic field in get_eeprom and
verify it in set_eeprom.  This patch adds this functionality using an
arbitary driver-specific magic value constant (0x9420).

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc9420.c |    4 ++++
 drivers/net/smsc9420.h |    1 +
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index a1e4b38..8c74d3d 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -413,6 +413,7 @@ static int smsc9420_ethtool_get_eeprom(struct net_device *dev,
 	}
 
 	memcpy(data, &eeprom_data[eeprom->offset], len);
+	eeprom->magic = SMSC9420_EEPROM_MAGIC;
 	eeprom->len = len;
 	return 0;
 }
@@ -423,6 +424,9 @@ static int smsc9420_ethtool_set_eeprom(struct net_device *dev,
 	struct smsc9420_pdata *pd = netdev_priv(dev);
 	int ret;
 
+	if (eeprom->magic != SMSC9420_EEPROM_MAGIC)
+		return -EINVAL;
+
 	smsc9420_eeprom_enable_access(pd);
 	smsc9420_eeprom_send_cmd(pd, E2P_CMD_EPC_CMD_EWEN_);
 	ret = smsc9420_eeprom_write_location(pd, eeprom->offset, *data);
diff --git a/drivers/net/smsc9420.h b/drivers/net/smsc9420.h
index 69c351f..e441402 100644
--- a/drivers/net/smsc9420.h
+++ b/drivers/net/smsc9420.h
@@ -44,6 +44,7 @@
 #define LAN_REGISTER_EXTENT		(0x400)
 
 #define SMSC9420_EEPROM_SIZE		((u32)11)
+#define SMSC9420_EEPROM_MAGIC		(0x9420)
 
 #define PKT_BUF_SZ			(VLAN_ETH_FRAME_LEN + NET_IP_ALIGN + 4)
 
-- 
1.6.0.6

