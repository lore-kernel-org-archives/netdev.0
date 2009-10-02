From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Messages are printed on screen
Date: Fri, 02 Oct 2009 21:49:39 +0100
Message-ID: <1254516579.23350.89.camel@localhost>
References: <ha4igd$ghh$1@ger.gmane.org>
	 <1254480996.23350.73.camel@localhost>  <ha4q26$7mt$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-JOBE4T/lT7vubLfjGF/z"
Cc: netdev@vger.kernel.org
To: Markus Feldmann <feldmann_markus@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40267 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758158AbZJBUtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 16:49:39 -0400
In-Reply-To: <ha4q26$7mt$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-JOBE4T/lT7vubLfjGF/z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-10-02 at 14:01 +0200, Markus Feldmann wrote:
> Ben Hutchings schrieb:
> > On Fri, 2009-10-02 at 11:52 +0200, Markus Feldmann wrote:
> >
> >>
> >> As you see some of my IRQ-Lines are multiply in use, so my Server is=20
> >> working hard at his limit.
> >=20
> > IRQ sharing is normal on PCs without MSI support, but to see where
> > that's happening you need to look at /proc/interrupts and not the BIOS
> > setup program or wherever you got the above information from.
> Ok i did <cat /proc/interrupts> and got:
>             CPU0
>    0:     259603    XT-PIC-XT        timer
>    1:       1421    XT-PIC-XT        i8042
>    2:          0    XT-PIC-XT        cascade
>    4:     200000    XT-PIC-XT        ohci_hcd:usb3, pppp0

This number is a clue because after every 100,000 interrupts for a
particular IRQ the kernel checks how many of them were handled.  If this
is less than 100 then it disables the IRQ.  So I suspect one of these
devices is misbehaving, or its driver is not handling interrupts
correctly.  Is 'pppp0' actually an Ethernet device that you're using for
PPPoE?  If so, what model of network card is it?

>    5:          0    XT-PIC-XT        ehci_hcd:usb1, lan0
>    7:       6959    XT-PIC-XT        lan1
>    8:          2    XT-PIC-XT        rtc0
>    9:          0    XT-PIC-XT        acpi
>   11:      37697    XT-PIC-XT        ide2, ide3, ohci_hcd:usb2, lan2
>   14:          0    XT-PIC-XT        ide0
> NMI:          0   Non-maskable interrupts
> TRM:          0   Thermal event interrupts
> MCE:          0   Machine check exceptions
> MCP:         13   Machine check polls
> ERR:          2
>=20
> How can i assigned IRQs during Boot?
[...]

They are assigned by the BIOS.  You may be able to configure this in
BIOS setup.

Ben.

--=20
Ben Hutchings
Who are all these weirdos? - David Bowie, about L-Space IRC channel #afp

--=-JOBE4T/lT7vubLfjGF/z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASsZnXue/yOyVhhEJAQJpzA/8CTYyAIJi2UfqE17Ude+aGlSlbrHi00d+
nd2JUWZRWeen12nuy/RR9yagJqbCHxdfOn28M/Ed34RrX7TcsUyAifRUr2Mo1eGZ
dIzKLkFygV0tD3BGY8T/BbOqyQxMju/YovJZ2dgr6Em/0mW2Y70A0UKj7hD6/0yM
/kxRSPNUDUggSjinXIHM1vcfcn/FQX1WuZrNrM2MH4TxYED5mih8XsBvpxLbGwmY
2hZzh9WmgIbGI6ShwByL9ZFlVf2EFn1VKrOLcJaLMkBP8xTlPvd72jRkCjuqSA+p
9g7w8vn1PennnW1mfB80FC0J78X1TUuz3A1N2QudzSsHfyJ0fl2qG8/nT42Q8llJ
RZScWvqfRDHPTTbU+AI4o1ZvMAYj5sI0k7SLxlFfQ2uZlEZlSYeKX/niARaXpI1M
1zabdqSpiNCr7RfdOPjvDG5RVqFX5C41R+2ee0DDdM/H6t7s+0B3q/cVt26ZOLyW
7CmnxAmvl5nlfQ1oVU5/qhlo5aayNaHDrTDmHFfJvgPHnmaTVtE1qwgxTY3lEPhr
IX9D2aqJeBOr3RCOWXf+lQQYHLkwpWGVT7AwbemW7LQxr4AXdA52LfwAz+EvV6vZ
wi/4frrikV+tRHHBgF5zPAgat5LOtv7lYlJTUlgGMkJtZBE99EH9jUbstxeaDJ+l
Pw8y++WkBc0=
=Le9U
-----END PGP SIGNATURE-----

--=-JOBE4T/lT7vubLfjGF/z--
