From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: neighbour table RCU
Date: Tue, 1 Sep 2009 08:59:21 -0700
Message-ID: <20090901085921.2c836dac@nehalam>
References: <20090831150453.3437a65c@nehalam>
	<4A9CC429.5020803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38933 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751483AbZIAP7Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 11:59:24 -0400
In-Reply-To: <4A9CC429.5020803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 01 Sep 2009 08:50:17 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > Looking at the neighbour table, it should be possible to get
> > rid of the two reader/writer locks.  The hash table lock is pretty
> > amenable to RCU, but the dynamic resizing makes it non-trivial.
> > Thinking of using a combination of RCU and sequence counts so that =
the
> > reader would just rescan if resize was in progress.
>=20
> I am not sure neigh_tbl_lock rwlock should be changed, I did not
> see any contention on it.
>=20
> >=20
> > The reader/writer lock on the neighbour entry is more of a problem.
> > Probably would be simpler/faster to change it into a spinlock and
> > be done with it.
> >=20
> > The reader/writer lock is also used for the proxy list hash table,
> > but that can just be a simple spinlock.
> >=20
>=20
> This is probably is the only thing we want to do at this moment,
> halving atomic ops on neigh_resolve_output()
>=20
> But why neigh_resolve_output() was called so much in the bench
> is the question...
>=20

Every packet has to have an ARP resolution.

--=20
