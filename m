From: David Miller <davem@davemloft.net>
Subject: Re: tg3 and Broadcom PHY driver
Date: Fri, 09 Oct 2009 14:25:17 -0700 (PDT)
Message-ID: <20091009.142517.265179839.davem@davemloft.net>
References: <4AC13036.8030506@embedded-sol.com>
	<20090928.145522.151077608.davem@davemloft.net>
	<1254185639.27790.3.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: felix@embedded-sol.com, mcarlson@broadcom.com,
	netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55818
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760944AbZJIVZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 17:25:22 -0400
In-Reply-To: <1254185639.27790.3.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 29 Sep 2009 01:53:59 +0100

> On Mon, 2009-09-28 at 14:55 -0700, David Miller wrote:
>> From: Felix Radensky <felix@embedded-sol.com>
>> Date: Mon, 28 Sep 2009 23:52:54 +0200
>> 
>> > Yes, moving CONFIG_TIGON3 right after CONFIG_PHYLIB in
>> > drivers/net/Makefile fixes the problem for me.
>> 
>> Thanks for testing.
>> 
>> We really need to fix this generically.
>> 
>> Does anyone think that moving the MDIO/MII/PHY layer objects
>> to the top of drivers/net/Makefile will break anything?
>> 
>> If not, that's what we should do I think.
> 
> Only the phylib drivers actually need to be moved to fix the
> initialisation order, but moving the others shouldn't hurt.

Ok, I'm adding the following to net-2.6 to resolve this and
will queue it up for -stable too.

Thanks everyone.

net: Link in PHY drivers before others.

We need PHY drivers to initialize in a static kernel before
the MAC drivers that use them.  So link them in first.

Based upon a report by Felix Radensky.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/Makefile |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index d866b8c..48d82e9 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -2,6 +2,10 @@
 # Makefile for the Linux network (ethercard) device drivers.
 #
 
+obj-$(CONFIG_MII) += mii.o
+obj-$(CONFIG_MDIO) += mdio.o
+obj-$(CONFIG_PHYLIB) += phy/
+
 obj-$(CONFIG_TI_DAVINCI_EMAC) += davinci_emac.o
 
 obj-$(CONFIG_E1000) += e1000/
@@ -100,10 +104,6 @@ obj-$(CONFIG_SH_ETH) += sh_eth.o
 # end link order section
 #
 
-obj-$(CONFIG_MII) += mii.o
-obj-$(CONFIG_MDIO) += mdio.o
-obj-$(CONFIG_PHYLIB) += phy/
-
 obj-$(CONFIG_SUNDANCE) += sundance.o
 obj-$(CONFIG_HAMACHI) += hamachi.o
 obj-$(CONFIG_NET) += Space.o loopback.o
-- 
1.6.4.4

