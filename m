From: Stuffed Crust <pizza@shaftnet.org>
Subject: Re: wireless: recap of current issues (configuration)
Date: Sun, 15 Jan 2006 11:18:53 -0500
Message-ID: <20060115161853.GC1722@shaftnet.org>
References: <20060113195723.GB16166@tuxdriver.com> <20060113212605.GD16166@tuxdriver.com> <20060113213011.GE16166@tuxdriver.com> <20060113221935.GJ16166@tuxdriver.com> <1137282117.27849.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IpbVkmxF4tDyP/Kb"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932093AbWAOQTT@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1137282117.27849.11.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--IpbVkmxF4tDyP/Kb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jan 14, 2006 at 06:41:56PM -0500, Dan Williams wrote:
> One other thing: capability.  It's not enough to be able to configure
> the device, user-space tools also have to know what the device is
> capable of before they try touching it.  Ie, which ciphers, protocols,
> channels, etc.  Similar to the IWRANGE ioctl that there is now.  Half
> the problem now is that you can't reliably tell what drivers support
> which features, or how much they support a particular feature.=20

This is an absolute requirement, especially when talking about=20
encryption. =20

You'd need, for example:

CAP_WEP_64
CAP_WEP_128
CAP_WEP_256 (non-standard, but often supported)
CAP_TKIP
CAP_MICHAELMIC
CAP_AES_CCMP

Then, to make things more complicated:

CAP_KEYMAPPING (can the hardware do keymapping?)
CAP_CAN_DISABLE_HWCRYPT (so if the hardware can't do TKIP, can we=20
                         perform it on the host?)

And to make things even more complicated, I've seen hardware that=20
supports disabling of hardware crypto, but not toggling it on the fly,=20
thanks to never-fixed hardware bugs. (you have to perform a full=20
reset/firmware load cycle.  this means you end up disabling host crypto=20
altogether, at least if any of the networks you want to support include=20
CCMP...

Other quirks -- hardware that requires host MICHAEL on transmits, but
handles it on reception, unless if the received frames are fragmented.=20
Other hardware that does keymapping on rx frames, but for transmits
takes the raw keydata in the tx descriptor.  (but still requires host
MICHAEL)

The list goes on and on..

 - Solomon
--=20
Solomon Peachy        				 ICQ: 1318344
Melbourne, FL 					=20
Quidquid latine dictum sit, altum viditur.

--IpbVkmxF4tDyP/Kb
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFDynXtPuLgii2759ARAuvHAJ0fpGxkcVQZZ2yKWTTV7VNXimP9FACg4eyn
NbMwA2ou5O6SrCuY/o/EaLY=
=5di8
-----END PGP SIGNATURE-----

--IpbVkmxF4tDyP/Kb--
