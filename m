From: Antonio Quartulli <antonio@open-mesh.com>
Subject: Re: [PATCH 1/3] if.h: add IFF_BRIDGE_RESTRICTED flag
Date: Tue, 9 Apr 2013 09:56:06 +0200
Message-ID: <20130409075606.GB3771@open-mesh.com>
References: <1365442863-32394-1-git-send-email-antonio@open-mesh.com>
 <1365442863-32394-2-git-send-email-antonio@open-mesh.com>
 <CAOaVG17nHuoRsf2Kss6LnpgC-Aojcso_zLYyBa18Vn9CGGY+GA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="v9Ux+11Zm5mwPlX6"
Cc: "David S. Miller" <davem@davemloft.net>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ht1.myhostedexchange.com ([69.50.2.37]:32957 "EHLO
	ht1.hostedexchange.local" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S934894Ab3DIH5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 03:57:32 -0400
Content-Disposition: inline
In-Reply-To: <CAOaVG17nHuoRsf2Kss6LnpgC-Aojcso_zLYyBa18Vn9CGGY+GA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--v9Ux+11Zm5mwPlX6
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 08, 2013 at 11:58:48 -0700, Stephen Hemminger wrote:
> The standard way to do this is to use netfilter. Considering the
> additional device flags and skb flag changes, I am not sure that your
> method is better.

To make it a bit more clear:

1) the skb flag will be used on the "receiving end-point" by batman-adv to =
mark
received packets and so instruct the bridge to do not forward them to restr=
icted
interfaces.

2) the IFF_ flag is used by batman-adv on the "sending side" to determine
whether a packet has been originated by a restricted interface and so instr=
uct
the remote endpoint to mark the skb when received.

3) to make the bridge code general enough, I decided to let it mark packets
coming from restricted interfaces as well so that it can also apply the pol=
icy
at 1) locally, without any further setting. The logic described in 1) is
therefore applied by the bridge even for local packets (not passing through
batman-adv)



Point 3) is the only one where netfilter might help. But using two mechanis=
m to
achieve one goal looked not sane to me and therefore I decided to to do it =
this
way. And actually the code allowing point 3 is only:

+       skb->bridge_restricted =3D !!(skb->dev->flags & IFF_BRIDGE_RESTRICT=
ED);


I hope this summary did not create further confusion :)

Thanks,

>=20
> On Mon, Apr 8, 2013 at 10:41 AM, Antonio Quartulli
> <antonio@open-mesh.com> wrote:
> > This new flag tells whether a network device has to be
> > considered as restricted in the new bridge forwarding logic.
> >
> > Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
> > ---
> >  include/uapi/linux/if.h | 1 +
> >  net/core/dev.c          | 2 +-
> >  2 files changed, 2 insertions(+), 1 deletion(-)
> >
> > diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
> > index 1ec407b..5c3a9bd 100644
> > --- a/include/uapi/linux/if.h
> > +++ b/include/uapi/linux/if.h
> > @@ -83,6 +83,7 @@
> >  #define IFF_SUPP_NOFCS 0x80000         /* device supports sending cust=
om FCS */
> >  #define IFF_LIVE_ADDR_CHANGE 0x100000  /* device supports hardware add=
ress
> >                                          * change when it's running */
> > +#define IFF_BRIDGE_RESTRICTED 0x200000 /* device is bridge-restricted =
*/
> >
> >
> >  #define IF_GET_IFACE   0x0001          /* for querying only */
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 3655ff9..49eafc8 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -4627,7 +4627,7 @@ int __dev_change_flags(struct net_device *dev, un=
signed int flags)
> >
> >         dev->flags =3D (flags & (IFF_DEBUG | IFF_NOTRAILERS | IFF_NOARP=
 |
> >                                IFF_DYNAMIC | IFF_MULTICAST | IFF_PORTSE=
L |
> > -                              IFF_AUTOMEDIA)) |
> > +                              IFF_AUTOMEDIA | IFF_BRIDGE_RESTRICTED)) |
> >                      (dev->flags & (IFF_UP | IFF_VOLATILE | IFF_PROMISC=
 |
> >                                     IFF_ALLMULTI));
> >
> > --
> > 1.8.1.5
> >

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--v9Ux+11Zm5mwPlX6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRY8mWAAoJEADl0hg6qKeOBfsP/Aw0cEjNkAXWCBxDp0aGpl70
Js9/+KBtmcJHWVqFUZXp46qiGmj2inNPud95Krery3fgGsXEBJYiY6wdmZqOkBM1
ajcoAPUcUOnmQpIuhLsVxdxywMlblBp0J34oj+RRSoVwR62WC4ZGgsebg0luqB0H
qKobTss2mwzm7exzCRDXBWrZ3Tc4HxiJLkpC1VJ5Dogq/uEeSK/ke0E0dvALX/X9
bKvIUB7jPpCNqhk6yoY5Npbhu2uYyN3MQAIY+3BfobgfM6/9KQRR+hB2eLVGtw3B
7JrZ5YHLiu/MoqJz8Hqj+CumkaB5MVeyM1mA2DRY9zoi3dL4vbFqDWD40GhWyeS3
61Q4a4LMciuvyE2ZKpyTlDAli8eYHTUNGcHxOlSUkDI8hIEAwqUYi8/MA8LRp1gf
Af7Ng2Lme6H2Xi7hzM9CsXXcchlMpaynNdcg0iGH8Yz3luUzXMBkfpLHftELP1Bv
P5j1Qn/S1sFdtnZFPdMkbhIwBpaLYZ2GU4SqM7P8nLt1shG3TQF126iX6BPzyOc/
M+pRj4OPs5GLOk0OJ7x7ROmf7XH/tl0FkMVkEglMFli4RM+7Oz33WqcxNWdQ+UZc
D72KSj281vg4dxbdodcNW7HPry6YYMnCy+XlvjsEYDQG0s4IDlGGXKZ4ezEvhgnU
pw9E3Qix0kbUsgaZXPAH
=8nXs
-----END PGP SIGNATURE-----

--v9Ux+11Zm5mwPlX6--
