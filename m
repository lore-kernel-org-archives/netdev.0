From: Amy Fong <amy.fong@windriver.com>
Subject: Re: [PATCH] Add Broadcom PHY support
Date: Tue, 5 Dec 2006 00:55:16 -0500 (EST)
Message-ID: <E1GrTGu-0005QS-OH@lucciola>
References: <1165266999.29784.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:47146 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967409AbWLEFze (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 00:55:34 -0500
In-Reply-To: <1165266999.29784.20.camel@localhost.localdomain>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Fri, 2006-09-15 at 16:15 -0400, Amy Fong wrote:
> > [PATCH] Add Broadcom PHY support
> > 
> > This patch adds a driver to support the bcm5421s and bcm5461s PHY
> > 
> > Kernel version:  linux-2.6.18-rc6
> > 
> > Signed-off-by: Amy Fong 
> 
> Some 5421's need special initialisation (see drivers/net/sungem_phy.c),
> might be worth having them there too. I was also wondering... for
> spidernet, we need to enable the fiber mode on the PHY. Does phylib has
> an API for that ?
> 
> I'd like to look into moving sungem and spidernet over to phylib.
> 
> Ben.


I believe that this fiber enabling can be done by defining config_init in the phy_driver struct.

struct phy_driver {
<snip>
        /* Called to initialize the PHY,
	 * including after a reset */
	int (*config_init)(struct phy_device *phydev);
<snip>
};

ie.

static struct phy_driver bcm5421s_driver = {
<snip>
	.config_init = bcm5421s_phy_config,
<snip>
};

int bcm5421s_phy_config(struct phy_device *phydev)
{
...
	/* enable fiber mode here... */
...
}

Amy
