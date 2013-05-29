From: "Jens Renner (EFE)" <renner@efe-gmbh.de>
Subject: Re: [PATCH] net: ethernet: xilinx_emaclite: keep protocol selector
 bits by reading ANAR
Date: Wed, 29 May 2013 18:54:15 +0200
Message-ID: <51A632B7.8020201@efe-gmbh.de>
References: <51A4D6FE.3080308@efe-gmbh.de> <51A61D8C.6090100@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: monstr@monstr.eu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:61124 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759039Ab3E2QyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 12:54:07 -0400
In-Reply-To: <51A61D8C.6090100@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 29.05.2013 17:23, schrieb Michal Simek:
> On 05/28/2013 06:10 PM, Jens Renner (EFE) wrote:
>> This patch reads the PHY's MII_ADVERTISE register (ANAR) before modifying
>> it. Hence, the protocol selector bits (4:0) which indicate IEEE 803.3u
>> support are prevented from being cleared. While the selector bits are
>> fixed / read-only on some PHYs, not setting them correctly on others
>> (like TI DP83630) makes the PHY fall back to 10/half mode which should be
>> avoided.
>> 
>> Signed-off-by: Jens Renner <renner@efe-gmbh.de> --- 
>> drivers/net/ethernet/xilinx/xilinx_emaclite.c               |    7
>> +++++-- 1 file changed, 5 insertions(+), 2 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
>> b/drivers/net/ethernet/xilinx/xilinx_emaclite.c index 919b983..4a67af1
>> 100644 --- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c +++
>> b/drivers/net/ethernet/xilinx/xilinx_emaclite.c @@ -922,7 +922,7 @@ void
>> xemaclite_adjust_link(struct net_device *ndev) static int
>> xemaclite_open(struct net_device *dev) { struct net_local *lp =
>> netdev_priv(dev); -       int retval; +       int retval, adv;
>> 
>> /* Just to be safe, stop the device first */ 
>> xemaclite_disable_interrupts(lp); @@ -946,7 +946,10 @@ static int
>> xemaclite_open(struct net_device *dev) phy_write(lp->phy_dev,
>> MII_CTRL1000, 0);
>> 
>> /* Advertise only 10 and 100mbps full/half duplex speeds */ -
>> phy_write(lp->phy_dev, MII_ADVERTISE, ADVERTISE_ALL); +               adv
>> = phy_read(lp->phy_dev, MII_ADVERTISE); +               if (adv < 0) +
>> return adv; +               phy_write(lp->phy_dev, MII_ADVERTISE, adv |
>> ADVERTISE_ALL);
>> 
>> /* Restart auto negotiation */ bmcr = phy_read(lp->phy_dev, MII_BMCR);
> 
> Acked-by: Michal Simek <monstr@monstr.eu>
> 
> Thanks, Michal
> 
> 

Michal, please mind the follow-ups to my original list mail:
http://lists.openwall.net/netdev/2013/05/28/126
http://lists.openwall.net/netdev/2013/05/29/140
There will be a patch v2 later this day (I will put you in CC).
Thanks,
Jens.
