From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH] IPv6: (5/5) Allow IPv6 tunnels without own IPv6 address
Date: Mon, 1 Sep 2003 11:18:30 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309010931420.27694-100000@rhea.tcs.hut.fi>
References: <20030901.112409.61391981.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Cc: davem@redhat.com, <usagi-core@linux-ipv6.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030901.112409.61391981.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 1 Sep 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> In article <Pine.LNX.4.44.0309010257390.26242-200000@rhea.tcs.hut.fi> (at Mon, 1 Sep 2003 03:11:58 +0300 (EEST)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:
>
> > unless (link-local) protocols like DHCPv6 or MLD are run over the virtual
> > link formed by IPv6 tunnels, the net_devices representing the tunnels
> > don't necessarily need to have an IPv6 address configured specifically to
> > them.
>
> Wrong. All interfaces have a link-local address. (RFC2462)

Unfortunately the IPv6 tunneling spec (RFC2473) is broken on this point :(
I should probably raise this issue on the IETF ipv6 WG mailing list.

The first problem is, that the way to generate the interface-identifier
isn't currently specified in the tunnel spec.

The IPv6 over PPP spec (RFC2472) section 4.1 has some ideas:

1) if available, reuse any IEEE EUI-48 or EUI-64 identifiers on the node
2) use link-layer addresses, machine serial numbers, et cetera
3) if none of these can be found, use random bits

The second problem is, that this method alone doesn't yet guarantee
unique identifiers to the two tunnel endpoints.

In RFC2472 the IPv6 Control Protocol negotiates the identifiers between
the two peers beforehand, but unfortunately we don't have a similar
protocol in RFC2473.

Like the other tunnels (ipip, ip_gre, sit) ip6_tunnel is fundamentally a
IFF_NOARP device so you can't even use DAD to detect a duplicate address
on the virtual link. (Besides, the link doesn't even exist before both
devices have been brought up on the two separate nodes.)

This is something for the ipv6 WG to think about, I guess.

In the mean time, do we accept the in theory 1/2^64 (in practice of course
bigger) chance of duplicate addresses occurring on the link?

If yes, then I could (probably still later today) send a patch where the
interface-identifiers for the IPv6 tunnels are generated like in the IPv6
over PPP case above.

Regards,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
