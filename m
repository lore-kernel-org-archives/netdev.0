From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Fri, 12 Sep 2003 11:16:53 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063361813.23778.419.camel@hades.cambridge.redhat.com>
References: <Pine.LNX.4.44.0309121234261.23575-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0309121234261.23575-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-09-12 at 12:48 +0300, Pekka Savola wrote:

> A year or two down the path, there may be another "local addressing"=20
> approach.. there is already a proposal:
>=20
> http://www.ietf.org/internet-drafts/draft-ietf-ipv6-unique-local-addr-0=
0.txt
>=20
> .. but whether thats *the* way, or a way at all, remains to be seen.

So the advocated FC00::/8 locally-assigned addresses would be a bit like
site-scope addresses, but with a higher probability of actually being
globally-unique, although that is entirely pointless, and without all
the useful semantics w.r.t. address selection. Great.

> You might also want to check out the document which is documenting the=20
> deprecation (note, it's still a draft version, and likely to evolve a=20
> lot), to learn about some of the problems of the site-locals:
>=20
> http://www.ietf.org/internet-drafts/draft-ietf-ipv6-deprecate-site-loca=
l-00.txt

It's interesting to see the arguments therein. I thought there might
have been some valid ones I wasn't previously aware of, since I'm fairly
new to IPv6. That doesn't really seem to be the case -- all the
arguments could apply just as well to RFC1918 too.

=C2=A72.1 -- people might use _internal_ addresses of one site when they'=
ve
moved to another. Just like trying to talk to RFC1918 internal addresses
when you've moved. Yes it's a vague possibility -- compounded if people
are playing schizodns tricks so that internal addresses actually have
public-looking names -- but in practice it's a failure mode for RFC1918
already, and hence is known and avoided. Site addresses don't work
off-site. Film at 11.

=C2=A72.2 -- internal addresses 'leak'. Not if you apply even a modicum o=
f
clue. Same as RFC1918 in IPv4. You don't let packets with private source
addresses outside your borders, and you don't put them in public DNS.=20

=C2=A72.3 -- routing is hard. Let's go shopping. You have a global intern=
al
network routed over crypto tunnels between multiple sites. And you can't
handle setting up the routing? Yeah, right.

=C2=A72.4 -- site is an illdefined concept. Yes, that's sort of the point.
Its scope is _allowed_ to vary, because it's user-defined. At long as it
doesn't leak, which it doesn't, you don't care whether I happen to use
'site' to mean a single physical location, or my global intranet.=20

=C2=A73 -- development of a better alternative. That would be nice. Nothi=
ng
we've discussed so far really seems 'better' though.

</RANT>

> One possible, conceptually maybe easier way, would be to deploy a singl=
e,
> internal ISATAP domain (so you'd have only _one_ internal IPv6 subnet,
> which would really be just automatic tunnel between all v6 hosts in you=
r
> enterprise), but that would require getting ISATAP in all the kernels a=
nd
> iputils you use first, and IMHO it wouldn't be the same as deployingi r=
eal=20
> IPv6... :-)

Some 6-in-4 method which gives at least a /64 to each IPv4 address is
nicer, since then you get the choice of making each host play for itself
to get optimal routing, or letting them route via a single
tunnel-capable router on each network segment. And it's an orthogonal
issue to the _real_ problem, which is getting optimal IPv6 routing to
the outside world by multi-homing, without the useful 'scope' concept
forcing you to pick the right addresses all the time.

--=20
dwmw2
