From: Stuffed Crust <pizza@shaftnet.org>
Subject: Re: wireless: recap of current issues (configuration)
Date: Mon, 16 Jan 2006 15:16:27 -0500
Message-ID: <20060116201627.GC12748@shaftnet.org>
References: <20060113195723.GB16166@tuxdriver.com> <20060113212605.GD16166@tuxdriver.com> <20060113213011.GE16166@tuxdriver.com> <20060113221935.GJ16166@tuxdriver.com> <1137191522.2520.63.camel@localhost> <20060116152312.6b9ddfd0@griffin.suse.cz> <1137423355.2520.112.camel@localhost> <20060116173325.GC8596@shaftnet.org> <43CBDF32.50109@errno.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="69pVuxX8awAiJ7fD"
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751196AbWAPURS@vger.kernel.org>
To: Sam Leffler <sam@errno.com>
Content-Disposition: inline
In-Reply-To: <43CBDF32.50109@errno.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--69pVuxX8awAiJ7fD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 16, 2006 at 10:00:18AM -0800, Sam Leffler wrote:
> Perhaps you haven't hit some of the more recent standards that place=20
> more of a burden on the ap implementation?  Also some vendor-specific=20
> protocol features suck up space for ap mode only and it is nice to be=20
> able to include them only as needed.

While there is more work to be done on the AP side, and that code may
even be easily wrapped in an #ifdef, the majority of the complexity is
shared by both the station and the AP.  It's worth mentioning that the
802.11 specs do not generally differentiate between "APs vs non-APs" --
they're all "STAs" of equal capabilities.

This is at least true of 802.11d, 802.11e, 802.11i
(supplicant/authenticator notwithstanding), 802.11j, and 802.11k.  The
general difference is that the AP needs to be aware of the state of its
associated STAs, and perform different actions depending on configured
policy and the STAs' states, whereas the STAs generally do what the AP
tells them to do.

> There are several advantages to splitting up the code such as reduced=20
> audit complexity and real space savings but I agree that it is an open=20
> question whethere there's a big gain to modularizing the code by=20
> operating mode.

I agree that there would be some space savings, but they'd be relatively
small, at least if the stack is designed to be generic.  This would make
the most difference for tiny/embedded systems -- but they'd want to use
#ifdefs to disable all AP code entirely, which includes all of the "if=20
(ap_mode) { } else { }" clauses that would litter the whole codebase,=20
regardless of modularity.  (then if we use function pointers... that's a=20
*lot* of virtual functions..)

 - Solomon
--=20
Solomon Peachy        				 ICQ: 1318344
Melbourne, FL 					=20
Quidquid latine dictum sit, altum viditur.

--69pVuxX8awAiJ7fD
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFDy/8bPuLgii2759ARAr8+AJ9eOvYBvCyRanBWmPcoxpFgkG77mwCgiYh1
ThjIgjnzcX28SC2ANjNmsMU=
=HKf2
-----END PGP SIGNATURE-----

--69pVuxX8awAiJ7fD--
