From: Eric B Munson <emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Allow TCP connections to cache SYN packet for userspace
 inspection
Date: Fri, 1 May 2015 16:01:36 -0400
Message-ID: <20150501200136.GA6113@akamai.com>
References: <1430502237-5619-1-git-send-email-emunson@akamai.com>
 <CALCETrWi6h3DRu6Z8jJ_-MiWqRRyKZHntpJFNON=GpAjMDYXmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="45Z9DzgjV8m4Oswq"
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrWi6h3DRu6Z8jJ_-MiWqRRyKZHntpJFNON=GpAjMDYXmQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 01 May 2015, Andy Lutomirski wrote:

> On Fri, May 1, 2015 at 10:43 AM, Eric B Munson <emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org> wrote:
> > In order to enable policy decisions in userspace, the data contained in
> > the SYN packet would be useful for tracking or identifying connections.
> > Only parts of this data are available to userspace after the hand shake
> > is completed.  This patch exposes a new setsockopt() option that will,
> > when used with a listening socket, ask the kernel to cache the skb
> > holding the SYN packet for retrieval later.  The SYN skbs will not be
> > saved while the kernel is in syn cookie mode.
> >
> > The same option will ask the kernel for the packet headers when used
> > with getsockopt() with the socket returned from accept().  The cached
> > packet will only be available for the first getsockopt() call, the skb
> > is consumed after the requested data is copied to userspace.  Subsequent
> > calls will return -ENOENT.  Because of this behavior, getsockopt() will
> > return -E2BIG if the caller supplied a buffer that is too small to hold
> > the skb header.
>=20
> What's the purpose and what headers are you returning?

Currently the ethernet, IP, and TCP headers are being returned.  The IP
and TCP headers will be used by userspace to make decisions on how to
handle incoming connections.  The ethernet headers are being returned
for completeness, I would be fine not including them in what is copied
if that is a concern, however the team requesting this change here
requires the IP and TCP headers.

>=20
> There was a bit of a mixup with tx timestamps where the set of headers
> returned was possibly excessive and incompletely thought out the first
> time around.

With this in mind, we could drop copying the ethernet headers and simply
hold onto the IP and TCP headers.

>=20
> --Andy

--45Z9DzgjV8m4Oswq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVQ9ugAAoJELbVsDOpoOa94z0QAI9y7GBAJ5yVbmKrgPFKMbiS
09G8rikm+zEYVBNoL4wgIqlmKetNwZgA6MHKIKKC9hshkBlrzwL7o4licewyQzv9
RVY1iKdH1MOKjvrrOS5qaj6N6pGpLLfdfsapmuxqOWwTxNmzdg34CukqfTntn95s
EDkxflsoB0uBY+ypTc6BSvVciwfxRGZbcIskw2MYMCqzrAUUv69MCanC7336nocq
9TbMTOxgRy80PsdGLwVS212LMHJE2aFmpTuAvssqPg7Okn/KHxUnfOGtxwUdy4gO
dlJk2S621eW2oUU93Q2bv8TQZPbCq1Ob6HDY7JyiSE2CeCaSnbHMoGt8Lk9Hge/u
My64+XiaMvPhO+X6yzKKZ5MMN8yllvIrT3Vd7pojuGuxqQ7XogBBrjjjf+ZFxaZl
ldXlO9+IjUa24bCcoX0FKSr6n42zQ7g7K/c+BNAAwqt42y+QkZKLXmnTKk8/Ur+u
k7jkrptSZr4JN8Bca5RV4d9+PZjQimHblcl5ZHkfnVPt+fDEO0Jm21NjuahNVZNB
rEI1h0ONzcapOEHT3cWEYebtnP0JnjhPVlLDq01/DtL9lUxVzGD/YZGabb4ziGtO
lIyPRb8BUkvzbWtpy+/K1bW52T69q4MBg8SxjtUVW2BQT2s2J19ub4xA6sGdM3p+
BzTGN+3xoH7VFRqem0on
=QXki
-----END PGP SIGNATURE-----

--45Z9DzgjV8m4Oswq--
