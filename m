From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC PATCH net-next 7/8] net: dsa: mv88e6060: make it a proper
 PHY driver
Date: Thu, 30 Apr 2015 06:49:29 -0700
Message-ID: <554232E9.5080104@roeck-us.net>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com> <1430359064-23454-8-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dave@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:34434 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbbD3NuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 09:50:25 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.85)
	(envelope-from <linux@roeck-us.net>)
	id 1YnorA-003gJ1-9r
	for netdev@vger.kernel.org; Thu, 30 Apr 2015 13:50:24 +0000
In-Reply-To: <1430359064-23454-8-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/29/2015 06:57 PM, Florian Fainelli wrote:
> Convert the Marvell 88E6060 switch driver into a proper PHY library
> driver that can be registered. To make sure we do not introduce
> functional changes, the PHY driver provides autoneg and status callbacks
> to make sure the attached Ethernet MAC driver still sees a link UP at
> the CPU port full speed.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>   drivers/net/dsa/mv88e6060.c | 114 ++++++++++++++++++++++++++++++++++++++++++--
>   1 file changed, 109 insertions(+), 5 deletions(-)
>

The whole complexity added here makes me wonder if we are really on the right track.
After all, switches are _not_ phy devices. Forcing them to register as phy devices
just because they use mdio and just because the Linux mdio implementation assumes
that anything connected to it is a phy seems odd.

A much better solution might be be to disconnect mdio from phy, ie to create a new
mdio bus framework, as then use this framework for anything connected to an mdio bus.

Does this make any sense, or am I completely off track ?

Thanks,
Guenter
