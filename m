From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: phy: marvell: Add support for 88e1545 PHY
Date: Thu, 2 Feb 2017 14:17:41 +0100
Message-ID: <20170202131741.GJ4967@lunn.ch>
References: <1485992103-23331-1-git-send-email-andrew@lunn.ch>
 <c9fb2430-d42b-0306-084d-6af2fb763fdf@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53381 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751027AbdBBNkc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 08:40:32 -0500
Content-Disposition: inline
In-Reply-To: <c9fb2430-d42b-0306-084d-6af2fb763fdf@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2017 at 12:55:16PM +0300, Sergei Shtylyov wrote:
> Hello!
> 
> On 2/2/2017 2:35 AM, Andrew Lunn wrote:
> 
> >The 88e1545 PHYs are discrete Marvell PHYs, found in a quad package on
> >the zii-devel-b board. Add support for it to the Marvell PHY driver.
> >
> >Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> >---
> >
> >NOTE: To apply cleanly, the "Work around missing PHY product ID in mv88e6390"
> >patches need to be applied first.
> >
> >drivers/net/phy/marvell.c   | 21 +++++++++++++++++++++
> > include/linux/marvell_phy.h |  1 +
> > 2 files changed, 22 insertions(+)
> >
> >diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> >index 1a0ac48cbc50..f9d0fa315a47 100644
> >--- a/drivers/net/phy/marvell.c
> >+++ b/drivers/net/phy/marvell.c
> >@@ -2123,6 +2123,26 @@ static struct phy_driver marvell_drivers[] = {
> > 		.get_stats = marvell_get_stats,
> > 	},
> > 	{
> >+		.phy_id = MARVELL_PHY_ID_88E1545,
> >+		.phy_id_mask = MARVELL_PHY_ID_MASK,
> >+		.name = "Marvell 88E1545",
> >+		.probe = m88e1510_probe,
> >+		.remove = &marvell_remove,
> >+		.features = PHY_GBIT_FEATURES,
> >+		.flags = PHY_HAS_INTERRUPT,
> >+		.config_init = &marvell_config_init,
> >+		.config_aneg = &m88e1510_config_aneg,
> >+		.read_status = &marvell_read_status,
> >+		.ack_interrupt = &marvell_ack_interrupt,
> >+		.config_intr = &marvell_config_intr,
> >+		.did_interrupt = &m88e1121_did_interrupt,
> >+		.resume = &genphy_resume,
> >+		.suspend = &genphy_suspend,
> >+		.get_sset_count = marvell_get_sset_count,
> >+		.get_strings = marvell_get_strings,
> >+		.get_stats = marvell_get_stats,
> 
>    Using & on some method inits and not using it on others doesn't
> look very consistent...

Hi Sergei

Very true. I think it has been historically like that, and adding new
PHYs is mostly a cut/paste operation. With this list getting longer
all the time, i'm thinking we should start using some macros.

Are you O.K. with the patch as it is, and a follow-up series to follow
soon?
	Thanks
		Andrew
