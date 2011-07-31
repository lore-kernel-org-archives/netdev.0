From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 03/71] amd: Move AMD (Lance) chipset drivers
Date: Sun, 31 Jul 2011 01:30:29 -0700
Message-ID: <1312101030.20837.100.camel@jtkirshe-mobl>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1312082850-24914-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAMuHMdXYoKkZrczdB6qPC1pfAGoTqgOiK2joY-38dewrVm5cRQ@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-ugZKF62n2uN97ujXQGAL"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Peter Maydell <pmaydell@chiark.greenend.org.uk>,
	Roman Hodek <Roman.Hodek@informatik.uni-erlangen.de>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Donald Becker <becker@scyld.com>,
	Sam Creasey <sammy@users.qual.net>,
	Miguel de Icaza <miguel@nuclecu.unam.mx>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	Don Fry <pcnet32@frontier.com>,
	Russell King <linux@arm.linux.org.uk>,
	David Davies <davies@maniac.ultranet.com>,
	"M.Hipp" <hippm@informatik.uni-tuebingen.de>,
	Pete Popov <ppopov@embeddedalley.com>,
	David Hinds <dahinds@users.sourceforge.net>,
	"Roger C. Pao" <rpao@paonet.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:46244 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753144Ab1GaIab (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2011 04:30:31 -0400
In-Reply-To: <CAMuHMdXYoKkZrczdB6qPC1pfAGoTqgOiK2joY-38dewrVm5cRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ugZKF62n2uN97ujXQGAL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-07-31 at 01:14 -0700, Geert Uytterhoeven wrote:
> On Sun, Jul 31, 2011 at 05:26, Jeff Kirsher <jeffrey.t.kirsher@intel.com>=
 wrote:
> > --- /dev/null
> > +++ b/drivers/net/ethernet/amd/Kconfig
> > @@ -0,0 +1,188 @@
> > +#
> > +# AMD network device configuration
> > +#
> > +
> > +config NET_VENDOR_AMD
> > +       bool "AMD devices"
> > +       depends on DIO || MACH_DECSTATION || MVME147 || ATARI || SUN3 |=
| \
> > +                  SUN3X || SBUS || PCI || ZORRO || (ISA && ISA_DMA_API=
) || \
> > +                  (ARM && ARCH_EBSA110) || ISA || EISA || MCA || PCMCI=
A
>=20
> Do you really need this big dependency? It will be true in almost all
> cases anyway,
> and the individual driver options are protected by other dependencies.
> Just enabling this option doesn't make the kernel bigger.

My thought behind this was from the standpoint, if I have system/arch
which is not listed here and I am using menuconfig, I would not want to
see an option listed that does not have any value or drivers which I
could select.

>=20
> > +       ---help---
> > +         If you have a network (Ethernet) chipset belonging to this cl=
ass,
> > +         say Y.
> > +
> > +         Note that the answer to this question does not directly affec=
t
> > +         the kernel: saying N will just case the configurator to skip =
all
> > +         the questions regarding AMD chipsets. If you say Y, you will =
be asked
> > +         for your specific chipset/driver in the following questions.
> > +
> > +config A2065
> > +       tristate "A2065 support"
> > +       depends on NET_VENDOR_AMD && ZORRO
>=20
> What about putting all driver sections inside "if NET_VENDOR_AMD" /
> "endif", so the
> individual driver configs don't need to depend on NET_VENDOR_AMD anymore?

Your right, I could have done that instead.  I saw examples of both in
the current Kconfig's and I chose this one mainly because there were
several drivers already using this model, not that it was any better
than what you are suggesting.

Personally, after doing all the work, I do like your suggestion because
it would make it easier for adding drivers in the future, where they
would not have to "remember to add the NET_VENDOR_* to the driver
Kconfig dependency.

>=20
> The rest looks fine to me.
>=20
> Gr{oetje,eeting}s,
>=20
>                         Geert
>=20
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m6=
8k.org
>=20
> In personal conversations with technical people, I call myself a hacker. =
But
> when I'm talking to journalists I just say "programmer" or something like=
 that.
>                                 -- Linus Torvalds



--=-ugZKF62n2uN97ujXQGAL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJONRKlAAoJECTsCADr/EWUonMH/2YnvTxagKSzsqhMlRH6o0Qg
Ah7uKcDR0DuO0swtSDJosTDZALnYY8YCGy7ukiMgtfT0ZsQNUnGQiBDPHjF7xGgo
e3A+hUJFtDq6qxuOCJvARvoxkfTwXpyebOyKDUxGx/rHjzfG+FZ/HB7fVbKUj6LO
iSTYsOx9fr8eZ/VhSg2GpXm1qPW4HiE2i5li9sgE2fxYoLJwiHy1rdvy2kATTctr
rM6romXAZnbrWjBDVFTG6zbcnNb1YdmPMEs9yI4u4bfY0Et/U++NKLneQDRPmzMa
Ez8aXcTcHWd7VxfKr/5EN7oOpyNwULFbW2CgwsBIoqwxabEixKL1C606tgYYrlw=
=Tmmh
-----END PGP SIGNATURE-----

--=-ugZKF62n2uN97ujXQGAL--

