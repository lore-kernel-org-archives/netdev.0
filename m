From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [BISECTED] v4.5-rc1 phylib regression
Date: Tue, 26 Jan 2016 22:36:00 +0100
Message-ID: <20160126213600.GJ27473@lunn.ch>
References: <20160125154520.GI22974@ak-desktop.emea.nsn-net.net>
 <20160126044624.GH3880@lunn.ch>
 <20160126121435.GK22974@ak-desktop.emea.nsn-net.net>
 <20160126133417.GI3880@lunn.ch>
 <CAOesGMgaB8R+7jGyLNgQ-M+2nVRhOsEp7LUbiApEEw+dscfL0w@mail.gmail.com>
 <20160126175353.GG27473@lunn.ch>
 <CAOesGMhYU4NOeGRJoF4bcELCFfSsvBVp2du7ZgVjC3QuCv637w@mail.gmail.com>
 <CAOesGMi+ymn_FdDfgTjwgyO-MsEJNGBDU9ayRJvGkjJ7T_ExfA@mail.gmail.com>
 <56A7DB27.6080203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olof Johansson <olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org>,
	Aaro Koskinen <aaro.koskinen-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <56A7DB27.6080203-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, 2016 at 12:46:31PM -0800, Florian Fainelli wrote:
> On 26/01/16 10:14, Olof Johansson wrote:
> > +devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org instead.
> > 
> > On Tue, Jan 26, 2016 at 10:08 AM, Olof Johansson <olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org> wrote:
> >> On Tue, Jan 26, 2016 at 9:53 AM, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org> wrote:
> >>>> I hate to bikeshed, but I'm not sure if "generic-mdio" is too...
> >>>> generic? Will someone writing a DT be thinking "well, this is a
> >>>> generic mdio PHY, I should set it"?  "mdio-device"?
> >>>> "generic-nonphy-mdio"? Neither of those seem much better.
> >>>
> >>> How about 'not-a-phy'?
> >>
> >> "mdio,not-a-phy" or "mdio,non-phy" will scope it a bit, especially if
> >> you expect other generic mdio properties that can do with a namespace.
> 
> Really not a fan of having to add an additional boolean property to
> differentiate an Ethernet PHY from something else, the proper solution
> would really be to enforce the use of the c22 or c45 compatible string
> as the least compatible string to be used, but I am assuming this is not
> necessarily an option here with DTBs out there.

Nope, not an option. Only a small number of DTB actually use c22 or
c45. The majority of devices have no compatible at all. Why should
they, the binding documentation says it is optional!
 
> What plays in favor of this boolean property is that the very concept of
> MDIO devices has been recently introduced, so presumably, there are not
> that many DTBs out there which would be affected...

In kernel, 0. I have one out of kernel, which i hope to contribute
once we decide on the new binding for DSA.

> The only other idea I had was to force the MDIO device creation to be
> dependent on finding a matching compatible string provided by a driver
> (yikes).

Complex. There are ordering issues, since the driver can be loaded a
long time after of_mdiobus_register() is called, yet it needs to be
of_mdiobus_register() which decides if a device is a PHY or not.

I think the bool is the only practical solution.

  Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
