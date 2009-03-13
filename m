From: David Miller <davem@davemloft.net>
Subject: Re: Multicast packet loss
Date: Fri, 13 Mar 2009 15:38:51 -0700 (PDT)
Message-ID: <20090313.153851.11725991.davem@davemloft.net>
References: <49B4B909.7050002@cosmosbay.com>
	<20090313.145152.121603300.davem@davemloft.net>
	<49BADE87.40407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kchang@athenacr.com, netdev@vger.kernel.org,
	cl@linux-foundation.org, bmb@athenacr.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41501
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754561AbZCMWjF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 18:39:05 -0400
In-Reply-To: <49BADE87.40407@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 13 Mar 2009 23:30:31 +0100

> David Miller a =E9crit :
> >> Also, when an event was queued for later invocation, I also needed=
 to keep
> >> a reference on "struct socket" to make sure it doesnt disappear be=
fore
> >> the invocation. Not all sockets are RCU guarded (we added RCU only=
 for=20
> >> some protocols (TCP, UDP ...). So I found keeping a read_lock
> >> on callback was the easyest thing to do. I now realize we might
> >> overflow preempt_count, so special care is needed.
> >=20
> > You're using this in UDP so... make the rule that you can't use
> > this with a non-RCU-quiescent protocol.
>=20
> UDP/TCP only ? I though many other protocols (not all using RCU) were
> using sock_def_readable() too...

Maybe create a inet_def_readable() just for this purpose :-)
