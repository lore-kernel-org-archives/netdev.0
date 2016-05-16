From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] phy dp83867: depend on CONFIG_OF_MDIO
Date: Mon, 16 May 2016 14:44:44 +0200
Message-ID: <20160516124444.GB27725@lunn.ch>
References: <1463398095-123269-1-git-send-email-agraf@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	michal.simek@xilinx.com, Dan Murphy <dmurphy@ti.com>
To: Alexander Graf <agraf@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39255 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752770AbcEPMot (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2016 08:44:49 -0400
Content-Disposition: inline
In-Reply-To: <1463398095-123269-1-git-send-email-agraf@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2016 at 01:28:15PM +0200, Alexander Graf wrote:
> The DP83867 phy driver doesn't actually work when CONFIG_OF_MDIO isn't enabled.
> It simply passes the device tree test, but leaves all internal configuration
> initialized at 0. Then it configures the phy with those values and renders a
> previously working configuration useless.
> 
> This patch makes sure that we only build the DP83867 phy code when
> CONFIG_OF_MDIO is set, to not run into that problem.

Hi Alexander

Looking at the code, the parameters read from device tree are needed
for RGMII mode. What about the case the PHY is used not in RGMII mode?
Could it be there are device trees which legitimately don't have these
properties since they are not needed, and are now going to get
-ENODEV?

	Andrew
