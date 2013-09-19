From: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [RFC PATCHv2 3/4] of: provide a binding for fixed link PHYs
Date: Thu, 19 Sep 2013 08:36:52 +0200
Message-ID: <20130919063652.GQ30088@pengutronix.de>
References: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1378480701-12908-4-git-send-email-thomas.petazzoni@free-electrons.com>
 <20130918042923.5D845C42CF7@trevor.secretlab.ca>
 <CAGVrzcbVTenhVC4tQznJFqVpO08ruxLyy1ZiLmw6Bu1=3zbGZg@mail.gmail.com>
 <20130918150031.D9034C42CDF@trevor.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Lior Amsalem <alior-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Christian Gmeiner <christian.gmeiner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ezequiel Garcia <ezequiel.garcia-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130918150031.D9034C42CDF-WNowdnHR2B42iJbIjFUEsiwD8/FfD2ys@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 18, 2013 at 10:00:31AM -0500, Grant Likely wrote:
> On Wed, 18 Sep 2013 10:21:11 +0100, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > >
> > > I understand what you're trying to do here, but it causes a troublesome
> > > leakage of implementation detail into the binding, making the whole
> > > thing look very odd. This binding tries to make a fixed link look
> > > exactly like a real PHY even to the point of including a phandle to the
> > > phy. But having a phandle to a node which is *always* a direct child of
> > > the MAC node is redundant and a rather looney. Yes, doing it that way
> > > makes it easy for of_phy_find_device() to be transparent for fixed link,
> > > but that should *not* drive bindings, especially when that makes the
> > > binding really rather weird.
> > 
> > This is not exactly true in the sense that the "new" binding just
> > re-shuffles the properties representation into something that is
> > clearer and more extendible but there is not much difference in the
> > semantics.
> 
> That's not my point in the above paragraph. My point is a binding that
> consists of a phandle to a node that is always a direct child is goofy
> and wrong.

It's not necessarily a direct child. Most of these fixed links are really
ethernet switches. These are (mostly) i2c devices which are under their
corresponding i2c bus node. Using a phandle from the ethernet MAC to
the port of a switch not only provides the link information, but also the
information to which port of the switch the MAC is connected.

Another situation is that some SoCs have a MDIO bus external to the MAC
and possibly shared for multiple ethernet MACs. This also requires a
phandle from the MAC to the MDIO bus.

So we have the situation that we need a phandle from the MAC to something
that provides a link. For consistency it would be good to always use a
phandle instead of having an inflexible 'fixed-link' property.

You're right, the binding doesn't provide anything new, but I think it
straightens things up for the future.

Sascha


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
