From: Shawn Guo <shawn.guo-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Thu, 23 Jun 2011 08:12:35 +0800
Message-ID: <20110623001234.GB25799@S2100-06.ap.freescale.net>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
	<1308410354-21387-2-git-send-email-shawn.guo@linaro.org>
	<20110618161934.GH8195@ponder.secretlab.ca>
	<20110619073000.GA23171@S2100-06.ap.freescale.net>
	<20110621135558.GB9228@S2101-09.ap.freescale.net>
	<BANLkTim4vunTm1176MRw3pqRZnunu4=9jg@mail.gmail.com>
	<20110622153353.GA25799@S2100-06.ap.freescale.net>
	<BANLkTimsk2eWKPi2hnHbaAn-vSMKmdYsGQ@mail.gmail.com>
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
In-Reply-To: <BANLkTimsk2eWKPi2hnHbaAn-vSMKmdYsGQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Wed, Jun 22, 2011 at 09:52:11AM -0600, Grant Likely wrote:
[...]
> =

> >> > - =A0 =A0 =A0 line =3D of_get_property(node, "id", NULL);
> >> > - =A0 =A0 =A0 if (!line)
> >> > + =A0 =A0 =A0 line =3D of_get_device_index(node, "serial");
> >> > + =A0 =A0 =A0 if (IS_ERR_VALUE(line))
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENODEV;
> >>
> >> Personally, it an alias isn't present, then I'd dynamically assign a p=
ort id.
> >>
> > We probably can not. =A0The driver works with being told the correct
> > port id which is defined by soc. =A0Instead of dynamically assigning
> > a port id, we have to tell the driver the exact hardware port id of
> > the device that is being probed.
> =

> Are you sure?  It doesn't look like the driver behaviour uses id for
> anything other than an index into the statically allocated serial port
> instance table.  I don't see any change of behaviour based on the port
> number anywhere.
> =

Sorry, I did not make this clear.  In serial_imx_probe(), the port
gets created and then saved as below.

	imx_ports[sport->port.line] =3D sport;

While in imx_console_setup(), it addresses the port as following.

	sport =3D imx_ports[co->index];

When users specify their console as ttymxc0, they mean they are
using the first i.mx uart hardware port, in turn ttymxc1 for the
second port ...

That said, imx_port[0] has to be the first hardware port, imx_port[1]
has to be the second one ...  That's why port id sport->port.line
can not be dynamically assigned, otherwise console may not work.

-- =

Regards,
Shawn
