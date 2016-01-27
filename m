From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [BISECTED] v4.5-rc1 phylib regression
Date: Wed, 27 Jan 2016 01:15:02 +0100
Message-ID: <20160127001502.GA11317@lunn.ch>
References: <20160126133417.GI3880@lunn.ch>
 <CAOesGMgaB8R+7jGyLNgQ-M+2nVRhOsEp7LUbiApEEw+dscfL0w@mail.gmail.com>
 <20160126175353.GG27473@lunn.ch>
 <CAOesGMhYU4NOeGRJoF4bcELCFfSsvBVp2du7ZgVjC3QuCv637w@mail.gmail.com>
 <CAOesGMi+ymn_FdDfgTjwgyO-MsEJNGBDU9ayRJvGkjJ7T_ExfA@mail.gmail.com>
 <56A7DB27.6080203@gmail.com>
 <20160126213600.GJ27473@lunn.ch>
 <CAOesGMiEzhN9sGBTq57xnti_Fy1J4rO=djehNHwj47ZhetymXw@mail.gmail.com>
 <20160126220924.GK27473@lunn.ch>
 <56A80725.1070808@gmail.com>
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
In-Reply-To: <56A80725.1070808-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, 2016 at 03:54:13PM -0800, Florian Fainelli wrote:
> On 26/01/16 14:09, Andrew Lunn wrote:
> >>> Nope, not an option. Only a small number of DTB actually use c22 or
> >>> c45. The majority of devices have no compatible at all. Why should
> >>> they, the binding documentation says it is optional!
> >>
> >> So one thing that can be done is to just have a whitelist in the
> >> driver that we add the known phy compatibles to, with a nice comment
> >> above that this should only be for legacy device trees.
> > 
> > So you mean drivers/of/of_mdio.c:of_mdiobus_child_is_phy()
> > has a white list like:
> > 
> > "brcm,40nm-ephy"
> > "marvell,88E1111", 
> > "marvell,88e1116",
> > "marvell,88e1118",
> > "marvell,88e1149r",
> > "marvell,88e1310",
> > "marvell,88E1510",
> > "marvell,88E1514",
> > "moxa,moxart-rtl8201cp",
> > 
> > Yes, that would work.
> > 
> > We should also update the binding documentation to limit what is legal
> > in the compatible string.
> 
> Agreed, and while at it, take the opportunity to make the compatible
> string clause 22/45 mandatory properties so we do not multiply the
> whitelist.

Hi Florian

I just posted the whitelist code.

Making clause 22/45 mandatory is going further than a fix. So i've
left this out for the moment. We can add it to net-next later.

     Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
