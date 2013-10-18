From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH net] bridge: clean the nf_bridge status when forwarding
 the skb
Date: Fri, 18 Oct 2013 17:41:23 +0200
Message-ID: <20131018154123.GM2596@neomailbox.net>
References: <1381791096-3561-1-git-send-email-antonio@meshcoding.com>
 <20131017112857.GA11318@localhost>
 <20131017113735.GB2699@open-mesh.com>
 <20131018111041.GA10964@localhost>
 <20131018113555.GK2596@neomailbox.net>
 <52614669.5040301@redhat.com>
 <20131018144618.GL2596@neomailbox.net>
 <526154B2.2060900@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="eMP3JyRexyk9c0Bv"
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Antonio Quartulli <antonio@open-mesh.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:18498 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756089Ab3JRPmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 11:42:05 -0400
Content-Disposition: inline
In-Reply-To: <526154B2.2060900@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--eMP3JyRexyk9c0Bv
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 18, 2013 at 11:33:06AM -0400, Vlad Yasevich wrote:
> On 10/18/2013 10:46 AM, Antonio Quartulli wrote:
> > On Fri, Oct 18, 2013 at 10:32:09AM -0400, Vlad Yasevich wrote:
> >> On 10/18/2013 07:35 AM, Antonio Quartulli wrote:
> >>> On Fri, Oct 18, 2013 at 01:10:41PM +0200, Pablo Neira Ayuso wrote:
> >>>> On Thu, Oct 17, 2013 at 01:37:35PM +0200, Antonio Quartulli wrote:
> >>>>> On Thu, Oct 17, 2013 at 04:28:57AM -0700, Pablo Neira Ayuso wrote:
> >
> > [...]
> >
> >>>
> >>> The problem I was having was due to an skb entering br0 first and br1=
 later.
> >>> When reaching br1 skb->nf_bridge was !=3D NULL because of the previou=
s processing
> >>> in br0.
> >>>
> >>
> >> Doesn't br_nf_pre_routing already take care of this for you?  It will
> >> drop the ref on the current nf_bridge and allocate a new one.  Is that
> >> not sufficient?
> >
> > In my case that line is not reached because
> >
> >   700         if (!IS_IP(skb) && !IS_VLAN_IP(skb) && !IS_PPPOE_IP(skb))
> >
> > is always true: the packet getting analysed is a batman-adv encapsulate=
d packet,
> > which does not match any of the three above.
> >
> > Cheers,
> >
>=20
> Looking at other encapsulators (PPP, iptunnel, VXLAN), they do
> nf_reset() on input.  Would that be appropriate for batman as well?

I thought that too.

But at this point, wouldn't it be better to do a reset here and remove the =
other
resets from any other encapsulation module?

Maybe this operation is supposed to not happen if no encapsulation is invol=
ved?
I thought that polishing the nf state when exiting the nf related path was a
clean and easy solution.

Moreover we avoid that any newly implemented tunneling module hit this prob=
lem again.


Cheers,

--=20
Antonio Quartulli

--eMP3JyRexyk9c0Bv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSYVajAAoJEADl0hg6qKeOBeAQAKqpPX+YCHq4iGJzDrSimJPY
XvIm3eDzW7xD9Dn8+mtnz21qK7ciVEa0oo9KT7EACPuno6aPwiD1ZMj0pH0Vscrd
jhI49oth/xwICdbFUf1aVdksGD++cWpw90Zk4YX87nSVEOdXUhkfxLyAamPfvUO9
QZg98M955fkp4lWqZbFWvIRHa7n5vsUfvO2AxFLkut5J5mEW+kC1oexTngefNLS1
UUkw0r8yGiIkmIk4+FVLC9VPG1MC0ZRfcSx9e0Sa4RKlYPqlwU6OJ5W4KHFxgugG
uiVUQxpknho5XPjyy8NbHVDNpzRHK14BwRzaPrZj1dcNq7y1L+kEqIEG7Z2rvj4p
vHpJxXPrhLjoeHxaG6J6QdByltXMyKpbRy4VIDtIojC5uHGqciE7IvxL29Aqyzm1
UZ+LbwDTLRfxyH9xa0hH1PJZFWloTsEKOQ45SfMQr89PwrjFf76EHlpusbexHf5d
mUe3Oz6EA9w0DAXTzuY/Yi0q3KogeXm/Vk+wWpAwxZ1BOOLP6Ale5vxSA2+0uxhX
28ZdIL78czJeK5Fng8AaqoHRlzvqXr/WW8Q9VEDhIKfEYZq8RBq3suClwcYaD3ts
mD1JWJgc6CeKSqfRZwdGncpVSzZSlaQ1E4ynz32xkpRJBKbzfdKspVxk/u5h8bGk
Jyn/yDIANTjp+K3OcZlX
=vSuT
-----END PGP SIGNATURE-----

--eMP3JyRexyk9c0Bv--
