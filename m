From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 18 Nov 2015 21:43:36 +0100
Message-ID: <1447879416.562854.443622857.62708268@webmail.messagingengine.com>
References: <1447819493.22599.137.camel@edumazet-glaptop2.roam.corp.google.com>
 <1447841988.834928.443071345.1AAFF2A9@webmail.messagingengine.com>
 <CAKD1Yr0Gpr6Ex2i1TXEWyETn48P4g5vBvFZ9=_g+Lz_7-PqBDQ@mail.gmail.com>
 <20151118.153508.123902005995190872.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, edumazet@google.com, ek@google.com,
	maze@google.com, dtor@google.com
To: David Miller <davem@davemloft.net>, lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:36503 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933203AbbKRUnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 15:43:37 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id B6C8520327
	for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 15:43:36 -0500 (EST)
In-Reply-To: <20151118.153508.123902005995190872.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 18, 2015, at 21:35, David Miller wrote:
> From: Lorenzo Colitti <lorenzo@google.com>
> Date: Wed, 18 Nov 2015 19:47:21 +0900
> 
> > On Wed, Nov 18, 2015 at 7:19 PM, Hannes Frederic Sowa
> > <hannes@stressinduktion.org> wrote:
> >> I bet there will soon be a timewaitd which handles the not configurable
> >> (David has rejected all those patches so far) timeout of TIME_WAIT
> >> sockets. And I bet it will be used. :/
> > 
> > No, SOCK_DESTROY has no effect on TCP_TIME_WAIT sockets or any other
> > non-full socket.
> > 
> > When called on any socket where sk_fullsock(sk) is false, it returns
> > EOPNOTSUPP because there is nothing to do. Its purpose is to interrupt
> > blocked userspace socket calls, not to release resources.
> 
> +1

Basically my concern is the same one I tried to express in the other
patch about Florian's patch "[PATCH -next] net: tcp: move to timewait
when receiving data post active-close": we could give the socket back
way too early so the quadruple can be reused. If timestamps are not in
use or we are dealing with NAT were we have dozens of synchronized
clocks behind the masquerading device, we could end up in accepting
delayed data. Especially this scenario can come up when the address is
actually not released but someone uses this feature on a server.

Bye,
Hannes
