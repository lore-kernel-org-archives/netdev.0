From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFC: MTU for serving NFS on Infiniband
Date: Tue, 24 Aug 2010 22:09:32 +0200
Message-ID: <1282680572.2467.78.camel@edumazet-laptop>
References: <alpine.LNX.2.00.1008230842290.9325@abcyxhiz.aict.ualberta.ca>
	 <20100823080543.319143e3@nehalam>
	 <alpine.WNT.2.00.1008240856170.2000@cluij.ucs.ualberta.ca>
	 <1282672647.2302.15.camel@achroite.uk.solarflarecom.com>
	 <alpine.WNT.2.00.1008241338470.1132@cluij.ucs.ualberta.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Marc Aurele La France <tsi@ualberta.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.WNT.2.00.1008241338470.1132@cluij.ucs.ualberta.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 24 ao=C3=BBt 2010 =C3=A0 13:49 -0600, Marc Aurele La France a =
=C3=A9crit :

>=20
> Any payload has to either fit in the MTU, or has to be broken up into=
=20
> MTU-sized (or less) fragments, come hell or high water.  That this is=
 done=20
> centrally is a good thing.  It is the "(or less)" part that I am work=
ing=20
> towards here.
>=20

Could you post a full stack trace, to help me understand the path from
NFS to ip_append_data ?

I suspect this is UDP transport ?

This reminds me a patch I wrote for IPV6 : We were allocating a huge
(MTU sized) buffer, just to fill few bytes in it...


commit 72e09ad107e78d69ff4d3b97a69f0aad2b77280f
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Sat Jun 5 03:03:30 2010 -0700

    ipv6: avoid high order allocations
   =20
    With mtu=3D9000, mld_newpack() use order-2 GFP_ATOMIC allocations, =
that
    are very unreliable, on machines where PAGE_SIZE=3D4K
   =20
    Limit allocated skbs to be at most one page. (order-0 allocations)
   =20
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
