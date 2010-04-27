From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Tue, 27 Apr 2010 19:37:52 +0200
Message-ID: <1272389872.2295.405.camel@edumazet-laptop>
References: <4BD6E887.3000804@athenacr.com>
	 <20100427.095108.68126984.davem@davemloft.net>
	 <1272388439.2295.369.camel@edumazet-laptop>
	 <20100427.102038.57469310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bmb@athenacr.com, therbert@google.com, netdev@vger.kernel.org,
	rick.jones2@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:45586 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756225Ab0D0RnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 13:43:12 -0400
Received: by bwz19 with SMTP id 19so3678bwz.21
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 10:43:11 -0700 (PDT)
In-Reply-To: <20100427.102038.57469310.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 avril 2010 =C3=A0 10:20 -0700, David Miller a =C3=A9crit :

>=20
> Indeed, a huge issue, in that we haven't converted the UDP hash over
> to RCU yet :-)
>=20

I am not sure what you mean, UDP hash _is_ RCU converted ;)

> But because of the transient bind nature of UDP there are still a bun=
ch
> of cases that won't even cure.
> --

We might use the ticket spinlock paradigm to let writers go in parallel
and let the user the socket lock

Instead of having the bh_lock_sock() to protect receive_queue *and*
backlog, writers get a unique slot in a table, that 'user' can handle
later.

Or serialize writers (before they try to bh_lock_sock()) with a
dedicated lock, so that user has 50% chances to get the sock lock,
contending with at most one writer.



