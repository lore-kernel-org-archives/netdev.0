From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: add suspend_halted module param
Date: Wed, 26 Feb 2014 21:22:22 +0100
Message-ID: <20140226202222.GD14907@lunn.ch>
References: <1393174719-20806-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <20140224191554.GC29288@lunn.ch>
 <530D1B7C.2090506@gmail.com>
 <20140226182117.GB14907@lunn.ch>
 <CAGVrzcYUfq84ryVET9qNJvyFCnhFdU4c0fOHbNN4eE8_w6qsAQ@mail.gmail.com>
 <20140226191009.GC14907@lunn.ch>
 <CAGVrzcb5k1JUPo0kvMdPJLCkWHb9qfHfDif08ud5ydKiKBwdHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGVrzcb5k1JUPo0kvMdPJLCkWHb9qfHfDif08ud5ydKiKBwdHQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The only case we need to handle is when the interface is brought down,
> suspend_halted=true will also power down the PHY, you reboot into
> u-boot, and you attempt a network boot right after that, in that case
> the PHY interface is still powered down and this does not work.

Correct. And since my device uses dhclient, the interface is always
put down on reboot when it releases the lease. 
 
> That could be worked around by putting the interface up again before
> you reboot into u-boot right, that specific logic being gated by
> reading the board model. Agreed, you need to duplicate that workaround
> in all affected user-space....

I wonder how many other systems are broken? Are we considering this a
regression? Should this feature to turned off by default, and a sysfs
knob used to enable it? That is the safe option.

     Andrew
