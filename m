From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx
 switches
Date: Fri, 27 Feb 2015 17:21:04 -0500 (EST)
Message-ID: <20150227.172104.142920096639146096.davem@davemloft.net>
References: <20150226141319.GA7971@gospo.home.greyhouse.net>
	<CAE4R7bBspZn3Mt2-KGeBBCfkxOQAmFFoOZJAnTKJBNPkS9P2Lg@mail.gmail.com>
	<20150226144433.GF1973@nanopsycho.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, gospo@cumulusnetworks.com, andrew@lunn.ch,
	zajec5@gmail.com, f.fainelli@gmail.com, netdev@vger.kernel.org,
	jogo@openwrt.org, hauke@hauke-m.de, nbd@openwrt.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753405AbbB0WVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 17:21:08 -0500
In-Reply-To: <20150226144433.GF1973@nanopsycho.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 26 Feb 2015 15:44:33 +0100

> Thu, Feb 26, 2015 at 03:19:27PM CET, sfeldma@gmail.com wrote:
>>Missing .ndo_start_xmit is the clue....do we need more?
> 
> You do not want to add null check for ndo_start_xmit to xmit path :)
> This should be some stub in case of no-tx.

Cheapest would be to force the device to use the noop_qdisc which
simply throws all packets away.

No fast path tests whatsoever.

Or we can attach an ndo_start_xmit that drops packets too.
