From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Thu, 30 Jun 2016 11:01:46 +1000
Message-ID: <20160630110146.6becc338@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/phy/fixed_phy.c

between commit:

  69fc58a57e56 ("net: phy: Manage fixed PHY address space using IDA")

from Linus' tree and commit:

  bf7afb29d545 ("phy: improve safety of fixed-phy MII register reading")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/phy/fixed_phy.c
index 9ec7f7353434,b376ada83598..000000000000
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@@ -23,9 -23,9 +23,10 @@@
  #include <linux/slab.h>
  #include <linux/of.h>
  #include <linux/gpio.h>
+ #include <linux/seqlock.h>
 +#include <linux/idr.h>
  
- #define MII_REGS_NUM 29
+ #include "swphy.h"
  
  struct fixed_mdio_bus {
  	struct mii_bus *mii_bus;
