From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: bcm_sf2: do not use indirect reads and
 writes for 7445E0
Date: Mon, 20 Jul 2015 16:49:03 -0700 (PDT)
Message-ID: <20150720.164903.725476389726819459.davem@davemloft.net>
References: <1437001772-17511-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52588 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbbGTXtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 19:49:04 -0400
In-Reply-To: <1437001772-17511-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 15 Jul 2015 16:09:32 -0700

> 7445E0 contains an ECO which disconnected the internal SF2 pseudo-PHY which was
> known to conflict with the external pseudo-PHY of BCM53125 switches. This
> motivated the need to utilize the internal SF2 MDIO controller via indirect
> register reads/writes to control external Broadcom switches due to this address
> conflict (both responded at address 30d).
> 
> For 7445E0, the internal pseudo-PHY of the SF2 switch got disconnected, and as
> a consequence this prevents the internal SF2 MDIO bus controller from reading
> data (reads back everything as 0) since the MDI line is tied low.
> 
> Fix this by making the indirect register reads and writes conditional to
> 7445D0, on 7445E0 we can utilize the SWITCH_MDIO controller (backed by
> mdio-unimac and not the DSA created slave MII bus).
> 
> We utilize of_machine_is_compatible() here since this is the only way for use
> to differentiate between these two chips in a way that does not violate layers
> or becomes (too) vendor-specific.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
