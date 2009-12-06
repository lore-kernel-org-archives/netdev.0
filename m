From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Subject: [PATCH] mv643xx_eth: check for valid hw address (resubmit)
Date: Sun, 6 Dec 2009 13:36:33 +0300
Message-ID: <20091206103633.GA4407@coldcone>
References: <20091204115138.GA5532@coldcone>
 <20091204.133042.10804388.davem@davemloft.net>
Reply-To: kirjanov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:39328 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933212AbZLFKem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 05:34:42 -0500
Received: by bwz27 with SMTP id 27so2872857bwz.21
        for <netdev@vger.kernel.org>; Sun, 06 Dec 2009 02:34:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091204.133042.10804388.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 04, 2009 at 13:30 -0800, David Miller wrote:
> From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
> Date: Fri, 4 Dec 2009 14:51:38 +0300
> 
> > Check for valid hw address.
> > 
> > Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>
> 
> Assuming we don't accept your other patch this needs
> to return -EINVAL.
(resubmitted due the fix in the return value)

Check for valid hw address.

Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>
---

 drivers/net/mv643xx_eth.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 796a493..1405a17 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1827,6 +1827,9 @@ static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr *sa = addr;
 
+	if (!is_valid_ether_addr(sa->sa_data))
+		return -EINVAL;
+
 	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
 
 	netif_addr_lock_bh(dev);


