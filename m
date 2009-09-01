From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: neighbour table RCU
Date: Tue, 01 Sep 2009 08:50:17 +0200
Message-ID: <4A9CC429.5020803@gmail.com>
References: <20090831150453.3437a65c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37888 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785AbZIAGuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 02:50:16 -0400
In-Reply-To: <20090831150453.3437a65c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Looking at the neighbour table, it should be possible to get
> rid of the two reader/writer locks.  The hash table lock is pretty
> amenable to RCU, but the dynamic resizing makes it non-trivial.
> Thinking of using a combination of RCU and sequence counts so that th=
e
> reader would just rescan if resize was in progress.

I am not sure neigh_tbl_lock rwlock should be changed, I did not
see any contention on it.

>=20
> The reader/writer lock on the neighbour entry is more of a problem.
> Probably would be simpler/faster to change it into a spinlock and
> be done with it.
>=20
> The reader/writer lock is also used for the proxy list hash table,
> but that can just be a simple spinlock.
>=20

This is probably is the only thing we want to do at this moment,
halving atomic ops on neigh_resolve_output()

But why neigh_resolve_output() was called so much in the bench
is the question...

