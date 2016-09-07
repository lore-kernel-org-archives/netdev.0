From: "Y.B. Lu" <yangbo.lu@nxp.com>
Subject: RE: [v11, 7/8] base: soc: introduce soc_device_match() interface
Date: Wed, 7 Sep 2016 04:10:32 +0000
Message-ID: <HE1PR04MB088939A28A68035F3393A441F8F80@HE1PR04MB0889.eurprd04.prod.outlook.com>
References: <1473150503-9550-1-git-send-email-yangbo.lu@nxp.com>
 <1473150503-9550-8-git-send-email-yangbo.lu@nxp.com>
 <CAPDyKFrvg3Qr5m3xXvywsCoVvaiF7ggHAj0Aw=WCOXg65Pt0PQ@mail.gmail.com>
 <6515108.aCEls7dUuW@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: linux-mmc <linux-mmc@vger.kernel.org>,
        Scott Wood <oss@buserror.net>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-clk <linux-clk@vger.kernel.org>,
        "linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
        "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Rob Herring <robh+dt@kernel.org>,
        Russell King <linux@arm.linux.org.uk>,
        Jochen Friedrich <jochen@scram.de>,
        Joerg Roedel <joro@8bytes.org>,
        Claudiu Manoil <claudiu.manoil@free
To: Arnd Bergmann <arnd@arndb.de>, Ulf Hansson <ulf.hansson@linaro.org>
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <6515108.aCEls7dUuW@wuerfel>
Content-Language: en-US
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Anrd and Uffe,

Thank you for your comment.
Please see my comment inline.



Best regards,
Yangbo Lu

> -----Original Message-----
> From: Arnd Bergmann [mailto:arnd@arndb.de]
> Sent: Tuesday, September 06, 2016 8:46 PM
> To: Ulf Hansson
> Cc: Y.B. Lu; linux-mmc; Scott Wood; linuxppc-dev@lists.ozlabs.org;
> devicetree@vger.kernel.org; linux-arm-kernel@lists.infradead.org; linux-
> kernel@vger.kernel.org; linux-clk; linux-i2c@vger.kernel.org;
> iommu@lists.linux-foundation.org; netdev@vger.kernel.org; Mark Rutland;
> Rob Herring; Russell King; Jochen Friedrich; Joerg Roedel; Claudiu Manoil=
;
> Bhupesh Sharma; Qiang Zhao; Kumar Gala; Santosh Shilimkar; Leo Li; X.B.
> Xie
> Subject: Re: [v11, 7/8] base: soc: introduce soc_device_match() interface
>=20
> On Tuesday, September 6, 2016 1:44:23 PM CEST Ulf Hansson wrote:
> > On 6 September 2016 at 10:28, Yangbo Lu <yangbo.lu@nxp.com> wrote:
> > > We keep running into cases where device drivers want to know the
> > > exact version of the a SoC they are currently running on. In the
> > > past, this has usually been done through a vendor specific API that
> > > can be called by a driver, or by directly accessing some kind of
> > > version register that is not part of the device itself but that
> > > belongs to a global register area of the chip.
>=20
> Please add "From: Arnd Bergmann <arnd@arndb.de>" as the first line, to
> preserve authorship. If you use "git send-email" or "git format-patch",
> that should happen automatically if the author field is set right (if not=
,
> use 'git commit --amend --author=3D"Arnd Bergmann <arnd@arndb.de>"'
> to fix it).
>=20

[Lu Yangbo-B47093] Oh, I'm sorry for my careless. Will correct it in next v=
ersion.

> > > +
> > > +/*
> > > + * soc_device_match - identify the SoC in the machine
> > > + * @matches: zero-terminated array of possible matches
> >
> > Perhaps also express the constraint on the matching entries. As you
> > need at least one of the ->machine(), ->family(), ->revision() or
> > ->soc_id() callbacks implemented, right!?
>=20
> They are not callbacks, just strings. Having an empty entry indicates the
> end of the array, and this is not called.
>=20
> > > + *
> > > + * returns the first matching entry of the argument array, or NULL
> > > + * if none of them match.
> > > + *
> > > + * This function is meant as a helper in place of of_match_node()
> > > + * in cases where either no device tree is available or the
> > > + information
> > > + * in a device node is insufficient to identify a particular
> > > + variant
> > > + * by its compatible strings or other properties. For new devices,
> > > + * the DT binding should always provide unique compatible strings
> > > + * that allow the use of of_match_node() instead.
> > > + *
> > > + * The calling function can use the .data entry of the
> > > + * soc_device_attribute to pass a structure or function pointer for
> > > + * each entry.
> >
> > I don't get the use case behind this, could you elaborate?
> >
> > Perhaps we should postpone adding the .data entry until we actually
> > see a need for it?
>=20
> I think the interface is rather useless without a way to figure out which
> entry you got. Almost all users of of_match_node() actually use the
> returned ->data field, and I expect this to be the same here.
>=20
> > > + */
> > > +const struct soc_device_attribute *soc_device_match(
> > > +       const struct soc_device_attribute *matches) {
> > > +       struct device *dev;
> > > +       int ret;
> > > +
> > > +       for (ret =3D 0; ret =3D=3D 0; matches++) {
> >
> > This loop looks a bit weird and unsafe.
>=20
> Ah, and I thought I was being clever ;-)
>=20
> > 1) Perhaps using a while loop makes this more readable?
> > 2) As this is an exported API, I guess validation of the ->matches
> > pointer needs to be done before accessing it.
>=20
> Sounds fine.

[Lu Yangbo-B47093] Ok, Will change this according to Uffe.=20
And actually there is issue with this for() when I verified it again this m=
orning.
We will get matches++ rather than matches which is correct finally :)

>=20
> > > +               if (!(matches->machine || matches->family ||
> > > +                     matches->revision || matches->soc_id))
> > > +                       return NULL;
> > > +               dev =3D NULL;
> >
> > There's no need to use a struct device just to assign it to NULL.
> > Instead just provide the function below with NULL.
> >
> > > +               ret =3D bus_for_each_dev(&soc_bus_type, dev, (void
> *)matches,
> > > +                                      soc_device_match_one);
>=20
>=20
> I don't remember what led to this, I think you are right, we should just
> pass NULL as most other callers.

[Lu Yangbo-B47093] Will correct it. Thanks. :)

>=20
> Thanks for the review.
>=20
> 	ARnd

