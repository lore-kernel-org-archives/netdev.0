From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.14 regression: huge latency in read/select on tun
Date: Sun, 20 Apr 2014 09:31:35 -0700
Message-ID: <1398011495.19600.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <533C381E.9090103@odi.ch>
		 <1396456973.3989.41.camel@edumazet-glaptop2.roam.corp.google.com>
		 <533D133A.3090008@odi.ch>
		 <1396531176.12330.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1396533026.12330.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5352D8FF.6070305@odi.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gerben@daybyday.nl, Vlad Yasevich <vyasevic@redhat.com>
To: Ortwin =?ISO-8859-1?Q?Gl=FCck?= <odi@odi.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5352D8FF.6070305@odi.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2014-04-19 at 22:13 +0200, Ortwin Gl=C3=BCck wrote:
> On 03.04.2014 15:50, Eric Dumazet wrote:
> > On Thu, 2014-04-03 at 06:19 -0700, Eric Dumazet wrote:
> >=20
> >> It seems TSO support is broken.
>=20
> I finally found time to bisect this:
>=20
> 53d6471cef17262d3ad1c7ce8982a234244f68ec is the first bad commit
> commit 53d6471cef17262d3ad1c7ce8982a234244f68ec
> Author: Vlad Yasevich <vyasevic@redhat.com>
> Date:   Thu Mar 27 17:26:18 2014 -0400
>=20
>     net: Account for all vlan headers in skb_mac_gso_segment
>=20
>     skb_network_protocol() already accounts for multiple vlan
>     headers that may be present in the skb.  However, skb_mac_gso_seg=
ment()
>     doesn't know anything about it and assumes that skb->mac_len
>     is set correctly to skip all mac headers.  That may not
>     always be the case.  If we are simply forwarding the packet (via
>     bridge or macvtap), all vlan headers may not be accounted for.
>=20
>     A simple solution is to allow skb_network_protocol to return
>     the vlan depth it has calculated.  This way skb_mac_gso_segment
>     will correctly skip all mac headers.
>=20
>     Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> :040000 040000 6066ee76dd70dde2f4675155579e550d29ba0216
> 2196ebff4f9a8b909617dd57beeaa76cbafc8525 M      include
> :040000 040000 20fdfb5efc1ada562b7899d0d58998914b1c2ff1
> c398988f31e1b1b6ee56cb20b1a7becbdf782a17 M      net
> --


Hmm.. probably already solved by commit=20
1e785f48d29a09b6cf96db7b49b6320dada332e1
("net: Start with correct mac_len in skb_network_protocol")
