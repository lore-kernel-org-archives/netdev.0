From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH] NET: bcm63xx_enet: move phy_(dis)connect into
 probe/remove
Date: Wed, 18 Apr 2012 14:48:16 +0200
Message-ID: <1334753296.5185.3.camel@sakura.staff.proxad.net>
References: <1334750537-14896-1-git-send-email-jonas.gorski@gmail.com>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jonas Gorski <jonas.gorski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:57491 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752152Ab2DRM5f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2012 08:57:35 -0400
In-Reply-To: <1334750537-14896-1-git-send-email-jonas.gorski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2012-04-18 at 14:02 +0200, Jonas Gorski wrote:

> Only connect/disconnect the phy during probe and remove, not during open
> and close. The phy seldom changes during the runtime, and disconnecting
> the phy during close will prevent the phy driver from keeping any
> configuration over a down/up cycle.
> 
> Signed-off-by: Jonas Gorski <jonas.gorski@gmail.com>

please CC me, I wrote this driver

> -		phydev = phy_connect(dev, phy_id, bcm_enet_adjust_phy_link, 0,
> -				     PHY_INTERFACE_MODE_MII);

bcm_enet_adjust_link() may modify some dma registers that are reset by
bcm_enet_open(), since it can now be called after probe, we may end up
with broken flow control depending on whatever was called first.


-- 
Maxime
