From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/3] net-next: mediatek: add RX delay support
Date: Thu, 5 May 2016 14:13:53 +0200
Message-ID: <20160505121353.GE7972@lunn.ch>
References: <1462439856-51788-1-git-send-email-john@phrozen.org>
 <1462439856-51788-4-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, nbd@nbd.name,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57542 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750951AbcEEMOC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 08:14:02 -0400
Content-Disposition: inline
In-Reply-To: <1462439856-51788-4-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2016 at 11:17:36AM +0200, John Crispin wrote:
> If an external Gigabit PHY is connected to either of the MACs we need to
> tell the to use a RX delay. Not doing so will result in heavy packet loss
> and/or data corruption of RX traffic.

Hi John

Is this comment correct? Reading the code, all this switch statement
does is select between RGMII, MII and RMII. It has nothing to do with
delay. I suspect the PHY is doing the delay, not the MAC, since you
pass the phy mode to of_phy_connect().

If my interpretation of the code is correct, you might also want to
handle PHY_INTERFACE_MODE_RGMII_TXID and PHY_INTERFACE_MODE_RGMII_ID
which are also RGMII modes.

      Andrew
