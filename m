From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/4] net: switchdev: Avoid sleep in atomic with
 DSA
Date: Mon, 9 Jan 2017 22:05:46 +0100
Message-ID: <20170109210546.GE13949@lunn.ch>
References: <20170109194503.10713-1-f.fainelli@gmail.com>
 <20170109204849.GA28310@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        jiri@resnulli.us
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53468 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932505AbdAIVFu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 16:05:50 -0500
Content-Disposition: inline
In-Reply-To: <20170109204849.GA28310@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 09, 2017 at 10:48:49PM +0200, Ido Schimmel wrote:
> Hi Florian,
> 
> On Mon, Jan 09, 2017 at 11:44:59AM -0800, Florian Fainelli wrote:
> > Hi all,
> > 
> > This patch series is to resolve a sleeping function called in atomic context
> > debug splat that we observe with DSA.
> > 
> > Let me know what you think, I was also wondering if we should just always
> > make switchdev_port_vlan_fill() set SWITCHDEV_F_DEFER, but was afraid this
> > could cause invalid contexts to be used for rocker, mlxsw, i40e etc.
> 
> Isn't this a bit of overkill? All the drivers you mention fill the VLAN
> dump from their cache and don't require sleeping.

Hi Ido

DSA in general does not cache information. It always ask the hardware.
So for mv88e6xxx, this is going to trigger MDIO operations, which take
mutex's and do sleep.

	Andrew
