From: Stuffed Crust <pizza@shaftnet.org>
Subject: Re: wireless: recap of current issues (configuration)
Date: Fri, 13 Jan 2006 20:17:26 -0500
Message-ID: <20060114011726.GA19950@shaftnet.org>
References: <20060113195723.GB16166@tuxdriver.com> <20060113212605.GD16166@tuxdriver.com> <20060113213011.GE16166@tuxdriver.com> <20060113221935.GJ16166@tuxdriver.com> <1137191522.2520.63.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="XsQoSWH+UP9D9v3l"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1423251AbWANBRk@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1137191522.2520.63.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jan 13, 2006 at 11:32:02PM +0100, Johannes Berg wrote:
> I'm not sure this is worth it. While putting this into the WiPHY device
> creates more logic there, putting knowledge like 'how many different
> channels can this WiPHY device support' etc. into some representation
> that can be used by the stack to decide is much more trouble than it is
> worth.

Do you mean 'simultaneous' channel operation, or something more mundane=20
like simply 'what frequencies can I run on'?

If you're talking about the former.. things get quite complicated, but=20
that could be handled by having two WiPHY devices registered.

As for the latter, when you factor in the needs of 802.11d and its
dependents (802.11j, 802.11k, and others) the stack is going to need to
be aware of the available channel sets; both in the sense of hardware
support and also the various regulatory requirements.=20

The hardware knows what frequencies it supports.  Unfortunately this has=20
to be a somewhat dynamic thing, as this is often not queryable until the=20
device firmware is up and running. =20

This can be accomplished by passing a static table to the=20
register_wiphy_device() call (or perhaps via a struct wiphy_dev=20
parameter) or through a more explicit, dynamic interface like:

  wiphy_register_supported_frequency(hw, 2412).=20

 - Solomon
--=20
Solomon Peachy        				 ICQ: 1318344
Melbourne, FL 					=20
Quidquid latine dictum sit, altum viditur.

--XsQoSWH+UP9D9v3l
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFDyFEmPuLgii2759ARApk7AJ9vrsX3JKIgGn2/b6PhUQIkEF5jQACgzUaE
GZgZOrx7cdf72jqEHRGsRCk=
=QDWO
-----END PGP SIGNATURE-----

--XsQoSWH+UP9D9v3l--
