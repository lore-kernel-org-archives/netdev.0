From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Fri, 12 Sep 2003 23:04:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063404261.7869.446.camel@imladris.demon.co.uk>
References: <Pine.LNX.4.44.0309122049220.27849-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0309122049220.27849-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-09-12 at 21:00 +0300, Pekka Savola wrote:
> > But RFC1918 is what makes intranets work.=20
>=20
> .. in a broken manner.

Except site-local addressing in IPv6 actually fixed the major breakage
:)

>   We already have IPv4.  If you want to deploy IPv6,=20
> do it properly.  IPv6 is about global addressing.
>=20
> The bottom line is: it's just so much better idea to use global address=
es=20
> and filtering.

Two separate global addresses -- one for the 'internal' communication,
one for external communication without the routes sucking. And a
half-baked 'most of the time it'll pick the right source address,
hopefully' approach.

As opposed to a site address for intra-site communication and a global
address for global communication.=20

> > And the proposal you pointed
> > me at puts them _back_ again, just gratuitously globally unique, and
> > without the semantics which actually made them _more_ useful than
> > RFC1918; made them ideal for multi-homing with both site- and global-
> > scope addresses.
>=20
> Also, such semantics ("site-locals always preferred") caused a number o=
f
> problems.

As does their absence. The whole of this thread has been an attempt to
devise a workaround for the breakage caused by their absence.


> There is a problem especially with multi-party applications, which do=20
> referrals.  Consider theree nodes A, B, and C.  A and B are in the same=
=20
> site and have both globals and site-locals.  C has only globals.  By th=
e=20
> "site-local smallest scope rule", A and B talk using site-locals. =20
> However, if B tells C to contact A, he gives C a site-local address of =
A,=20
> instead of the global.  And C can't handle it.

Don't Do That Then.

Seriously; this is a known problem already and it's trivially avoidable.
Don't send a site-local address to a machine you're talking to using
globals. With explicit knowledge of scope, applications can _do_ that.=20

Whereas in the vile 'hosts have both HQ-derived addresses for internal
communication and addresses derived from their local IPv6 uplink for
global communication' scenario, the application has _no_ chance of
picking the right address.

> If you're interested to go a bit deeper to the reasoning, you may be=20
> interested to read=20
> http://www.ietf.org/internet-drafts/draft-wasserman-ipv6-sl-impact-02.t=
xt

At first glance, it seems that a lot of the problems go away if you
don't allow 'multi-sited' nodes, and more go away when you realise
they're already known and easily-avoided pitfalls of RFC1918 -- for
example, don't introduce gratuitous ambiguity by playing stupid
schizodns tricks as described in =C2=A73.3; use a sane domain like
'company.internal' for site-local addresses.

I need to read it more carefully, but to be honest it doesn't really
seem to justify the complete abolition of site-scope.

I suspect we're getting off-topic here though.

I suspect my implementation plan is going to revert to using site-local
addressing, since it's trivial and does precisely what I want.

I'll just have to trust that whatever the replacement is, it also solves
the address-selection issues which site-local scope solves _perfectly_
for internal networks.

--=20
dwmw2
