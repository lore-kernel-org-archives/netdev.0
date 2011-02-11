From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 07/15] be2net: For the VF MAC, use the OUI from
 current MAC address
Date: Fri, 11 Feb 2011 17:36:18 -0600
Message-ID: <20110211233618.GA18389@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51193 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757324Ab1BKXgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 18:36:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we are always using the Emulex OUI for a VF MAC address
while generating MAC for a VF.  Use OUI from current MAC instead.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be.h |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index add0b93..3a800e2 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -450,9 +450,8 @@ static inline void be_vf_eth_addr_generate(struct be_adapter *adapter, u8 *mac)
 	mac[5] = (u8)(addr & 0xFF);
 	mac[4] = (u8)((addr >> 8) & 0xFF);
 	mac[3] = (u8)((addr >> 16) & 0xFF);
-	mac[2] = 0xC9;
-	mac[1] = 0x00;
-	mac[0] = 0x00;
+	/* Use the OUI from the current MAC address */
+	memcpy(mac, adapter->netdev->dev_addr, 3);
 }
 
 extern void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
-- 
1.7.1

