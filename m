From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 1/2] qdisc: Allow qdiscs to provide backpressure up
 the stack.
Date: Fri, 27 Aug 2010 17:59:57 +0200
Message-ID: <1282924797.5208.31.camel@edumazet-laptop>
References: <4C774B8F.2030805@candelatech.com>
	 <20100826.223604.48516081.davem@davemloft.net>
	 <4C775411.1000302@candelatech.com>
	 <20100826.231110.260096663.davem@davemloft.net>
	 <4C77D939.2050807@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:47463 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597Ab0H0QAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 12:00:03 -0400
Received: by wwc33 with SMTP id 33so1175568wwc.1
        for <netdev@vger.kernel.org>; Fri, 27 Aug 2010 09:00:01 -0700 (PDT)
In-Reply-To: <4C77D939.2050807@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 27 ao=C3=BBt 2010 =C3=A0 08:26 -0700, Ben Greear a =C3=A9cr=
it :

> For the trivial case, I can just kfree_skb when BUSY is returned, for=
 the
> same overall behaviour as today.  For something like UDP, I might be =
able
> to poke the SKB back into the queue instead of freeing it.

Its not trivial at all. Actually I bet this is not possible.

There is no queue for UDP (apart CORKing of course). There is at most
one frame per socket. Once this frame is ready (uncork), we send it
immediately via ip_push_pending_frames(), a destructive process, no way
it can be rollbacked in case of failure at the end of the chain.

throttling is only done because some frames are queued in qdisc, keepin=
g
memory accounting refs on socket.

Between UDP and qdisc, they are many layers (netfilter, ip
fragmentation, ...), so requeuing skb is not possible at all.

Netfilter wont rollback all its work.


backpressure should be evaluated by another way.



