From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/2 net-next] phy: allow flagging a device as internal
Date: Tue, 21 May 2013 17:44:27 +0100
Message-ID: <1369154667.2615.17.camel@bwh-desktop.uk.solarflarecom.com>
References: <1369132626-13776-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<afleming@freescale.com>, <jogo@openwrt.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:53777 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753794Ab3EUQoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 12:44:30 -0400
In-Reply-To: <1369132626-13776-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-21 at 11:37 +0100, Florian Fainelli wrote:
> David, Andy,
> 
> This small patch set updates libphy to allow PHY drivers to flag a
> specific PHY device as internal, which is then used to accurately
> report the transceiver type (internal vs external) in ethtool.
> 
> As far as I can tell we only have one in-tree driver for the moment
> which is known to be for internal PHYs.

I don't think you should make any change like this until there is proper
documentation of what the 'transceiver' field actually means.

It appears that XCVR_EXTERNAL was originally used for a transceiver
module external to the system, usually connected to an AUI port.  The
modern equivalent of that might be SFP+ and similar module slots, but
they're a bit different because the Physical Coding Sublayer is usually
part of the controller.

Many newer drivers are using XCVR_EXTERNAL to indicate that the PHY is a
separate package from the controller, which is what you seem to be doing
here.  But nowhere is that specified!

The transceiver field doesn't even really matter much unless the user
has a choice of which to use.  Does anyone make boards like that any
more?  And it's probably entirely redundant with the port and
phy_address fields in that case, anyway.

Ben.

> Florian Fainelli (2):
>   phy: allow drivers to flag a PHY device as internal
>   phy: bcm63xx: report Broadcom BCM63xx PHYs as internal
> 
>  drivers/net/phy/bcm63xx.c    | 4 ++--
>  drivers/net/phy/phy.c        | 2 +-
>  drivers/net/phy/phy_device.c | 3 +++
>  include/linux/phy.h          | 3 +++
>  4 files changed, 9 insertions(+), 3 deletions(-)
> 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
