From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH] net: dsa: mv88e6060: Fix false positive lockdep splat
Date: Thu, 22 Oct 2015 10:08:01 +0200
Message-ID: <56289961.5090603@baylibre.com>
References: <5627B149.6030109@baylibre.com> <20151021161416.GG17207@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151021161416.GG17207@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2015 06:14 PM, Andrew Lunn wrote:
> On Wed, Oct 21, 2015 at 05:37:45PM +0200, Neil Armstrong wrote:
>> Like the change made for mv88e6xxx, use mutex_lock_nested() to avoid
>> lockdep to give false positives because of nested MDIO busses.
> 
> Hi Neil
> 
> We now have three instances of this, since mdio-mux.c has the same
> code. Maybe now would be a good time to refactor this code into
> mdiobus_read_nested() and mdiobus_write_nested() in mdio_bus.c?  At
> the same time, add BUG_ON(in_interrupt()) similar to the non-nested
> versions?
> 
> 	Andrew
> 
Well, mdio-mux also calls switch_fn inside the mdio_lock, clean refactoring
would introduce a separate lock and call the nested variants.
Is that ok ? Can someone test mdio-mux is I make the change ?


Neil
