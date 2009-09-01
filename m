From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: neighbour table RCU
Date: Tue, 1 Sep 2009 09:23:17 -0700
Message-ID: <20090901092317.0fe6c9f2@nehalam>
References: <20090831150453.3437a65c@nehalam>
	<4A9CC429.5020803@gmail.com>
	<200909011855.34175.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40007 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751733AbZIAQX3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 12:23:29 -0400
In-Reply-To: <200909011855.34175.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Sep 2009 18:55:34 +0300
Octavian Purdila <opurdila@ixiacom.com> wrote:

> On Tuesday 01 September 2009 09:50:17 Eric Dumazet wrote:
> > Stephen Hemminger a =C3=A9crit :
> > > Looking at the neighbour table, it should be possible to get
> > > rid of the two reader/writer locks.  The hash table lock is prett=
y
> > > amenable to RCU, but the dynamic resizing makes it non-trivial.
> > > Thinking of using a combination of RCU and sequence counts so tha=
t the
> > > reader would just rescan if resize was in progress.
> >
> > I am not sure neigh_tbl_lock rwlock should be changed, I did not
> > see any contention on it.
> >
>=20
> Speaking about neighbour optimizations, here is a RFC patch which mak=
es the=20
> tables double linked, for constant time deletion. It has given us a s=
ignificant=20
> performance improvement - in less then usual setups though, with lots=
 of=20
> neighbours.
>=20
> Would something like this be acceptable for upstream? (pardon the p4 =
diff dump=20
> :) - but I think it will give a rough idea, if acceptable will clean =
it up and=20
> properly submit it)
>=20
> BTW, would switching to list_head be better?

Use hlist for the neighbour table. It has the right properties
and makes future RCU easier.
