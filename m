From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: Config Items appearing twice in same Kconfig file?
Date: Thu, 13 May 2010 11:08:49 +1000
Message-ID: <1273712929.25436.5.camel@concordia>
References: <20100512143445.GA32559@faui48a.informatik.uni-erlangen.de>
	<20100512144017.GA722@faui48a.informatik.uni-erlangen.de>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============9149217305822838533=="
Cc: linux-ia64@vger.kernel.org, vamos@i4.informatik.uni-erlangen.de,
	Jesse Barnes <jbarnes@virtuousgeek.org>, Timo Teras <timo.teras@iki.fi>,
	Chen Liqin <liqin.chen@sunplusct.com>, Paul Mackerras <paulus@samba.org>,
	"H. Peter Anvin" <hpa@zytor.com>, Lennox Wu <lennox.wu@gmail.com>,
	Jesper Nilsson <jesper.nilsson@axis.com>,
	"Pekka Savola \(ipv6\)" <pekkas@netcore.fi>, x86@kernel.org,
	James Morris <jmorris@namei.org>, Ingo Molnar <mingo@redhat.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Matt Turner <mattst88@gmail.com>,
	Fenghua Yu <fenghua.yu@intel.com>, Mike Frysinger <vapier@gentoo.org>,
	Arnd Bergmann <arnd@arndb.de>, Graf Yang <graf.yang@analog.com>,
	Mikael Starvik <starvik@axis.com>,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	Thomas Gleixner <tglx@linutronix.de>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Richard Henderson <rth@twiddle.net>, Karsten Keil <isdn@linux-pi
To: Christoph Egger <siccegge@cs.fau.de>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20100512144017.GA722@faui48a.informatik.uni-erlangen.de>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org


--===============9149217305822838533==
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-h/kN6/EO2DvGfQAWWQqy"


--=-h/kN6/EO2DvGfQAWWQqy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2010-05-12 at 16:40 +0200, Christoph Egger wrote:
> Just noticed it might have been worth adding the output so everyone
> out there doesn't ned to grep through his tree for reference:
>=20
> % grep  ^config **/Kconfig* | sort | uniq -dc                            =
  =20

That didn't actually work for me?

>       2 arch/powerpc/Kconfig:config KERNEL_START
>       2 arch/powerpc/Kconfig:config PAGE_OFFSET
>       2 arch/powerpc/Kconfig:config PHYSICAL_START
>       2 arch/powerpc/Kconfig:config RELOCATABLE

The duplication of these is caused by the second definitions being
inside an "if PPC64" block.

For PAGE_OFFSET and KERNEL_START we want the 2nd definitions, the
default value is different between 32 & 64 bit.

For RELOCATABLE it's a little weird, but we want the 2nd definition
because the depends condition is different between 32 & 64bit - though
they could probably be merged.

I don't really see why we need two versions of PHYSICAL_START.

cheers

--=-h/kN6/EO2DvGfQAWWQqy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkvrUR0ACgkQdSjSd0sB4dJ7HwCgmCXXhb0zeKo4q5rwizaQsc1u
qnUAoKwiE9Qk0disa6OQAd42Mv7OowT2
=UXV0
-----END PGP SIGNATURE-----

--=-h/kN6/EO2DvGfQAWWQqy--


--===============9149217305822838533==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@lists.ozlabs.org
https://lists.ozlabs.org/listinfo/linuxppc-dev
--===============9149217305822838533==--
