From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: [RFC] Patch to Abstract Ethernet PHY support (using driver model)
Date: Thu, 13 Jan 2005 13:21:52 -0800
Message-ID: <20050113212152.GA16041@gate.ebshome.net>
References: <FC6D9B81-5514-11D9-8D51-000393C30512@freescale.com> <A3A281FF-5525-11D9-80ED-000393C30512@freescale.com> <20050106070245.GA6539@gate.ebshome.net> <61A37C72-659C-11D9-8D70-000393C30512@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kumar Gala <kumar.gala@freescale.com>, Netdev <netdev@oss.sgi.com>,
        Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
Content-Disposition: inline
In-Reply-To: <61A37C72-659C-11D9-8D70-000393C30512@freescale.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 13, 2005 at 01:50:31PM -0600, Andy Fleming wrote:
> >I suspect that _all_ XXX_read_status functions for different PHYs in
> >your patch can be easily handled by generic IEEE 802.3 compliant code
> >(you need to update genphy_read_status to properly handle GigE of
> >course).
>
> Ok, I understand this, but a part of me rebels.  The "standard"
> procedure is to read the Link Partner Advertisement, AND it with the
> Advertisement, and then find the highest setting that works.  It seems
> to me that this is replicating work that is already done by the PHY,
> and I hate to do work that's already been done.

Well, some PHYs have a non-standard way to get this info, some PHYs
don't. I don't understand why do you want to bloat kernel with
knowledge of this PHY-specific registers when there is a standard way
to get this info? In fact I use IBM EMAC with a lot of different PHYs
and never needed this special code, except only PHY initialization
maybe.

> I also have one worry about this technique (though I'm still reading
> the 802.3 spec to see if my worry is valid).  Is it possible that the
> PHY would choose a setting which is lower than the highest possible,
> and therefore render the method above inaccurate?

It's a standard, period. If there is a PHY which isn't compliant I
guess it will not work anyway, but in this case, yes, we can use
PHY-specific link detection, but only in this case. I suspect you'll
have a hard time finding such PHY :)

> Yeah, that's not a problem.  I just wasn't sure if the bits were
> properly defined on non-gigabit PHYs.  I will change this, as long as
> the relevant bits are always correct on 10/100 PHYs

I use ES bit in MII_BMSR register to detect availability of MII_ESR
register. So far it worked OK with number of 10/100 PHYs.

> >4) Pause negotiation/advertising is completely missing.
>
> Sigh... I knew someone would ask for that.  I will get right on this.

This is not that difficult, I have example code in NAPI IBM EMAC
driver (http://kernel.ebshome.net).

--
Eugene
