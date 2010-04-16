From: =?iso-8859-1?Q?Gr=E9goire?= Baron <baronchon@n7mm.org>
Subject: Re: Network protocol (IP,IPv6,...) and TC actions (ACT_CSUM)
Date: Sat, 17 Apr 2010 01:10:50 +0200
Message-ID: <20100416231050.GB18383@n7mm.org>
References: <20100411190845.GA18383@n7mm.org>
 <4BC4AA5B.8040901@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Ceuleers <jan.ceuleers@computer.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from solo.fdn.fr ([80.67.169.19]:36917 "EHLO solo.fdn.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932781Ab0DPX1h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Apr 2010 19:27:37 -0400
Content-Disposition: inline
In-Reply-To: <4BC4AA5B.8040901@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Jan, for the suggestion.

Hi,

I will re-explain my situation.

I started to write a new TC action (ACT_CSUM) in order to be able to
force, specially when ACT_PEDIT is used, the update of common checksums=
:
 * the IPv4 header checksum,
 * the ICMP/IGMP and ICMPv6 checksums,
 * the TCP/UDP checkusms,
 * and why not, more ...

Also, the idea is to support directly IPv4 and IPv6.
The best user interface (via iproute2/tc) could to not ask the final
user to assume a specific network protocol, but let the action
discover it.

With this aim, I would like to know if someone could confirm me the
struct sk_buff .protocol member is the good candidate to discover if I
have an IPv4, an IPv6 packet or any other network protocol, in the skb
got by the TC action code (supporting INGRESS and EGRESS).

Indeed, this struct sk_buff member could contain something like
ETH_P_8021Q, which isn't a network protocol Id ...

I think this kind of content isn't seen by the TC actions, which work
at the network level (even if their filter protocol flag accepts all).
If someone could confirm, thanks in advance.

By the same way, I've wondered if the struct sk_buff .len member could
be used to avoid to "discover" the network packet length in the TC
action code, especially in the case of IPv6 packets (and jumbogram ;-).
But, I think not, because it could be not the case in INGRESS TC action
execution, in my point of view, because the packet wasn't delivered to
the network protocol yet. Is my analysis right?

Thanks again for your help.

Best Regards,

Gr=E9goire Baron

On Tue, Apr 13, 2010 at 07:31:07PM +0200, Jan Ceuleers wrote:
> Gr=E9goire Baron wrote:
> > As this .protocol member seems to be used at different moments when=
 a
> > packet is received, forwared or sent, and could contain something l=
ike
> > ETH_P_8021Q which isn't a network protocol Id, can we say the struc=
t
> > sk_buff .protocol member is guaranteed to contain a network protoco=
l Id
> > in the struct sb_buff used in the TC action executions ?
>=20
> Gr=E9goire,
>=20
> I suggest that you ask your question on the netdev mailing list (netd=
ev@vger.kernel.org).
>=20
> Cheers, Jan
