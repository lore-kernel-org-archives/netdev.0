From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipip6 - integer underrun when handlince icmpv4 unreachable
 messages
Date: Tue, 9 Dec 2014 14:28:41 +0100
Message-ID: <20141209132841.GL6390@secunet.com>
References: <546A6E04.30603@web.de>
 <20141204085628.GG6390@secunet.com>
 <54808A5C.1050205@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <roque@di.fc.ul.p>,
	<kuznet@ms2.inr.ac.ru>, <r.venning@telstra.com>, <nate@thebog.net>
To: Alexander Wetzel <alexander.wetzel@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33359 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756814AbaLIN2s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 08:28:48 -0500
Content-Disposition: inline
In-Reply-To: <54808A5C.1050205@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 04, 2014 at 05:22:52PM +0100, Alexander Wetzel wrote:
> Hello,
> 
> The patch works for me, thank you very much.
> 
> Rejecting the ipv4 tunel packets with icmp unreachable is producing the
> expected "Destination unreachable: Address unreachable" messages for the
> inside ipv6 client and everything works as expected. Without the call in
> sit.c to skb_reset_transport_header.
> 
> I'll continue to use the patch on my ipv6 tunnel router but I'm sure it
> works as intended.
> 
> 
> On 04.12.2014 09:56, Steffen Klassert wrote:
> > 
> > I think the easiest is to fix it in _decode_session6().
> > Could you please try the patch below?
> > 
> > Subject: [PATCH] xfrm6: Fix transport header offset in _decode_session6.
> > 
> > skb->transport_header might not be valid when we do a reverse
> > decode because the ipv6 tunnel error handlers don't update it
> > to the inner transport header. This leads to a wrong offset
> > calculation and to wrong layer 4 informations. We fix this
> > by using the size of the ipv6 header as the first offset.
> > 
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Thanks for testing, I've applied this to the ipsec tree now.
