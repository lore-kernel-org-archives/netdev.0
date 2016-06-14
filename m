From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 12/12] net: dsa: mv88e6xxx: add addressing
 mode to info
Date: Wed, 15 Jun 2016 00:44:25 +0200
Message-ID: <20160614224425.GL12832@lunn.ch>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
 <20160614183153.32327-13-vivien.didelot@savoirfairelinux.com>
 <20160614220941.GJ12832@lunn.ch>
 <871t3z1ka6.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <871t3z1ka6.fsf@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 14, 2016 at 06:24:17PM -0400, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> >> -	ret = mdiobus_read_nested(bus, addr, reg);
> >> +	ret = mdiobus_read_nested(bus, sw_addr + addr, reg);
> >>  	if (ret < 0)
> >>  		return ret;
> >
> > If we are doing direct access, doesn't it means sw_addr is 0?
> >
> > So isn't this pointless?
> 
> 6060 has no indirect access and directly responds to 16 SMI addresses,
> regardless its chip address which can be strapped to either 0 or 16.

Ah! O.K.

wnr854t-setup.c uses 0.
rd88f6183ap-ge-setup.c uses 0.
wrt350n-v2-setup.c uses 0.
rd88f5181l-fxo-setup.c uses 0.
rd88f5181l-ge-setup.c uses 0.
mach-bf518/boards/ezbrd.c uses 0.

The 6060 is a very old device. I doubt we will get any new boards
contributed using it. We are also going to have trouble actually
finding a device with one in order to test a merged mv88e6xxx and
mv88e6060 driver.

So i say we ignore the possibility of an 6060 on 16, until one really
comes along.

> Question 2) is MV88E6XXX_FLAG_MULTI_CHIP confusing?

No, i think it is fine.

    Andrew
