From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC v2 1/4] bridge: enable interfaces to opt out from becoming
 the root bridge
Date: Sun, 16 Feb 2014 18:56:52 +0000
Message-ID: <1392577012.15615.116.camel@deadeye.wl.decadent.org.uk>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
	 <1392433180-16052-2-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-rsGrmwfKCYJri+Sjh8qI"
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	bridge@lists.linux-foundation.org
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36680 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753300AbaBPS5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Feb 2014 13:57:05 -0500
In-Reply-To: <1392433180-16052-2-git-send-email-mcgrof@do-not-panic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-rsGrmwfKCYJri+Sjh8qI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-02-14 at 18:59 -0800, Luis R. Rodriguez wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
>=20
> It doesn't make sense for some interfaces to become a root bridge

I think you mean 'root port'.

> at any point in time. One example is virtual backend interfaces
> which rely on other entities on the bridge for actual physical
> connectivity. They only provide virtual access.
>=20
> Device drivers that know they should never become part of the
> root bridge have been using a trick of setting their MAC address
> to a high broadcast MAC address such as FE:FF:FF:FF:FF:FF. Instead
> of using these hacks lets the interfaces annotate its intent and
> generalizes a solution for multiple drivers, while letting the
> drivers use a random MAC address or one prefixed with a proper OUI.
> This sort of hack is used by both qemu and xen for their backend
> interfaces.
>=20
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: bridge@lists.linux-foundation.org
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
> ---
>  include/uapi/linux/if.h | 1 +
>  net/bridge/br_if.c      | 2 ++
>  net/bridge/br_private.h | 1 +
>  net/bridge/br_stp_if.c  | 2 ++
>  4 files changed, 6 insertions(+)
>=20
> diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
> index d758163..8d10382 100644
> --- a/include/uapi/linux/if.h
> +++ b/include/uapi/linux/if.h
> @@ -84,6 +84,7 @@
>  #define IFF_LIVE_ADDR_CHANGE 0x100000	/* device supports hardware addres=
s
>  					 * change when it's running */
>  #define IFF_MACVLAN 0x200000		/* Macvlan device */
> +#define IFF_BRIDGE_NON_ROOT 0x400000    /* Don't consider for root bridg=
e */
[...]

Does it really make sense to add a flag that says exactly which special
behaviour you want, or would it be better to define the flag as a
passive property, which other drivers/protocols then use as a condition
for special behaviour?

The fact that you also define the IFF_BRIDGE_SKIP_IP flag, and set it on
exactly the same devices, makes me think that they should actually be a
single flag.  I don't know how that flag should be named or described,
though.

Ben.

--=20
Ben Hutchings
Any sufficiently advanced bug is indistinguishable from a feature.

--=-rsGrmwfKCYJri+Sjh8qI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwEJ9Oe/yOyVhhEJAQr7ZQ//XJTbfwlF6wA9jJv96XiPN/YXk8vMVUqC
qgbGy8U4FXpg6gRIyASm6HiyviT7VZiLfskA9QGPKadgVb2x4LAPKPlQJGRWN2Pb
I6WpRq0QzqUBLTPstUUVbayfH1TuLCQ1aUBfJx60oE5mi4qPfCw8Jn+ngyXlj4dc
1FoS8Td2VKM9GOope4AYVcQ5HVPbyDgD88AZZQDtTaYEpK+ffW/7UcotEL0k3ddc
mS+voQikMFajOl2pyrZ0ztZXIVTGvJtDiHxN1wACEEu4s4pCMHvTiSDofb9vawCE
AuH8/RvRDLwaK3uUOQ+5U9g16L5hn4fOrKCSRBg+asYJ0u42YCHQfhnFFlBcVj6s
D9rSjg7bJQMGeCbhB7KOAJAzd430N598jqZmK8/eFHK6GDh2HVwwuLV14vmkhnVb
GAdqim31ZtJTvNSBbVZQx/4KHBewutCFHc+281D0HzGNfFfpprMlEEfO5q/f2Nre
jWyaccNLUK6bGlfmNeANCE2oGKit4jFUe7jgKb9xaWc/aLLEO4l4Jyq96evKpea0
KrLJgoNkscPpDzM8uPoqBEBUYHQ4kwXcQqQdCR4W2tjhCdcT0ZYQzwsi+A7Np0XY
EmTRwRC2wHVoLm1QT9+HwUxqMem2wtTKy/8I3I9EbY0FC6BDGqVrnyAGUldTGkgW
yFWN/QaYj80=
=hTJd
-----END PGP SIGNATURE-----

--=-rsGrmwfKCYJri+Sjh8qI--
