From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH] net: add additional lock to qdisc to increase
 enqueue/dequeue fairness
Date: Fri, 21 May 2010 08:43:49 -0700
Message-ID: <20100521084349.0d6f8f9a@nehalam>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
	<1269377667.2915.25.camel@edumazet-laptop>
	<20100323.144512.140757007.davem@davemloft.net>
	<1269382380.2915.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42355 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758256Ab0EUPn5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 11:43:57 -0400
In-Reply-To: <1269382380.2915.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Mar 2010 23:13:00 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mardi 23 mars 2010 =E0 14:45 -0700, David Miller a =E9crit :
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Tue, 23 Mar 2010 21:54:27 +0100
> >=20
> > > Quite frankly, the real problem in this case is not the reduced
> > > throughput, but fact that one cpu can stay a long time doing the =
xmits
> > > to device, of skb queued by other cpus. This can hurt latencies a=
 lot,
> > > for real time threads for example...
> > >=20
> > > I wonder if ticket spinlocks are not the problem. Maybe we want a
> > > variant of spinlocks, so that cpu doing transmits can get the loc=
k
> > > before other cpus...
> >=20
> > I want to note that things operate the way they do now
> > intentionally.
> >=20
> > Herbert Xu and Jamal Hadi Salim were active in this area
> > about 4 years ago.
>=20
> Yes, but ticket spinlocks were added after their work (in 2008 - 2.6.=
25
> if I remember well) and change things.
>=20
> We want cpu owning __QDISC_STATE_RUNNING being able to re-get the loc=
k
> as fast as possible. Alexander results can show the possible speedup.

What about having a special function (spin_lock_greedy?) that just igno=
res
the ticket mechanism and always assumes it has right to next ticket.



--=20
