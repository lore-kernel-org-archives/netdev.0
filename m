From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6 3/6] be2net: check for valid ether address
Date: Mon, 30 Nov 2009 09:26:26 +0530
Message-ID: <20091130035616.GA15493@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:29490 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752885AbZK3D4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 22:56:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow only valid ether addresses to be assigned and used for the interface.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index e24f498..10262fa 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -125,6 +125,9 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 	struct sockaddr *addr = p;
 	int status = 0;
 
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
 	status = be_cmd_pmac_del(adapter, adapter->if_handle, adapter->pmac_id);
 	if (status)
 		return status;
@@ -2146,6 +2149,10 @@ static int be_get_config(struct be_adapter *adapter)
 			MAC_ADDRESS_TYPE_NETWORK, true /*permanent */, 0);
 	if (status)
 		return status;
+
+	if (!is_valid_ether_addr(mac))
+		return -EADDRNOTAVAIL;
+
 	memcpy(adapter->netdev->dev_addr, mac, ETH_ALEN);
 	memcpy(adapter->netdev->perm_addr, mac, ETH_ALEN);
 
-- 
1.6.3.3

