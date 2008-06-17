From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Killing sk->sk_callback_lock (was Re: [PATCH] net/core/sock.c
 remove extra wakeup)
Date: Tue, 17 Jun 2008 05:09:55 +0200
Message-ID: <48572B03.1050602@cosmosbay.com>
References: <484F43A3020000760003F543@lucius.provo.novell.com> <4856C12F020000C700039679@lucius.provo.novell.com> <4856C12F020000C700039679@lucius.provo.novell.com> <20080617025612.GA8191@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick Mullaney <pmullaney@novell.com>, davem@davemloft.net,
	Gregory Haskins <GHaskins@novell.com>, chuck.lever@oracle.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.111]:6447 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753414AbYFQDKD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 23:10:03 -0400
In-Reply-To: <20080617025612.GA8191@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu a =E9crit :
> On Mon, Jun 16, 2008 at 07:38:23PM -0600, Patrick Mullaney wrote:
>> I don't follow but I wasn't part of the IRC discussion. :-) Please
>> send me a note out of band if you would like to discuss again on IRC=
=2E
>> I agree that the sk_callback_lock may be significant overhead
>> (although lockstat is not showing it to be highly contended).
>=20
> Lock contention doesn't matter! The worst problem with read-write
> locks is cache-line bouncing.  That is, read locks will grab cache
> lines from other read locks thus causing performance to go down
> the drain if read locks are common (which is the only scenario
> where you use read-write locks anyway).  Moral of the story is
> that read-write locks are bad.
>=20
> Cheers,

Yes, read-write locks are bad (not the concept itself, only their
implementation) but alternatives are complex to setup and maintain.

ipt_do_table() for example hits a read-write lock for every packet
handled on a chain. This is why firewalling sucks even with few rules.





