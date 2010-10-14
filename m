From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: allocate skbs on local node
Date: Thu, 14 Oct 2010 21:59:38 +0200
Message-ID: <1287086378.2659.26.camel@edumazet-laptop>
References: <1286838210.30423.128.camel@edumazet-laptop>
	 <1286839363.30423.130.camel@edumazet-laptop>
	 <1286859925.30423.184.camel@edumazet-laptop>
	 <20101011230322.f0f6dd47.akpm@linux-foundation.org>
	 <AANLkTin8FczYpPvi79w7iuKOZz3uZtYFfTPitAgQFxzD@mail.gmail.com>
	 <20101014122752.21dd4eaf.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Christoph Hellwig <hch@lst.de>,
	Christoph Lameter <cl@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43426 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755202Ab0JNUAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 16:00:01 -0400
Received: by wyb28 with SMTP id 28so2500414wyb.19
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 12:59:59 -0700 (PDT)
In-Reply-To: <20101014122752.21dd4eaf.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 14 octobre 2010 =C3=A0 12:27 -0700, Andrew Morton a =C3=A9crit=
 :

> Can we think of any hardware configuration for which the change would
> be harmful?  Something with really expensive cross-node DMA maybe?
>=20

If such hardware exists (yes it does, but not close my hands...), then
NIC IRQS probably should be handled by cpus close to the device, or it
might be very slow. This has nothing to do with skb allocation layer.

I believe we should not try to correct wrong IRQ affinities with NUMA
games. Network stack will wakeup threads and scheduler will run them on
same cpu, if possible.

If skb stay long enough on socket receive queue, application will need
to fetch again remote numa node when reading socket a few milliseconds
later, because cache will be cold : Total : two cross node transferts
per incoming frame.

The more node distances are big, the more speedup we can expect from
this patch.

Thanks


