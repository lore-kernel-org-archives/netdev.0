From: Philipp Kern <pkern@debian.org>
Subject: Re: [PATCH] net: move "IPv6: sending pkt_too_big to self" to NETDEBUG
Date: Sun, 29 Jul 2012 14:24:02 +0200
Message-ID: <20120729122402.GA23910@spike.0x539.de>
References: <1343487997-9047-1-git-send-email-pkern@debian.org>
 <1343496560.2009.15.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="82I3+IH0IqGh5yIs"
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	ak@linux.intel.com
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1343496560.2009.15.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jul 28, 2012 at 10:29:20AM -0700, Joe Perches wrote:
> On Sat, 2012-07-28 at 17:06 +0200, Philipp Kern wrote:
> > ip6_xmit checks if the outgoing packet is larger than the path MTU and
> > emits ICMPv6 packet too big locally if this is the case. Logging this,
> > even at KERN_DEBUG, confuses users. It is also not actually helpful for
> > debugging, given that there is no reference to the connection that
> > triggered this event.
> []
> > diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> []
> > @@ -241,7 +241,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, =
struct flowi6 *fl6,
> >  			       dst->dev, dst_output);
> >  	}
> > =20
> > -	net_dbg_ratelimited("IPv6: sending pkt_too_big to self\n");
> > +	LIMIT_NETDEBUG("IPv6: sending pkt_too_big to self\n");
> LIMIT_NETDEBUG doesn't include a logging level.
> Add a KERN_DEBUG prefix or another KERN_<LEVEL>.

True, sorry, and thanks. That got lost with the change to net_dbg_ratelimit=
ed.

> Maybe it'd be better to add the context too.

Right. What kind of context do you want to see? Would saddr, daddr and dst_=
mtu
be enough? What about skb->len / local_df / skb_is_gso (which are in the
condition of the preceding if)?

Kind regards
Philipp Kern

--82I3+IH0IqGh5yIs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEAREIAAYFAlAVK2IACgkQ7Ro5M7LPzdgwvwCeNnVVEZjjrpzqSF1QHt+OdwU8
A4oAoLrnwa3nxb2RSdorii9KQdKoozJjiQEcBAEBCAAGBQJQFStiAAoJEERuJUU1
0FbsXYoH/ixslK4agb9iopqzKQyUWZIyWE7E7SLJCqI38Q43JbMGGXiMQHpxgR3R
GeqSv1zGzPsaepN6tGfpAiFuMdTt3Cw+ElkFZ/9DJiNEQANsjVoqTm24tM3iYvgC
/0HwqZtewj+LgQGOosBa5xjgLoYX3ZNEW5TYW7oqWH9H4LMg3QAUSrKWQ2j/FNe4
/8Am3qrv/2YJIvvqlV1TnByMRmrEmkyjHUzk8YM5skHX4chQyo4RHm4VB99oEFsL
La7CCGNeVZa/xlGju5tqq3h27MQ6Pdwz8V2zScFZv5SkX9J+Cf8zilvbTb5CyVIP
AqHCuE6Wr22DkihPccraYv5j05q9Iz0=
=w8Is
-----END PGP SIGNATURE-----

--82I3+IH0IqGh5yIs--
