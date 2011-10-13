From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: more accurate skb truesize
Date: Thu, 13 Oct 2011 22:51:55 +0200
Message-ID: <1318539115.2533.12.camel@edumazet-laptop>
References: <1318519581.2393.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111013203352.GA5707@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andi Kleen <ak@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35745 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335Ab1JMUv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 16:51:59 -0400
Received: by wyg34 with SMTP id 34so2335750wyg.19
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 13:51:58 -0700 (PDT)
In-Reply-To: <20111013203352.GA5707@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 octobre 2011 =C3=A0 13:33 -0700, Andi Kleen a =C3=A9crit :
> On Thu, Oct 13, 2011 at 05:26:21PM +0200, Eric Dumazet wrote:
> > skb truesize currently accounts for sk_buff struct and part of skb =
head.
> >=20
> > Considering that skb_shared_info is larger than sk_buff, its time t=
o
> > take it into account for better memory accounting.
> >=20
> > This patch introduces SKB_TRUESIZE(X) macro to centralize various
> > assumptions into a single place.
>=20
> It's still quite inaccurate, especially for the kmalloced data area i=
f it's not
> paged. It would be better to ask slab how much memory was really=20
> allocated. But at least this could be done more easily now with the n=
ew=20
> macro, so it's definitely a step in the right direction.

Note : in skb_alloc() function, SKB_TRUESIZE(size) delivers the exact
value : I do the ksize(data) call to ask how many byte kmalloc()
provided me.

So skb->truesize is quite accurate (unless KMEMCHECK or other debug
stuff is used of course)

=46or the SKB_TRUESIZE() macro, we dont want to do a dummy call to
kmalloc()/kfree(), since its basically used to roughly set a queue
limit.

Thanks !
