From: David Miller <davem@davemloft.net>
Subject: Re: net-next: broken IP_PKTINFO
Date: Wed, 17 Dec 2008 22:17:19 -0800 (PST)
Message-ID: <20081217.221719.195850752.davem@davemloft.net>
References: <1229513101.3685.57.camel@localhost.localdomain>
	<20081217.193406.102253657.davem@davemloft.net>
	<4949E6BE.9080709@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: markmc@redhat.com, andi@firstfloor.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54164
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751125AbYLRGRR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 01:17:17 -0500
In-Reply-To: <4949E6BE.9080709@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 18 Dec 2008 06:59:26 +0100

> David Miller a =E9crit :
> > Eric, we'll need to rever this change I think.
>=20
> I am afraid we have to revert it, yes.

Done.

> About ip_cmsg_recv_pktinfo() :
>=20
> iif can be found in skb->iif instead of rt->rt_iif, but I am not sure
> about rt_spec_dst : Shouldnt we find it in ip_hdr(skb)->saddr ?
> =20
> Do you know if we really need rtable in ip_cmsg_recv_pktinfo() ?

I think we might, as these are routing attributes, which not
necessarily match up with the values found in the SKB.

In fact, I do remember that "specific destination" has a very
exact definition in the routing RFCs and it has to do with the
matched route.

Conversely, in what situations (other than with the reverted patch
applied, hehe) would the route not be attached here?
