From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Wed, 21 Dec 2011 13:30:05 +0100
Message-ID: <1324470605.2728.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1323177878.2448.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1323264929.23681.178.camel@zakaz.uk.xensource.com>
	 <1323438427.20077.57.camel@zakaz.uk.xensource.com>
	 <20111209.133407.2156473837364120429.davem@davemloft.net>
	 <1324465434.7877.11.camel@zakaz.uk.xensource.com>
	 <1324465724.2728.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324466290.7877.22.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:57566 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328Ab1LUMaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 07:30:09 -0500
Received: by vbbfc26 with SMTP id fc26so5734005vbb.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 04:30:08 -0800 (PST)
In-Reply-To: <1324466290.7877.22.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 11:18 +0000, Ian Campbell a =C3=
=A9crit :

>=20
> An order 1 allocation is in multiples of PAGE_SIZE, isn't it, even
> though they happen to be contiguous?

Really an order-1 allocation allocates one page, a compound one.

>=20
> Or are you considering the possibility of kmalloc returning a super p=
age
> of some description? Isn't that to some extent transparent to the cal=
ler
> who (assuming PAGE_SIZE 4096) doesn't know if kmalloc(16384) returned
> 4*4096 contiguous pages or 1*16384 page?
>=20

Its a part of a _single_ page, or the total of it.

Its mandatory, or else many drivers would break their DMA handling.

> Anyway I take your underlying point that 2*PAGE_SIZE is no kind of li=
mit
> on the size of the linear region.
>=20

Sure, since net/unix/af_unix.c can happily allocate huge linear skbs, i=
f
memory is not too fragmented of course...

(The stream unix socket limit their skbs to SKB_MAX_ALLOC (up to 4
pages), but datagram ones have no limit)
