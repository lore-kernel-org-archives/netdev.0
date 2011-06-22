From: Shawn Guo <shawn.guo-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Wed, 22 Jun 2011 23:33:54 +0800
Message-ID: <20110622153353.GA25799@S2100-06.ap.freescale.net>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
	<1308410354-21387-2-git-send-email-shawn.guo@linaro.org>
	<20110618161934.GH8195@ponder.secretlab.ca>
	<20110619073000.GA23171@S2100-06.ap.freescale.net>
	<20110621135558.GB9228@S2101-09.ap.freescale.net>
	<BANLkTim4vunTm1176MRw3pqRZnunu4=9jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Jason Liu <jason.hui-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jeremy Kerr <jeremy.kerr-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <BANLkTim4vunTm1176MRw3pqRZnunu4=9jg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 21, 2011 at 01:13:50PM -0600, Grant Likely wrote:
> On Tue, Jun 21, 2011 at 7:55 AM, Shawn Guo <shawn.guo-KZfg59tc24xl57MIdRCFDg@public.gmane.org> wrot=
e:
> > Hi Grant,
> >
> > I just gave a try to use aliases node for identify the device index.
> > Please take a look and let me know if it's what you expect.
> =

> Thanks Shawn.  This is definitely on track.  Comments below...
> =

> >
> > On Sun, Jun 19, 2011 at 03:30:02PM +0800, Shawn Guo wrote:
> > [...]
> >> > >
> >> > > +#ifdef CONFIG_OF
> >> > > +static int serial_imx_probe_dt(struct imx_port *sport,
> >> > > + =A0 =A0 =A0 =A0 struct platform_device *pdev)
> >> > > +{
> >> > > + struct device_node *node =3D pdev->dev.of_node;
> >> > > + const __be32 *line;
> >> > > +
> >> > > + if (!node)
> >> > > + =A0 =A0 =A0 =A0 return -ENODEV;
> >> > > +
> >> > > + line =3D of_get_property(node, "id", NULL);
> >> > > + if (!line)
> >> > > + =A0 =A0 =A0 =A0 return -ENODEV;
> >> > > +
> >> > > + sport->port.line =3D be32_to_cpup(line) - 1;
> >> >
> >> > Hmmm, I really would like to be rid of this. =A0Instead, if uarts mu=
st
> >> > be enumerated, the driver should look for a /aliases/uart* property
> >> > that matches the of_node. =A0Doing it that way is already establishe=
d in
> >> > the OpenFirmware documentation, and it ensures there are no overlaps
> >> > in the global namespace.
> >> >
> >>
> >> I just gave one more try to avoid using 'aliases', and you gave a
> >> 'no' again. =A0Now, I know how hard you are on this. =A0Okay, I start
> >> thinking about your suggestion seriously :)
> >>
> >> > We do need some infrastructure to make that easier though. =A0Would =
you
> >> > have time to help put that together?
> >> >
> >> Ok, I will give it a try.
> >>
> >
> > diff --git a/arch/arm/boot/dts/imx51-babbage.dts b/arch/arm/boot/dts/im=
x51-babbage.dts
> > index da0381a..f4a5c3c 100644
> > --- a/arch/arm/boot/dts/imx51-babbage.dts
> > +++ b/arch/arm/boot/dts/imx51-babbage.dts
> > @@ -18,6 +18,12 @@
> > =A0 =A0 =A0 =A0compatible =3D "fsl,imx51-babbage", "fsl,imx51";
> > =A0 =A0 =A0 =A0interrupt-parent =3D <&tzic>;
> >
> > + =A0 =A0 =A0 aliases {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 serial0 =3D &uart0;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 serial1 =3D &uart1;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 serial2 =3D &uart2;
> > + =A0 =A0 =A0 };
> > +
> =

> Hmmm.  David Gibson had tossed out an idea of automatically generating
> aliases from labels.  It may be time to revisit that idea.
> =

> David, perhaps using this format for a label should turn it into an
> alias (prefix label with an asterisk):
> =

>         *thealias: i2c@12340000 { /*...*/ };
> =

> .... although that approach gets *really* hairy when considering that
> different boards will want different enumeration.  How would one
> override an automatic alias defined by an included .dts file?
> =

Another dependency the patch has to wait for?  Or we can go ahead and
utilize the facility later when it gets ready?

> > =A0 =A0 =A0 =A0chosen {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bootargs =3D "console=3Dttymxc0,115200 r=
oot=3D/dev/mmcblk0p3 rootwait";
> > =A0 =A0 =A0 =A0};
> > @@ -47,29 +53,29 @@
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =3D <0x70000000 0x40=
000>;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ranges;
> >
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart@7000c000 {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart2: uart@7000c000 {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compatib=
le =3D "fsl,imx51-uart", "fsl,imx21-uart";
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =3D =
<0x7000c000 0x4000>;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0interrup=
ts =3D <33>;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0id =3D <=
3>;
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fsl,has-r=
ts-cts;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fsl,uart-=
has-rtscts;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
> >
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart@73fbc000 {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart0: uart@73fbc000 {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compatible =3D "fsl,imx5=
1-uart", "fsl,imx21-uart";
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =3D <0x73fbc000 0x40=
00>;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0interrupts =3D <31>;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0id =3D <1>;
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fsl,has-rts-cts;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fsl,uart-has-rtscts;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
> >
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart@73fc0000 {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart1: uart@73fc0000 {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compatible =3D "fsl,imx5=
1-uart", "fsl,imx21-uart";
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =3D <0x73fc0000 0x40=
00>;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0interrupts =3D <32>;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0id =3D <2>;
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fsl,has-rts-cts;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fsl,uart-has-rtscts;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
> > =A0 =A0 =A0 =A0};
> >
> > diff --git a/drivers/of/base.c b/drivers/of/base.c
> > index 632ebae..13df5d2 100644
> > --- a/drivers/of/base.c
> > +++ b/drivers/of/base.c
> > @@ -737,6 +737,37 @@ err0:
> > =A0EXPORT_SYMBOL(of_parse_phandles_with_args);
> >
> > =A0/**
> > + * =A0 =A0 of_get_device_index - Get device index by looking up "alias=
es" node
> > + * =A0 =A0 @np: =A0 =A0Pointer to device node that asks for device ind=
ex
> > + * =A0 =A0 @name: =A0The device alias without index number
> > + *
> > + * =A0 =A0 Returns the device index if find it, else returns -ENODEV.
> > + */
> > +int of_get_device_index(struct device_node *np, const char *alias)
> > +{
> > + =A0 =A0 =A0 struct device_node *aliases =3D of_find_node_by_name(NULL=
, "aliases");
> > + =A0 =A0 =A0 struct property *prop;
> > + =A0 =A0 =A0 char name[32];
> > + =A0 =A0 =A0 int index =3D 0;
> > +
> > + =A0 =A0 =A0 if (!aliases)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> > +
> > + =A0 =A0 =A0 while (1) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 snprintf(name, sizeof(name), "%s%d", alia=
s, index);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 prop =3D of_find_property(aliases, name, =
NULL);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!prop)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (np =3D=3D of_find_node_by_path(prop->=
value))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 index++;
> > + =A0 =A0 =A0 }
> =

> Rather than parsing the alias strings everytime, it would probably be
> better to preprocess all the properties in the aliases node and create
> a lookup table of alias->node references that can be walked quickly
> and trivially.
> =

Ok, I'm thinking about it.  Will probably ask something on details
later.

> Also, when obtaining an enumeration for a device, you'll need to be
> careful about what number gets returned.  If the node doesn't match a
> given alias, but aliases do exist for other devices of like type, then
> you need to be careful not to assign a number already assigned to
> another device via an alias (this of course assumes the driver
> supports dynamics enumeration, which many drivers will).  It would be
> =

Some words not finished?

> \> +
> > + =A0 =A0 =A0 return index;
> > +}
> > +EXPORT_SYMBOL(of_get_device_index);
> > +
> > +/**
> > =A0* prom_add_property - Add a property to a node
> > =A0*/
> > =A0int prom_add_property(struct device_node *np, struct property *prop)
> > diff --git a/drivers/tty/serial/imx.c b/drivers/tty/serial/imx.c
> > index da436e0..852668f 100644
> > --- a/drivers/tty/serial/imx.c
> > +++ b/drivers/tty/serial/imx.c
> > @@ -1271,18 +1271,18 @@ static int serial_imx_probe_dt(struct imx_port =
*sport,
> > =A0 =A0 =A0 =A0struct device_node *node =3D pdev->dev.of_node;
> > =A0 =A0 =A0 =A0const struct of_device_id *of_id =3D
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0of_match_device(imx_uart=
_dt_ids, &pdev->dev);
> > - =A0 =A0 =A0 const __be32 *line;
> > + =A0 =A0 =A0 int line;
> >
> > =A0 =A0 =A0 =A0if (!node)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENODEV;
> >
> > - =A0 =A0 =A0 line =3D of_get_property(node, "id", NULL);
> > - =A0 =A0 =A0 if (!line)
> > + =A0 =A0 =A0 line =3D of_get_device_index(node, "serial");
> > + =A0 =A0 =A0 if (IS_ERR_VALUE(line))
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENODEV;
> =

> Personally, it an alias isn't present, then I'd dynamically assign a port=
 id.
> =

We probably can not.  The driver works with being told the correct
port id which is defined by soc.  Instead of dynamically assigning
a port id, we have to tell the driver the exact hardware port id of
the device that is being probed.

-- =

Regards,
Shawn
