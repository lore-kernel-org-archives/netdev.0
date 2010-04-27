From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Tue, 27 Apr 2010 16:30:59 +0200
Message-ID: <1272378659.2295.193.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004222249400.27016@pokey.mtv.corp.google.com>
	 <1272302434.19143.76.camel@edumazet-laptop>
	 <q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com>
	 <20100426.110432.104061817.davem@davemloft.net>
	 <4BD6E887.3000804@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, rick.jones2@hp.com
To: Brian Bloniarz <bmb@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:51358 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497Ab0D0ObI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 10:31:08 -0400
Received: by bwz19 with SMTP id 19so131862bwz.21
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 07:31:05 -0700 (PDT)
In-Reply-To: <4BD6E887.3000804@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 avril 2010 =C3=A0 09:37 -0400, Brian Bloniarz a =C3=A9crit =
:
> David Miller wrote:
> > How damn hard is it to add two 16-bit ports to the hash regardless =
of
> > protocol?
> >  =20
> Come to think of it, for UDP the hash must ignore
> the srcport and srcaddr, because a single bound
> socket is going to wildcard both those fields.
>=20

=46or your application maybe ;)

Here, I have thousand of RTP flows to big mediagateways, so the
(srcaddr, dstaddr) is shared by all these flows.

Tom Herbert also wants a threaded DNS server.

=46or UDP, we could have a bitmap (system level ?) to say if a particul=
ar
destination port wants multi-cpu (RPS) spreading or not, even if the NI=
C
decided to use a single queue to submit frames to the host (ie mask the
src_addr and src_port). In this case, RFS on non conected UDP sockets
could be activated as well.

Or just a global sysctl to be able to mask the src_addr and/or src_port
in our software rxhash.




> So the best we can hope for is for the hash to
> include destport and destaddr? From looking at
> my BCM5709's multiq behavior, I think broadcom's
> hash includes the destaddr but not the destport.


Toepliz hash for UDP is a hash(src_addr, dst_addr)

Both src port and dst port are ignored.


