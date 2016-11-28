From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 2/2] net: dsa: mv88e6xxx: Add 88E6176 device tree support
Date: Mon, 28 Nov 2016 17:14:15 +0100
Message-ID: <20161128161415.GI17704@lunn.ch>
References: <1480280279-9552-1-git-send-email-afaerber@suse.de>
 <1480280279-9552-2-git-send-email-afaerber@suse.de>
 <20161127212709.GD13318@lunn.ch>
 <9500470d-09c3-3ecb-994b-3d108bffc99e@suse.de>
 <20161127220846.GH13318@lunn.ch>
 <e5d45b55-a4c1-3b5e-0bdc-a5e340b072d0@suse.de>
 <20161127231009.GA17704@lunn.ch>
 <20161128080939.ippqlytvojitefkp@perseus.defre.kleine-koenig.org>
 <20161128131735.GA4379@lunn.ch>
 <2c59cc79-b6dc-9920-1725-a7785ff3b6bf@kleine-koenig.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andreas =?iso-8859-1?Q?F=E4rber?= <afaerber-l3A5Bk7waGM@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Michal Hrusecki <Michal.Hrusecky-x+rMaJPWets@public.gmane.org>,
        Tomas Hlavacek <tomas.hlavacek-x+rMaJPWets@public.gmane.org>,
        Bed??icha Ko??atu <bedrich.kosata-x+rMaJPWets@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <uwe-rXY34ruvC2xidJT2blvkqNi2O/JbrIOy@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2c59cc79-b6dc-9920-1725-a7785ff3b6bf-rXY34ruvC2xidJT2blvkqNi2O/JbrIOy@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2016 at 04:44:47PM +0100, Uwe Kleine-König wrote:
> On 11/28/2016 02:17 PM, Andrew Lunn wrote:
> >> I still wonder (and didn't get an answer back when I asked about this)
> >> why a comment is preferred here. For other devices I know it's usual and
> >> requested by the maintainers to use:
> >>
> >> 	compatible = "exact name", "earlyer device to match driver";
> >>
> >> . This is more robust, documents the situation more formally and makes
> >> it better greppable. The price to pay is only a few bytes in the dtb
> >> which IMO is ok.
> > 
> > We did discuss this a while back. The information is useless and
> > should to be ignored if present.
> 
> Who is "we"?

Anybody on netdev a while back, but mostly Vivien and myself.

> I'd say fail to probe is the right thing to do. Of course that doesn't
> work for already supported models because it will break compatibility.

And that is the first rule of device tree, never break backwards
compatibility.

> Also it seems wrong to write "marvell,mv88e6085" (only) if I know the
> hardware is really a "marvell,mv88e6176".

Why? Remember, the property name is called "compatible", not "is".

> > Linus has said he does not like ARM devices because of all the busses
> > which are not enumerable. Here we have a device which with a little
> > bit of help we can enumerate. So we should. 
> 
> If you write
> 
> 	compatible = "marvell,mv88e6176", "marvell,mv88e6085";
> 
> you can still enumerate in the same way as before.

Sure it would. But if the driver decides to ignore it, it is likely to
be wrong. Developers are used to comments being wrong. We are
suspicious of comments, we don't trust them 100%. But if somebody sees
a property in a device tree, they put a higher 'trustability' value on
it. But it actually has less trustable than a comment.
 
> There are several more instances where the device tree specifies
> something that could be probed instead. Some examples:
> 
> 	compatible = "ethernet-phy-id0141.0DD1", "ethernet-phy-ieee802.3-c22";

There are examples of phys which don't implemented register 2 and
3. In that case, you do need to specify the ID, if you want the
correct driver to load.

> 	compatible = "spansion,s25fl164k", "jedec,spi-nor";

And there was a push recently to add "jedec,spi-nor" everywhere and
deprecate a specific compatible because it is also not needed.

> 	compatible = "fsl,imx25-flexcan", "fsl,p1010-flexcan";
> 	compatible = "arm,pl011", "arm,primecell";

I don't know these hardwares, so cannot comment.

  Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
