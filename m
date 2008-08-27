From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Wed, 27 Aug 2008 18:42:05 -0300
Message-ID: <20080827184205.225a1b06@tux>
References: <20080819213417.45133573@tux>
	<Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
	<20080822183224.2d52f16c@tux>
	<20080822.143709.65615512.davem@davemloft.net>
	<20080823111446.06a350a2@tux>
	<Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
	<20080824163843.33b4f890@tux>
	<Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
	<20080826141812.589848a0@tux>
	<Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
	<20080826181731.4581fd2c@tux>
	<Pine.LNX.4.64.0808271236080.1034@wrl-59.cs.helsinki.fi>
	<20080827165142.4bc7b70f@tux>
	<Pine.LNX.4.64.0808272319520.4693@wrl-59.cs.helsinki.fi>
	<20080827175012.580efae1@tux>
	<Pine.LNX.4.64.0808272358230.4759@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0808272358230.4759@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Aug 2008 00:25:31 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Sure, but that still doesn't explain at all why the expected traffic=20
> doesn't show up anywhere (ie., the working mail after nmap resolution=
).=20
> Such a router cannot prevent us tcpdumping both ends. My point is tha=
t we=20
> would always see the packet at least in the sending end's tcpdump. An=
d,=20
> would we have the traffic from the end-point tcpdumps, we could trivi=
ally=20
> figure out what the middlebox did to the traffic.=20

	Ok.

> Agreed, it shouldn't happen. Do you have a static setup for the IPs o=
r is=20
> there dhcp component which could in theory cause some routing table=20

	Static setup. But there were traces of a multipath config I
used before and completely forgot (below).

> alterations, again I find that unlikely but in the meantime I start t=
o run=20
> out of ideas how the client and server can speak with each other with=
out=20
> leaving any traces about it (I hope you really used exactly the tcpdu=
mp=20
> command you told in the mail linking to those stall logs).

	Yes, you can believe me. Anyway, I disabled the eth1 interface.
And there's more! We never had 2 links on this server, although I was
always prepared to use multipath and ip route policy (since the plans
were to have 2 links). I had 2 commands which I suspect maybe could be
messing everything:

#ip rule add from ${link0} lookup 1
#ip route add 0/0 via ${gw0} table 1

#ip rule add from ${link1} lookup 2
#ip route add 0/0 via ${gw1} table 2

	I deleted all of this. I just use this if I had to links from
two ISPs and decided to load balance between them. As it isn't the
case...

> There's some NAT somewhere btw because the client uses 192.168.0.2 as=
=20
> source address but I don't think that currently has some relevance (i=
t=20
> might timeout some connections after an idle period, which is usually
> of configurable length).

	Yes, in my client machine, I'm behind a D-Link 524 router.
Anyway, give me some days, I'll test with these new changes for a week
at least before confirming the problem was solved (and with both frto
and htb enabled).

	If it's really this old Mulitpath misconfiguration, I apologize
for my error and the length discussion. Anyway, it's good to register,
in the case someone do the same error as me.

	Well, let's wait to see if the problem has gone.

	Thank you very much.

--=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
