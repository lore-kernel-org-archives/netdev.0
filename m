From: Patrick McHardy <kaber@trash.net>
Subject: Re: bad nat connection tracking performance with ip_gre
Date: Tue, 18 Aug 2009 12:38:39 +0200
Message-ID: <4A8A84AF.7050901@trash.net>
References: <4A8A7F14.3010103@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4A8A7F14.3010103@iki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Timo Ter=E4s wrote:
> Hi,
>=20
> I noticed (in relation to my nbma gre multicast testing) that
> the nat connection tracking code does not cache flows for
> locally originating traffic that is routed to gre tunnel
> (forwarded traffic is ok).
>=20
> I basically have a router box with nbma gre tunnel. It gets
> 10/8 traffic. And is routed to internet interface. An ipsec
> xfrm is applied.
>=20
> Now, if the router box is forwarding traffic from some
> physical interface, everything works as expected.
>=20
> However, if a local process on the router box is sending
> packets that go to gre tunnel, each packet causes a new
> lookup on nat table OUTPUT chain. This is easily verified
> by doing flood ping on router box on private IP and the
> counters on nat table OUTPUT chain default policy start
> to get incremented wildly.
>=20
> I tried to oprofile this and it says most of the time is
> spent in ipt_do_table(). I would suppose that the place
> where netfilter hook is called is
> ip_gre.c:ipgre_tunnel_xmit() when it invokes macro
> IPTUNNEL_XMIT() calling ip_local_out().
>=20
> Monitoring the connection tracking stats, it looks like
> all packets are reusing the proper connection tracking
> cache entry. But somehow the nat target still gets
> called for the locally originating packets to gre.
>=20
> Any ideas how to fix this?

Please use the TRACE target in raw/OUTPUT to trace the flow of
packets through the netfilter hooks:

modprobe ipt_LOG
iptables -t raw -A OUTPUT -j TRACE
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
