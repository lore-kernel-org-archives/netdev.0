From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning after merge of the nettree
Date: Wed, 21 Jul 2010 21:11:16 -0700 (PDT)
Message-ID: <20100721.211116.98027768.davem@davemloft.net>
References: <20100722120639.cc8d56a5.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, richardcochran@gmail.com,
	florian@openwrt.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100722120639.cc8d56a5.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 22 Jul 2010 12:06:39 +1000

> After merging the net tree, today's linux-next build (x86_64 allmodconfig)
> produced this warning:
> 
> drivers/net/r6040.c: In function 'r6040_ioctl':
> drivers/net/r6040.c:513: warning: passing argument 2 of 'phy_mii_ioctl' from incompatible pointer type
> include/linux/phy.h:522: note: expected 'struct ifreq *' but argument is of type 'struct mii_ioctl_data *'
> 
> Introduced by commit 28b041139e344ecd0f144d6205b004ae354cfa1e ("net:
> preserve ifreq parameter when calling generic phy_mii_ioctl()") (which
> changed the phy_mii_ioctl() API) interacting with commit
> 3831861b4ad8fd0ad7110048eb3e155628799d2b ("r6040: implement phylib")
> (which added a use of that function).

Thanks Stephen, should be fixed as follows:

--------------------
r6040: Fix args to phy_mii_ioctl().

Reported by Stephen Rothwell.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/r6040.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 7d482a2..142c381 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -510,7 +510,7 @@ static int r6040_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!lp->phydev)
 		return -EINVAL;
 
-	return phy_mii_ioctl(lp->phydev, if_mii(rq), cmd);
+	return phy_mii_ioctl(lp->phydev, rq, cmd);
 }
 
 static int r6040_rx(struct net_device *dev, int limit)
-- 
1.7.1.1
