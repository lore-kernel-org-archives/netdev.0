From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: add additional lock to qdisc to increase
 enqueue/dequeue fairness
Date: Tue, 23 Mar 2010 23:13:00 +0100
Message-ID: <1269382380.2915.40.camel@edumazet-laptop>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
	 <1269377667.2915.25.camel@edumazet-laptop>
	 <20100323.144512.140757007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:49102 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711Ab0CWWNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 18:13:04 -0400
Received: by bwz1 with SMTP id 1so2327832bwz.21
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 15:13:03 -0700 (PDT)
In-Reply-To: <20100323.144512.140757007.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 mars 2010 =C3=A0 14:45 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 23 Mar 2010 21:54:27 +0100
>=20
> > Quite frankly, the real problem in this case is not the reduced
> > throughput, but fact that one cpu can stay a long time doing the xm=
its
> > to device, of skb queued by other cpus. This can hurt latencies a l=
ot,
> > for real time threads for example...
> >=20
> > I wonder if ticket spinlocks are not the problem. Maybe we want a
> > variant of spinlocks, so that cpu doing transmits can get the lock
> > before other cpus...
>=20
> I want to note that things operate the way they do now
> intentionally.
>=20
> Herbert Xu and Jamal Hadi Salim were active in this area
> about 4 years ago.

Yes, but ticket spinlocks were added after their work (in 2008 - 2.6.25
if I remember well) and change things.

We want cpu owning __QDISC_STATE_RUNNING being able to re-get the lock
as fast as possible. Alexander results can show the possible speedup.



