From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] IPSEC failover and replay detection sequence numbers
Date: 29 Oct 2004 11:01:35 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1099062095.1023.14.camel@jzny.localdomain>
References: <1099045435.2888.47.camel@nienna.balabit>
	 <1099054721.1027.118.camel@jzny.localdomain>
	 <1099056277.2888.71.camel@nienna.balabit>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, ipsec-tools-devel@lists.sourceforge.net,
        vpn-failover@lists.balabit.hu
Return-path: <netdev-bounce@oss.sgi.com>
To: KOVACS Krisztian <hidden@balabit.hu>
In-Reply-To: <1099056277.2888.71.camel@nienna.balabit>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-10-29 at 09:24, KOVACS Krisztian wrote:
>   Hi,
>=20
> 2004-10-29, p keltez=E9ssel 14:58-kor jamal ezt =EDrta:
> > To take a rough estimate of 5K users, how often do you think
> > these replay messages will be generated?
> >=20
> > Is there a (clever) way to avoid transporting them and still achieve
> > an accurate failover?
>=20
>   There is, provided that you do not want replay detection to work afte=
r
> a failover. The more often you would send sequence number updates the
> smaller the possible replay window will be. If you sacrifice scalabilit=
y
> you get more accurate replay detection.
>=20

ok. It should still get better in a short period of time though.
Moral in my point is i hope you make it an optional feature.

>   To play with numbers: say that you have 5K users, so let's suppose
> there are at most 20K IPSEC SAs. If you decide to send an update per
> second, that would mean 20K updates/second. If each update message is 2=
0
> bytes long, that means that on Ethernet you can transmit all of them in
> about 280 packets.=20

Are you batching?=20
In my count: Assuming 20bytes is in a packet of its own - your numbers
translate to 20Kpps which is > 10Mbps ;->=20
I suppose SAs will be much lower rate. So you need probably a dedicated
100Mbps just for the syncing. I would also say SA updates should be
prioritized over replay messages.

> That's not too much. (I suppose the 20K pfkey
> messages would be much more of a problem, though...)

Why not use the netlink events (you mention pfkey).

Batching them with a timeout should help.

cheers,
jamal
