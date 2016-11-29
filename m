From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 2/2] net: dsa: mv88e6xxx: Add 88E6176 device tree support
Date: Tue, 29 Nov 2016 19:20:02 +0100
Message-ID: <20161129182002.GB21645@lunn.ch>
References: <1480280279-9552-2-git-send-email-afaerber@suse.de>
 <20161127212709.GD13318@lunn.ch>
 <9500470d-09c3-3ecb-994b-3d108bffc99e@suse.de>
 <20161127220846.GH13318@lunn.ch>
 <e5d45b55-a4c1-3b5e-0bdc-a5e340b072d0@suse.de>
 <20161127231009.GA17704@lunn.ch>
 <20161128080939.ippqlytvojitefkp@perseus.defre.kleine-koenig.org>
 <20161128131735.GA4379@lunn.ch>
 <2c59cc79-b6dc-9920-1725-a7785ff3b6bf@kleine-koenig.org>
 <87oa0yb29b.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <uwe-rXY34ruvC2xidJT2blvkqNi2O/JbrIOy@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andreas =?iso-8859-1?Q?F=E4rber?= <afaerber-l3A5Bk7waGM@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Michal Hrusecki <Michal.Hrusecky-x+rMaJPWets@public.gmane.org>,
        Tomas Hlavacek <tomas.hlavacek-x+rMaJPWets@public.gmane.org>,
        Bed??icha Ko??atu <bedrich.kosata-x+rMaJPWets@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87oa0yb29b.fsf-BOtmAI95c/+pXNIQCVAXCG0Lkn3mC4nZ0tOlhedn3YvkypF1WZHjJXhe7Zk3YmMvjmZSf7Nhrd8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 29, 2016 at 12:54:24PM -0500, Vivien Didelot wrote:
> Hi,
> 
> Uwe Kleine-König <uwe-rXY34ruvC2xidJT2blvkqNi2O/JbrIOy@public.gmane.org> writes:
> 
> > Also it seems wrong to write "marvell,mv88e6085" (only) if I know the
> > hardware is really a "marvell,mv88e6176".
> 
> I agree. It might be complex for a user to dig into the driver in order
> to figure out how the switch ID is read and which compatible to choose.
> 
> I've sent a patch to change this https://lkml.org/lkml/2016/6/8/1198 but
> Andrew had a stronger opinion on compatible strings, which makes sense.
> 
> >> Linus has said he does not like ARM devices because of all the busses
> >> which are not enumerable. Here we have a device which with a little
> >> bit of help we can enumerate. So we should. 
> >
> > If you write
> >
> > 	compatible = "marvell,mv88e6176", "marvell,mv88e6085";
> >
> > you can still enumerate in the same way as before.
> 
> So we don't break the existing DTS files, I like this.
> 
> The driver already prints info about the detected switch. Instead of
> failing at probe, which seems against the notion of compatible and
> breaks the existing behavior, it could report the eventual mismatch?

I'm still against it.

Say we let the driver probe and warn when the compatible string is
wrong. Is this likely to get fixed? Probably not, it is just a
warning, people ignore them.

A few years later, we have accumulated a number of broken device
trees. And suddenly we really do have a Marvell device with a broken
ID in its port register, or more likely, the revision number was not
incremented but there was incompatible register changes. We suddenly
do have to look at the compatible string. But we know many are actually
wrong. How do we know which to trust? We basically have to say, if the
compatible is "marvell,mv88e6042" we trust it, all the others we don't
trust and ignore.

Isn't that madness?

What we have today is verified correct. If this hypothetical
"marvell,mv88e6042" does happen, then no problems, we add a compatible
string for it, and it works.

We should probably add a comment to the mv88e6xxx_of_match array,
explaining how it currently works.

      Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
