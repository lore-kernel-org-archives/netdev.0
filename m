From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [net:master 114/121] drivers/net/phy/mdio_bus.c:248: warning: No
 description found for parameter 'owner'
Date: Fri, 25 Sep 2015 11:56:56 +0100
Message-ID: <20150925105656.GK21513@n2100.arm.linux.org.uk>
References: <201509251554.GLQ5oOz9%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:46564 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164AbbIYK5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 06:57:08 -0400
Content-Disposition: inline
In-Reply-To: <201509251554.GLQ5oOz9%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 25, 2015 at 03:58:00PM +0800, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
> head:   b626ef0128d254d33ee43c51d68f577bbec370ac
> commit: 3e3aaf649416988ca8be4ad2c52dc24d8be7b46e [114/121] phy: fix mdiobus module safety
> config: i386-allnoconfig (attached as .config)
> reproduce:
>   git checkout 3e3aaf649416988ca8be4ad2c52dc24d8be7b46e
>   # save the attached .config to linux build tree
>   make ARCH=i386 
> 
> All warnings (new ones prefixed by >>):
> 
> >> drivers/net/phy/mdio_bus.c:248: warning: No description found for parameter 'owner'
> >> drivers/net/phy/mdio_bus.c:248: warning: No description found for parameter 'owner'

We could fix this new warning like this, but I'm not particularly happy
because it means we're documenting internals as an API, which it isn't.
IMHO, the original doc is correct - we're documenting mdiobus_register()
here, which is the preferred API which should be used everywhere, rather
than __mdiobus_register() which is the implementation detail.  I guess
docbook can't know that though.

So, is this something that should be fixed like the below?

8<===
From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH] net: update docbook comment for __mdiobus_register()

Update the docbook comment for __mdiobus_register() to include the new
module owner argument.  This resolves a warning found by the 0-day
builder.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/phy/mdio_bus.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index c340e412b38f..12f44c53cc8e 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -236,11 +236,14 @@ static inline void of_mdiobus_link_phydev(struct mii_bus *mdio,
 #endif
 
 /**
- * mdiobus_register - bring up all the PHYs on a given bus and attach them to bus
+ * __mdiobus_register - bring up all the PHYs on a given bus and attach them to bus
  * @bus: target mii_bus
+ * @owner: module containing bus accessor functions
  *
  * Description: Called by a bus driver to bring up all the PHYs
- *   on a given bus, and attach them to the bus.
+ *   on a given bus, and attach them to the bus. Drivers should use
+ *   mdiobus_register() rather than __mdiobus_register() unless they
+ *   need to pass a specific owner module.
  *
  * Returns 0 on success or < 0 on error.
  */
-- 
2.1.0



-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
