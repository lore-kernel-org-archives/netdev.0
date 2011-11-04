From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 03/10] seeq: Move the SEEQ drivers
Date: Fri, 04 Nov 2011 14:10:02 -0700
Message-ID: <1320441002.5386.4.camel@jtkirshe-mobl>
References: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1313134384-7287-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20111104172446.GB12913@n2100.arm.linux.org.uk>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-r20ogQ+nt6eC25WNE0gp"
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Hamish Coleman <hamish@zot.apana.org.au>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43747 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752607Ab1KDVKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 17:10:03 -0400
In-Reply-To: <20111104172446.GB12913@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-r20ogQ+nt6eC25WNE0gp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-11-04 at 10:24 -0700, Russell King - ARM Linux wrote:
> Okay, this is the only patch I saw (for the SEEQ drivers), but I notice
> that more of the ARM drivers have moved.  The result is not nice.  Or
> even workable.
>=20
> While looking for my ether1, ether3 and etherh drivers in Kconfig, I
> enable every option which is presented to me under the new 'ethernet
> drivers' stuff.  I'm offered my ether3 driver under the SEEQ stuff -
> that's fine.  But what about the rest?
>=20
> Well...
>=20
> drivers/net/ethernet/intel/Kconfig:
> config NET_VENDOR_INTEL
>         bool "Intel devices"
>         default y
>         depends on PCI || PCI_MSI
>=20
> drivers/net/ethernet/i825xx/Kconfig:
> config NET_VENDOR_I825XX
>         bool "Intel (82586/82593/82596) devices"
>         default y
>         depends on NET_VENDOR_INTEL && (ISA || ISA_DMA_API || ARM || \
>                    ARCH_ACORN || MCA || MCA_LEGACY || SNI_RM || SUN3 || \
>                    GSC || BVME6000 || MVME16x || EXPERIMENTAL)
>=20
> if NET_VENDOR_I825XX
> config ARM_ETHER1
>         tristate "Acorn Ether1 support"
>         depends on ARM && ARCH_ACORN
>=20
> This is NOT a PCI driver, yet it has ended up with a requirement for
> CONFIG_PCI to be set, which is nonsense for this platform because it
> has no PCI.
>=20
> What about etherh?
> drivers/net/ethernet/natsemi/Kconfig:
> config NET_VENDOR_NATSEMI
>         bool "National Semi-conductor devices"
>         default y
>         depends on MCA || MAC || MACH_JAZZ || PCI || XTENSA_PLATFORM_XT20=
00
>=20
> drivers/net/ethernet/8390/Kconfig:
> config NET_VENDOR_8390
>         bool "National Semi-conductor 8390 devices"
>         default y
>         depends on NET_VENDOR_NATSEMI && (AMIGA_PCMCIA || PCI || SUPERH |=
| \
>                    ISA || MCA || EISA || MAC || M32R || MACH_TX49XX || \
>                    MCA_LEGACY || H8300 || ARM || MIPS || ZORRO || PCMCIA =
|| \
>                    EXPERIMENTAL)
> if NET_VENDOR_8390
> config ARM_ETHERH
>         tristate "I-cubed EtherH/ANT EtherM support"
>         depends on ARM && ARCH_ACORN
>=20
> Again, exactly the same thing.
>=20
> Thankfully, ARM_AM79C961A is right, so that's two out of five correct.
>=20
> I've no idea what the right solution is to this complex maze of Kconfig
> stuff.  Do I through an 'ARM' into the NET_VENDOR_INTEL and
> NET_VENDOR_NATSEMI dependencies?
>=20
> While I realise this is a big change, and bugs like this are likely, it
> would've been nice to be copied on more of the patches which affect
> drivers I maintain.

I just submitted a patch to resolve this issue with the "sub" Kconfig's
having a dependency which is not reflected in the "parent" Kconfig.

http://patchwork.ozlabs.org/patch/123250/

--=-r20ogQ+nt6eC25WNE0gp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJOtFSqAAoJEOVv75VaS+3Oe2AP/i9/1t5svbaevqVhdaMyhPmr
d4MYfa//mKb/j7Cn8TXkJezFWH3VCL8HLblqHya0cIyOjBhrU7jw3zwSJWFZD4k8
ZOgHlghTCa8nXqBrKCrRE72BItRJmGFcTIS35W0z3j+vuWmS9sGc9f6FpHt755ap
bjp4j6k4HPsqyt2VI89PJADz2akZtd1UuvIIIDX4xulxDD9sZ8Ppu+DVrdqsLU71
1dkpVCbDdgF1WzcUzbofxlFs4Onv1kCIpIiJiT79xpHm2iAw+4O0KEZ71LlreDjP
5vcz967VtmQGG3VIofX3HcSJhgSe7F/8kvXYX3Nk2OCpsvRpgyCrAIDR+IWtDMGx
RXzbCBoqDzOx32ISvBeCyoSTdPD3pTvFxr2/I7+6v7eoRf2JqkAz7g9NmHZ5Qf3n
IkEsC+cLYwQBmPfOCWw/tU3YsxU88lOD/+iJJegUc17meEpNPCK4ptocJSYYc1Ep
csXGxN0D+SZa+GpDXXep9+IOunxgXfdcNGCGdvLaJEgM1nAxAM+QoT+HMxdUXx7+
nXqqnMSTLE0yvUiFl2UimFk8bruNF44WuvuViK0YgTsQN/5ROeXpQkJ1IdcLYaB1
cYEmD2UrIHoHaNCyO55TuZweVAXPNAB8NWOkhr3ZilreIvZqv256a5Zf/49TGYIj
O3/ooXFPEdGza145n4uL
=kJLi
-----END PGP SIGNATURE-----

--=-r20ogQ+nt6eC25WNE0gp--
