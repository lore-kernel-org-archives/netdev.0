From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] e1000e: workaround missing power down mii control bit
 on 82571
Date: Thu, 16 Dec 2010 18:56:37 +0000
Message-ID: <1292525797.3253.8.camel@bwh-desktop>
References: <20101216182847.GA14985@ajones-laptop.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org
To: Arthur Jones <ajones@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:17412 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754887Ab0LPS4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 13:56:41 -0500
In-Reply-To: <20101216182847.GA14985@ajones-laptop.nbttech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-12-16 at 10:28 -0800, Arthur Jones wrote:
> Hi Jeff,  Re-sending w/ proper netdev email
> address.  Sorry about that...
> 
> Arthur
> 
> ---
> 
> On 82571 only, AFAICT, the PHY does not seem to
> store the MII control register 0 bit 11 (power
> down PHY). So that when we power down the PHY
> on dev_close() and then run ethtool on the closed
> dev, we end up turning the PHY back on even though
> the interface is down.  This pretty easy to repro:
> 
> $ ethtool -s eth0 wol d
> $ ifconfig eth0 up
> $ mii-tool eth0
> eth0: negotiated 100baseTx-FD, link ok
> $ ifconfig eth0 down
> $ mii-tool eth0
> eth0: no link
> $ ethtool -s eth0 autoneg on  (doesn't really matter what we do here)
> $ mii-tool eth0
> eth0: negotiated 100baseTx-FD, link ok (this should be: eth0: no link)
> 
> We fix this by tracking the power down bit that we
> write to the PHY control register and re-inserting
> it when we read it.
[...]

Adding this special case into MDIO access seems like a really nasty
hack.  Surely the callers that set the control register should take care
of this.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

