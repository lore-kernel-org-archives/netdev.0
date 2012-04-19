From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH] NET: bcm63xx_enet: move phy_(dis)connect into
 probe/remove
Date: Thu, 19 Apr 2012 15:33:00 +0200
Message-ID: <1334842380.5185.29.camel@sakura.staff.proxad.net>
References: <1334750537-14896-1-git-send-email-jonas.gorski@gmail.com>
	 <1334753296.5185.3.camel@sakura.staff.proxad.net>
	 <CAOiHx=khEqKaAsD++=0BXEzutaWCgi-30B=6hYyLChfkAaHXXA@mail.gmail.com>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jonas Gorski <jonas.gorski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:32973 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754208Ab2DSNc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2012 09:32:59 -0400
In-Reply-To: <CAOiHx=khEqKaAsD++=0BXEzutaWCgi-30B=6hYyLChfkAaHXXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2012-04-18 at 21:30 +0200, Jonas Gorski wrote:
> 
> The phy state machine will start in PHY_READY after phy_connect, which
> will result in NOPs, so no call to bcm_enet_adjust_phy_link() after
> _probe() and before _open(). The state machine starts doing real work
> only after calling phy_start(), which happens only after the dma
> register accesses in open(). So no race here. 

If I read the phylib code correctly, after phy_connect() the phy is in
READY state, and you can access it via ethtool.

-- 
Maxime
