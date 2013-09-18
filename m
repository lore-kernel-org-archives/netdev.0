From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [RFC PATCHv2 3/4] of: provide a binding for fixed link PHYs
Date: Wed, 18 Sep 2013 10:00:31 -0500
Message-ID: <20130918150031.D9034C42CDF@trevor.secretlab.ca>
References: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com> <1378480701-12908-4-git-send-email-thomas.petazzoni@free-electrons.com> <20130918042923.5D845C42CF7@trevor.secretlab.ca> <CAGVrzcbVTenhVC4tQznJFqVpO08ruxLyy1ZiLmw6Bu1=3zbGZg@mail.gmail.com>
Cc: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Lior Amsalem <alior-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Christian Gmeiner <christian.gmeiner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ezequiel Garcia <ezequiel.garcia-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGVrzcbVTenhVC4tQznJFqVpO08ruxLyy1ZiLmw6Bu1=3zbGZg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Sep 2013 10:21:11 +0100, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Hello,
> 
> 2013/9/18 Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>:
> > On Fri,  6 Sep 2013 17:18:20 +0200, Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org> wrote:
> >> Some Ethernet MACs have a "fixed link", and are not connected to a
> >> normal MDIO-managed PHY device. For those situations, a Device Tree
> >> binding allows to describe a "fixed link" using a special PHY node.
> >>
> >> This patch adds:
> >>
> >>  * A documentation for the fixed PHY Device Tree binding.
> >>
> >>  * An of_phy_is_fixed_link() function that an Ethernet driver can call
> >>    on its PHY phandle to find out whether it's a fixed link PHY or
> >>    not. It should typically be used to know if
> >>    of_phy_register_fixed_link() should be called.
> >>
> >>  * An of_phy_register_fixed_link() function that instantiates the
> >>    fixed PHY into the PHY subsystem, so that when the driver calls
> >>    of_phy_connect(), the PHY device associated to the OF node will be
> >>    found.
> >>
> >> Signed-off-by: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> >
> > Hi Thomas,
> >
> > The implemenation in this series looks like it is in good shape, so I'll
> > restrict my comments to be binding...
> >
> >> ---
> >>  .../devicetree/bindings/net/fixed-link.txt         | 34 ++++++++++++++++++++++
> >>  drivers/of/of_mdio.c                               | 24 +++++++++++++++
> >>  include/linux/of_mdio.h                            | 15 ++++++++++
> >>  3 files changed, 73 insertions(+)
> >>  create mode 100644 Documentation/devicetree/bindings/net/fixed-link.txt
> >>
> >> diff --git a/Documentation/devicetree/bindings/net/fixed-link.txt b/Documentation/devicetree/bindings/net/fixed-link.txt
> >> new file mode 100644
> >> index 0000000..9f2a1a50
> >> --- /dev/null
> >> +++ b/Documentation/devicetree/bindings/net/fixed-link.txt
> >> @@ -0,0 +1,34 @@
> >> +Fixed link Device Tree binding
> >> +------------------------------
> >> +
> >> +Some Ethernet MACs have a "fixed link", and are not connected to a
> >> +normal MDIO-managed PHY device. For those situations, a Device Tree
> >> +binding allows to describe a "fixed link".
> >> +
> >> +Such a fixed link situation is described by creating a PHY node as a
> >> +sub-node of an Ethernet device, with the following properties:
> >> +
> >> +* 'fixed-link' (boolean, mandatory), to indicate that this PHY is a
> >> +  fixed link PHY.
> >> +* 'speed' (integer, mandatory), to indicate the link speed. Accepted
> >> +  values are 10, 100 and 1000
> >> +* 'full-duplex' (boolean, optional), to indicate that full duplex is
> >> +  used. When absent, half duplex is assumed.
> >> +* 'pause' (boolean, optional), to indicate that pause should be
> >> +  enabled.
> >> +* 'asym-pause' (boolean, optional), to indicate that asym_pause should
> >> +  be enabled.
> >
> > I understand what you're trying to do here, but it causes a troublesome
> > leakage of implementation detail into the binding, making the whole
> > thing look very odd. This binding tries to make a fixed link look
> > exactly like a real PHY even to the point of including a phandle to the
> > phy. But having a phandle to a node which is *always* a direct child of
> > the MAC node is redundant and a rather looney. Yes, doing it that way
> > makes it easy for of_phy_find_device() to be transparent for fixed link,
> > but that should *not* drive bindings, especially when that makes the
> > binding really rather weird.
> 
> This is not exactly true in the sense that the "new" binding just
> re-shuffles the properties representation into something that is
> clearer and more extendible but there is not much difference in the
> semantics.

That's not my point in the above paragraph. My point is a binding that
consists of a phandle to a node that is always a direct child is goofy
and wrong.

> > Second, this new binding doesn't provide anything over and above the
> > existing fixed-link binding. It may not be pretty, but it is
> > estabilshed.
> 
> In fact it does, the old one is obscure and not easily extendable
> because we rely on an integer array to represent the various
> properties, so at least this new one makes it easy to extend the
> binding to support a possibly new fixed-link property. Being able to
> deprecate a fundamentaly badly designed binding should still be a
> prerogative, software is flexible and can deal with both with little
> cost.

I understand that, but consistency is also important. I don't see a
proposal for a new feature for the binding in this patch. Without a
really compelling reason to change a binding that works (even if it is
opaque) I cannot agree to changing it.

> > That said, I do agree that the current Linux implementation is not good
> > because it cannot handle a fixed-link property transparently. That's a
> > deficiency in the Linux implementation and it should be fixed.
> > of_phy_connect() currently requires the phy phandle to be passed in.
> > Part of the reason it was done this way is that some drivers connect to
> > multiple 'phys'. A soulition could be to make the phy handle optional.
> > If it is empty then go looking for either a phy-device or fixed-link
> > property. Otherwise use the provided node.
> 
> I do not quite follow you on this one, and I fear we might be leaking
> some Linux probing heuristic into Device Tree bindings by implicitely
> saying "not including a PHY phandle means connecting to a fixed-PHY
> link." This would also dramatically change the current behavior for
> most drivers where they might refuse probing if no corresponding PHY
> device node is present and they are not designed to connect to a fixed
> PHY one.

Drivers we can change and fix. There aren't very may call sites
affected so I'm not overly worried about it. Also, I was making a
suggestion on how to fix it, but a suggestion is not a fully formed
patch. The issue you raise would of course need to be addressed.

g.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
