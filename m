From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] phy: marvell: remove LED config override
Date: Fri, 10 Jun 2016 20:38:57 +0200
Message-ID: <20160610183857.GF2338@lunn.ch>
References: <20160610174252.14017-1-clemens.gruber@pqgruber.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>
To: Clemens Gruber <clemens.gruber@pqgruber.com>,
	Sergei Poselenov <sposelenov@emcraft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41769 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751203AbcFJSjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 14:39:08 -0400
Content-Disposition: inline
In-Reply-To: <20160610174252.14017-1-clemens.gruber@pqgruber.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 10, 2016 at 07:42:52PM +0200, Clemens Gruber wrote:
> Configuring the PHY LED registers for the Marvell 88E1510 and others is
> not possible, because regardless of the values in marvell,reg-init, it
> is later overridden in m88e1121_config_aneg with a non-standard default.
> 
> This became visible after we moved the call of marvell_of_reg_init in
> commit 79be1a1c9090 ("phy: marvell: Fix and unify reg-init behavior").
> Moving it to _config_init was necessary due to the PHY state machine
> getting stuck if the PHY interrupts were not enabled early on.
> As that default LED configuration is set in _config_aneg, it overrides
> the marvell,reg-init configuration from the device tree.
> 
> This patch removes this override and allows the user to again set the
> PHY LED configuration through marvell,reg-init or if that does not
> exist, keep the original defaults as documented in the datasheet.

That override code exists for a reason. I don't like just removing it
without understanding why it is there. Sergei Poselenov added it as
part of the 1121 support. Maybe he knows why it is there?

     Andrew
