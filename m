From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Thu, 15 Apr 2010 10:51:47 +0200
Message-ID: <1271321507.16881.2244.camel@edumazet-laptop>
References: <1271056697.16881.7.camel@edumazet-laptop>
	 <20100414.235256.190096561.davem@davemloft.net>
	 <1271318553.16881.2161.camel@edumazet-laptop>
	 <20100415.012607.15449571.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org,
	nuclearcat@nuclearcat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:52332 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757499Ab0DOIv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 04:51:56 -0400
Received: by bwz25 with SMTP id 25so1209415bwz.28
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 01:51:54 -0700 (PDT)
In-Reply-To: <20100415.012607.15449571.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 01:26 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 15 Apr 2010 10:02:33 +0200
>=20
> > Denys got a crash that we cannot explain yet. He said he has no
> > multiqueue devices, so obviously my patch cant help him.
> >=20
> > But this patch was fixing a real issue, I believe I pointed it twic=
e
> > already...
>=20
> Ok, I thought your patch was specifically meant to fix Denys's bug.
>=20
> The confusion comes from the fact that you mention Denys's crash in
> your commit message:
>=20
> --------------------
> When dev_pick_tx() caches tx queue_index on a socket, we must check
> socket dst_entry matches skb one, or risk a crash later, as reported =
by
> Denys Fedorysychenko, if old packets are in flight during a route
> change, involving devices with different number of queues.
> --------------------
>=20
> Anyways, I studied your patch once more and read the thread discussio=
n
> with Krishna again and your patch looks fine.  I'll apply it to
> net-2.6, thanks!
>=20

In any case, I think there is a fundamental problem with this sk
caching. Because one packet can travel in many stacked devices before
hitting the wire.

(bonding, vlan, ethernet) for example.

Socket cache is meaningfull for one level only...



