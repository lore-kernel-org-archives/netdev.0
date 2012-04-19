From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] ksz884x: don't copy too much in netdev_set_mac_address()
Date: Thu, 19 Apr 2012 10:00:19 +0300
Message-ID: <20120419070018.GA16645@elgon.mountain>
References: <1334758394.3209.156.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tristram.Ha@micrel.com, Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:32680 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046Ab2DSHAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 03:00:49 -0400
Content-Disposition: inline
In-Reply-To: <1334758394.3209.156.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MAX_ADDR_LEN is 32.  ETH_ALEN is 6.  mac->sa_data is a 14 byte array, so
the memcpy() is doing a read past the end of the array.  I asked about
this on netdev and Ben Hutchings told me it's supposed to be copying
ETH_ALEN bytes (thanks Ben).

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index ef723b1..eaf9ff0 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -5675,7 +5675,7 @@ static int netdev_set_mac_address(struct net_device *dev, void *addr)
 		memcpy(hw->override_addr, mac->sa_data, ETH_ALEN);
 	}
 
-	memcpy(dev->dev_addr, mac->sa_data, MAX_ADDR_LEN);
+	memcpy(dev->dev_addr, mac->sa_data, ETH_ALEN);
 
 	interrupt = hw_block_intr(hw);
 
