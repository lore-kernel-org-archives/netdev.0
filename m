From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: neighbour table RCU
Date: Tue, 1 Sep 2009 19:56:45 +0300
Message-ID: <200909011956.45811.opurdila@ixiacom.com>
References: <20090831150453.3437a65c@nehalam> <200909011855.34175.opurdila@ixiacom.com> <4A9D486D.4020408@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:5511 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755081AbZIAQ7F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 12:59:05 -0400
In-Reply-To: <4A9D486D.4020408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 01 September 2009 19:14:37 Eric Dumazet wrote:
> Octavian Purdila a =E9crit :
> > On Tuesday 01 September 2009 09:50:17 Eric Dumazet wrote:
> >> Stephen Hemminger a =E9crit :
> >>> Looking at the neighbour table, it should be possible to get
> >>> rid of the two reader/writer locks.  The hash table lock is prett=
y
> >>> amenable to RCU, but the dynamic resizing makes it non-trivial.
> >>> Thinking of using a combination of RCU and sequence counts so tha=
t the
> >>> reader would just rescan if resize was in progress.
> >>
> >> I am not sure neigh_tbl_lock rwlock should be changed, I did not
> >> see any contention on it.
> >
> > Speaking about neighbour optimizations, here is a RFC patch which m=
akes
> > the tables double linked, for constant time deletion. It has given =
us a
> > significant performance improvement - in less then usual setups tho=
ugh,
> > with lots of neighbours.
>
> How many "struct neigh_parms" do you have in your setups, and
> what is the frequency of neigh_parms_release() calls ???
>

Each L3 interface part (at least for IPv4/IPv6 and I see DecNet as well=
) has a=20
neigh_parms associated. And we use up to 128K interfaces in certain tes=
ts=20
scenarios ;)

In our case the interfaces are created/destroyed dynamically, so when u=
sing a=20
large number of interfaces the test cleanup takes forever without this =
(and=20
other) patch(es).

Thanks,
tavi
