From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] net: percpu net_device refcount
Date: Sat, 9 Oct 2010 09:58:59 -0700
Message-ID: <20101009165859.GD2544@linux.vnet.ibm.com>
References: <1286471555.2912.291.camel@edumazet-laptop>
 <20101007103051.63b5177c@nehalam>
 <20101008215604.GF2408@linux.vnet.ibm.com>
 <1286605396.2692.10.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:46631 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756617Ab0JIQ7F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Oct 2010 12:59:05 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o99GhY7C029141
	for <netdev@vger.kernel.org>; Sat, 9 Oct 2010 12:43:34 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o99Gx4It407366
	for <netdev@vger.kernel.org>; Sat, 9 Oct 2010 12:59:04 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o99Gx3Pv002712
	for <netdev@vger.kernel.org>; Sat, 9 Oct 2010 12:59:03 -0400
Content-Disposition: inline
In-Reply-To: <1286605396.2692.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 09, 2010 at 08:23:16AM +0200, Eric Dumazet wrote:
> Le vendredi 08 octobre 2010 =E0 14:56 -0700, Paul E. McKenney a =E9cr=
it :
> > On Thu, Oct 07, 2010 at 10:30:51AM -0700, Stephen Hemminger wrote:
> > > On Thu, 07 Oct 2010 19:12:35 +0200
> > > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > >=20
> > > > We tried very hard to remove all possible dev_hold()/dev_put() =
pairs in
> > > > network stack, using RCU conversions.
> > > >=20
> > > > There is still an unavoidable device refcount change for every =
dst we
> > > > create/destroy, and this can slow down some workloads (routers =
or some
> > > > app servers)
> > > >=20
> > > > We can switch to a percpu refcount implementation, now dynamic =
per_cpu
> > > > infrastructure is mature. On a 64 cpus machine, this consumes 2=
56 bytes
> > > > per device.
> > >=20
> > > It makes sense, but what about 256 cores and 1024 Vlans?
> > > That adds up to 4M of memory which is might be noticeable.
> >=20
> > I bet that systems that have 256 cores have >100GB of memory, at wh=
ich
> > point 4MB is way down in the noise.
>=20
> Well, first its 1MB added, and secondly we added percpu stats for vla=
n
> devices, and this consumed 8x more :
>=20
> (struct vlan_rx_stats is 32 bytes per cpu and per vlan
> 32*256*1024  ->  8 Mbytes
>=20
> Some strange machines have many cores sharing a small amount of memor=
y,
> but I am not sure they want to run many net devices ;)

I do have to admit that the rapid growth rate in the data required migh=
t
well be cause for concern.  But only if it continues.  ;-)

							Thanx, Paul
