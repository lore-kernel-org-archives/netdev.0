From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Sat, 13 Sep 2003 06:57:59 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309130642490.779-100000@netcore.fi>
References: <1063404261.7869.446.camel@imladris.demon.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1063404261.7869.446.camel@imladris.demon.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 12 Sep 2003, David Woodhouse wrote:
> On Fri, 2003-09-12 at 21:00 +0300, Pekka Savola wrote:
> > The bottom line is: it's just so much better idea to use global addre=
sses=20
> > and filtering.
>=20
> Two separate global addresses -- one for the 'internal' communication,
> one for external communication without the routes sucking. And a
> half-baked 'most of the time it'll pick the right source address,
> hopefully' approach.
>=20
> As opposed to a site address for intra-site communication and a global
> address for global communication.=20

The bottom line for that is: there is no longer a clear distinction of
"inside" and "outside".  Any design which assumes all the internal nodes
can communicate freely with each other seems very subject to abuse, and
multiple points of failure (where one node can compromise all of them). =20
For such communication, globals are the best -- there has to be internal
filtering -- and gives no false sense of security which would rely on=20
addressing.

Note that this is slightly different wrt. RFC1918 addresses.  Deploying
both globals and site-locals makes the problem of "compromise one node,
use it as a stepping stone to compromise all the local nodes" slightly
worse.

Therefore, the use of "internal addresses" does not help with that except
for very small sites (e.g. home, using dial-up and getting a different
prefix every time, but the internal communication should stay stable), it
only propagates bad design from IPv4 to IPv6.
=20
> > There is a problem especially with multi-party applications, which do=
=20
> > referrals.  Consider theree nodes A, B, and C.  A and B are in the sa=
me=20
> > site and have both globals and site-locals.  C has only globals.  By =
the=20
> > "site-local smallest scope rule", A and B talk using site-locals. =20
> > However, if B tells C to contact A, he gives C a site-local address o=
f A,=20
> > instead of the global.  And C can't handle it.
>=20
> Don't Do That Then.
>=20
> Seriously; this is a known problem already and it's trivially avoidable.
> Don't send a site-local address to a machine you're talking to using
> globals. With explicit knowledge of scope, applications can _do_ that.=20
>=20
> Whereas in the vile 'hosts have both HQ-derived addresses for internal
> communication and addresses derived from their local IPv6 uplink for
> global communication' scenario, the application has _no_ chance of
> picking the right address.

Applications are not supposed to know the scope, or be able (or even WANT=
)=20
to take any stance on the properties of addresses they're using.
=20
> > If you're interested to go a bit deeper to the reasoning, you may be=20
> > interested to read=20
> > http://www.ietf.org/internet-drafts/draft-wasserman-ipv6-sl-impact-02=
.txt
>=20
> At first glance, it seems that a lot of the problems go away if you
> don't allow 'multi-sited' nodes, and more go away when you realise
> they're already known and easily-avoided pitfalls of RFC1918 -- for
> example, don't introduce gratuitous ambiguity by playing stupid
> schizodns tricks as described in =C2=A73.3;=20

True, to an extent.

> use a sane domain like
> 'company.internal' for site-local addresses.

Right, but not everybody may be content with that kind of approach..

> I'll just have to trust that whatever the replacement is, it also solve=
s
> the address-selection issues which site-local scope solves _perfectly_
> for internal networks.

I doubt that, because the address selection is something that caused a=20
number of problems in the first place.  However, longest prefix match=20
gives a working communication in most cases.

--=20
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
