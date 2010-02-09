From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH net-next-2.6] be2net: bug fix in be_read_eeprom
Date: Tue, 9 Feb 2010 09:21:26 +0530
Message-ID: <20100209035115.GA6577@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f193.google.com ([209.85.210.193]:58839 "EHLO
	mail-yx0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217Ab0BIDvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 22:51:33 -0500
Received: by yxe31 with SMTP id 31so6405568yxe.21
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2010 19:51:33 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The offset to read the eeprom data was missing and
wrong eeprom data was being dumped. This patch fixes this.

>From Suresh R <sureshr@serverengines.com>
Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 09d8899..dcc7f37 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -614,7 +614,7 @@ be_read_eeprom(struct net_device *netdev, struct ethtool_eeprom *eeprom,
 
 	if (!status) {
 		resp = (struct be_cmd_resp_seeprom_read *) eeprom_cmd.va;
-		memcpy(data, resp->seeprom_data, eeprom->len);
+		memcpy(data, resp->seeprom_data + eeprom->offset, eeprom->len);
 	}
 	pci_free_consistent(adapter->pdev, eeprom_cmd.size, eeprom_cmd.va,
 			eeprom_cmd.dma);
-- 
1.6.3.3

