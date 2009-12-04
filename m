From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Subject: [PATCH] mv643xx_eth: check for valid hw address
Date: Fri, 4 Dec 2009 14:51:38 +0300
Message-ID: <20091204115138.GA5532@coldcone>
Reply-To: kirjanov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:60610 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753049AbZLDLtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 06:49:47 -0500
Received: by bwz27 with SMTP id 27so1872408bwz.21
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2009 03:49:53 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check for valid hw address.

Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>

---
drivers/net/mv643xx_eth.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 796a493..0b85501 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1827,6 +1827,9 @@ static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr *sa = addr;
 
+	if (!is_valid_ether_addr(sa->sa_data))
+		return -EADDRNOTAVAIL;
+
 	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
 
 	netif_addr_lock_bh(dev);
