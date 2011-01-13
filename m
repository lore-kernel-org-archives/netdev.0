From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next-2.6] netdev: bfin_mac: Remove
 is_multicast_ether_addr use in netdev_for_each_mc_addr
Date: Wed, 12 Jan 2011 20:08:04 -0800
Message-ID: <1294891685.4114.29.camel@Joe-Laptop>
References: <1294824611-10483-1-git-send-email-tklauser@distanz.ch>
	 <AANLkTimztPZB3N+ZYNsDM9L3ZEM+x__bBc-JCRgO8iDC@mail.gmail.com>
	 <1294852681.4114.6.camel@Joe-Laptop>
	 <20110112.190143.184432859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vapier.adi@gmail.com, tklauser@distanz.ch,
	michael.hennerich@analog.com,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3119 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752027Ab1AMEIH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jan 2011 23:08:07 -0500
In-Reply-To: <20110112.190143.184432859.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove code that has no effect.

Signed-off-by: Joe Perches <joe@perches.com>

---

Uncompiled, untested...

> > Does a netdev_for_each_mc_addr loop entry really
> > need to verify that the address is multicast?
> > Couldn't this just be:
> It could, and I'd be happy to apply a follow-on patch that does
> this.

 drivers/net/bfin_mac.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index fe75e7a..22abfb3 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -1284,19 +1284,12 @@ static void bfin_mac_multicast_hash(struct net_device *dev)
 {
 	u32 emac_hashhi, emac_hashlo;
 	struct netdev_hw_addr *ha;
-	char *addrs;
 	u32 crc;
 
 	emac_hashhi = emac_hashlo = 0;
 
 	netdev_for_each_mc_addr(ha, dev) {
-		addrs = ha->addr;
-
-		/* skip non-multicast addresses */
-		if (!is_multicast_ether_addr(addrs))
-			continue;
-
-		crc = ether_crc(ETH_ALEN, addrs);
+		crc = ether_crc(ETH_ALEN, ha->addr);
 		crc >>= 26;
 
 		if (crc & 0x20)




