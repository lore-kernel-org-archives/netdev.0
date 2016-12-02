From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/6] net: dsa: mv88e6xxx: add a software reset op
Date: Fri, 2 Dec 2016 16:43:42 +0100
Message-ID: <20161202154342.GL21887@lunn.ch>
References: <20161130225930.25510-1-vivien.didelot@savoirfairelinux.com>
 <20161130225930.25510-4-vivien.didelot@savoirfairelinux.com>
 <20161130232633.GS21645@lunn.ch>
 <87vav3gz67.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87vav3gz67.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 01, 2016 at 03:41:20PM -0500, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> >> diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> >> index ab52c37..9e51405 100644
> >> --- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> >> +++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> >> @@ -765,6 +765,9 @@ struct mv88e6xxx_ops {
> >>  	int (*phy_write)(struct mv88e6xxx_chip *chip, int addr, int reg,
> >>  			 u16 val);
> >>  
> >> +	/* Switch Software Reset */
> >> +	int (*reset)(struct mv88e6xxx_chip *chip);
> >> +
> >
> > Hi Vivien
> >
> > In my huge patch series of 6390, i've been using a g1_ prefix for
> > functionality which is in global 1, g2_ for global 2, etc.  This has
> > worked for everything so far with the exception of setting which
> > reserved MAC addresses should be sent to the CPU. Most devices have it
> > in g2, but 6390 has it in g1.
> >
> > Please could you add the prefix.
> 
> I don't understand. It looks like you are talking about the second part
> of the comment I made on your RFC patchset, about the Rsvd2CPU feature:

Hi Vivien

I mean

+	/* Switch Software Reset */
+	int (*g1_reset)(struct mv88e6xxx_chip *chip);
+

We have a collection of function pointers with port_ prefix, another
collection with stats_, and a third with ppu_, etc. And then we have
some which do not fit a specific category. Those i have prefixed with
g1_ or g2_. I think we should have some prefix, and that is my
suggestion.

	Andrew
