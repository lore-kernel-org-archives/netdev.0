From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] tun: orphan an skb on tx
Date: Mon, 2 Feb 2015 09:24:46 +0100
Message-ID: <20150202082446.GR13046@secunet.com>
References: <1422797630.11044.32.camel@infradead.org>
 <20150201.121948.998046471405758397.davem@davemloft.net>
 <1422826183.11044.72.camel@infradead.org>
 <20150201.210716.588479604128207372.davem@davemloft.net>
 <1422862030.11044.86.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <mst@redhat.com>,
	<herbert@gondor.apana.org.au>, <eric.dumazet@gmail.com>,
	<jan.kiszka@siemens.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <qemu-devel@nongnu.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1422862030.11044.86.camel@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 02, 2015 at 07:27:10AM +0000, David Woodhouse wrote:
> On Sun, 2015-02-01 at 21:07 -0800, David Miller wrote:
>=20
> > We might as well have not have implemented the IPSEC stack at all,
> > because as a result of the userland VPN stuff our IPSEC stack is
> > largely unused except by a very narrow group of users.
>=20
> Well, I'd love to make better use of it if I can. I do suspect it mak=
es
> most sense for userspace to continue to manage the probing of UDP
> connectivity, and the fallback to TCP mode =E2=80=94 and I suspect it=
 also makes
> sense to continue to use tun for passing packets up to the VPN client
> when it's using the TCP transport.
>=20
> So the question would be how we handle redirecting the packet flow to
> the optional UDP transport, when the VPN client determines that it's
> available. For the sake of the user setting up firewall and routing
> rules, I do think it's important that it continues to appear to
> userspace as the *same* device for the entire lifetime of the session=
,
> regardless of which transport the packets happen to be using at a giv=
en
> moment in time. It doesn't *have* to be tun, though.=20
>=20
> You don't seem to like my suggestion of somehow pushing down an XFRM
> state to the tun device to direct the packets out there instead of up=
 to
> userspace. Do you have an alternative suggestion... or a specific
> concern that would help me come up with something you like better?

Maybe you want to use a virtual tunnel interface (vti) what we have
already. Everything that is routed through such an interface is
guaranteed to be either encrypted if a matching xfrm state is present
or dropped. Same on the rceive side, everything that is received by
this interface is guaranteed to be IPsec processed. So you can do
a routing based decision about the IPsec processing.

While I'm sure it could handle the ESP in UDP encapsulation, I'm not th=
at
sure about your TCP fallback because this requires a valid xfrm state
to allow packets to pass. Using the same interface for both is probably
not possible.
