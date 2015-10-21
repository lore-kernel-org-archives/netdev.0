From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: mv88e6060: Fix false positive lockdep splat
Date: Wed, 21 Oct 2015 18:14:16 +0200
Message-ID: <20151021161416.GG17207@lunn.ch>
References: <5627B149.6030109@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45037 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755168AbbJUQOa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 12:14:30 -0400
Content-Disposition: inline
In-Reply-To: <5627B149.6030109@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2015 at 05:37:45PM +0200, Neil Armstrong wrote:
> Like the change made for mv88e6xxx, use mutex_lock_nested() to avoid
> lockdep to give false positives because of nested MDIO busses.

Hi Neil

We now have three instances of this, since mdio-mux.c has the same
code. Maybe now would be a good time to refactor this code into
mdiobus_read_nested() and mdiobus_write_nested() in mdio_bus.c?  At
the same time, add BUG_ON(in_interrupt()) similar to the non-nested
versions?

	Andrew
