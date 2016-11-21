From: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Subject: Re: [RFC PATCH net v2 2/3] dt: bindings: add ethernet phy
 eee-disable-advert option documentation
Date: Mon, 21 Nov 2016 17:16:33 +0100
Message-ID: <1479744993.17538.85.camel@baylibre.com>
References: <1479742524-30222-1-git-send-email-jbrunet@baylibre.com>
         <1479742524-30222-3-git-send-email-jbrunet@baylibre.com>
         <20161121160149.GF1922@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Kevin Hilman <khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andre Roth <neolynx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Carlo Caione <carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161121160149.GF1922-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-11-21 at 17:01 +0100, Andrew Lunn wrote:
> On Mon, Nov 21, 2016 at 04:35:23PM +0100, Jerome Brunet wrote:
> > 
> > Signed-off-by: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
> > ---
> >  Documentation/devicetree/bindings/net/phy.txt | 5 +++++
> >  1 file changed, 5 insertions(+)
> > 
> > diff --git a/Documentation/devicetree/bindings/net/phy.txt
> > b/Documentation/devicetree/bindings/net/phy.txt
> > index bc1c3c8bf8fa..7f066b7c1e2c 100644
> > --- a/Documentation/devicetree/bindings/net/phy.txt
> > +++ b/Documentation/devicetree/bindings/net/phy.txt
> > @@ -35,6 +35,11 @@ Optional Properties:
> >  - broken-turn-around: If set, indicates the PHY device does not
> > correctly
> >    release the turn around line low at the end of a MDIO
> > transaction.
> >  
> > +- eee-advert-disable: Bits to clear in the MDIO_AN_EEE_ADV
> > register to
> > +  disable EEE modes. Example
> > +    * 0x4: disable EEE for 1000T,
> > +    * 0x6: disable EEE for 100TX and 1000T
> > +
> 
> Hi Jerome
> 
> I like the direction this patchset is taking. But hex values are
> pretty unfriendly. 

Agreed

> Please add a set of boolean properties, and do the
> mapping to hex in the C code.
> 
> That would also make extending this API easier. e.g. say you have a
> 10Gbps PHY with EEE, and you need to disable it. This hex value
> quickly gets ugly, eee-advert-disable-10000 is nice and simple.

What I did not realize when doing this patch for the realtek driver is
that there is already 6 valid modes defined in the kernel

#define MDIO_EEE_100TX		MDIO_AN_EEE_ADV_100TX	/*
100TX EEE cap */
#define MDIO_EEE_1000T		MDIO_AN_EEE_ADV_1000T	/*
1000T EEE cap */
#define MDIO_EEE_10GT		0x0008	/* 10GT EEE cap */
#define MDIO_EEE_1000KX		0x0010	/* 1000KX EEE cap
*/
#define MDIO_EEE_10GKX4		0x0020	/* 10G KX4 EEE cap
*/
#define MDIO_EEE_10GKR		0x0040	/* 10G KR EEE cap
*/

I took care of only 2 in the case of realtek.c since it only support
MDIO_EEE_100TX and MDIO_EEE_1000T.

Defining a property for each is certainly doable but it does not look
very nice either. If it extends in the future, it will get even more
messier, especially if you want to disable everything.

What do you think about keeping a single mask value but use the define
above in the DT ? It would be more readable than hex and easy to
extend, don't you think ?

These defines are already part of the uapi so I guess we can use those
in the DT bindings ?

> 
> 	Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
