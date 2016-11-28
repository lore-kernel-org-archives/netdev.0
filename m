From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 2/2] net: dsa: mv88e6xxx: Add 88E6176 device tree support
Date: Mon, 28 Nov 2016 14:17:35 +0100
Message-ID: <20161128131735.GA4379@lunn.ch>
References: <1480280279-9552-1-git-send-email-afaerber@suse.de>
 <1480280279-9552-2-git-send-email-afaerber@suse.de>
 <20161127212709.GD13318@lunn.ch>
 <9500470d-09c3-3ecb-994b-3d108bffc99e@suse.de>
 <20161127220846.GH13318@lunn.ch>
 <e5d45b55-a4c1-3b5e-0bdc-a5e340b072d0@suse.de>
 <20161127231009.GA17704@lunn.ch>
 <20161128080939.ippqlytvojitefkp@perseus.defre.kleine-koenig.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
In-Reply-To: <20161128080939.ippqlytvojitefkp-jgopVnDzZD+b0XQX99//ntPVjbGH4+40kFgPdswSElo@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> I still wonder (and didn't get an answer back when I asked about this)
> why a comment is preferred here. For other devices I know it's usual and
> requested by the maintainers to use:
> 
> 	compatible = "exact name", "earlyer device to match driver";
> 
> . This is more robust, documents the situation more formally and makes
> it better greppable. The price to pay is only a few bytes in the dtb
> which IMO is ok.

We did discuss this a while back. The information is useless and
should to be ignored if present.

The switch has a register which contains its model and revision. Each
port has a set of registers, and register 3 contains the
model/version. For all devices compatible with the 6085, the port
registers start at address 0x10. For the 6190, the port registers
start at 0x0. So given one of these two compatible strings, we can
find the model of the device, from something which is burned into the
silicon.

Now, say we did add per device compatible strings. We look up the
model burned into the silicon, find it is different to what the device
tree is and do what? Fail the probe? Or just keep going using the
value in the silicon? It seems silly to fail the probe if the driver
does support the model, but that means the device tree is never
verified and hence probably wrong. Why have wrong information in the
device tree, especially wrong information which we never use. It is
better to not have that information in the device tree.

Linus has said he does not like ARM devices because of all the busses
which are not enumerable. Here we have a device which with a little
bit of help we can enumerate. So we should. 

    Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
