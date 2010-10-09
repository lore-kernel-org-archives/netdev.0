From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: percpu net_device refcount
Date: Sat, 09 Oct 2010 08:23:16 +0200
Message-ID: <1286605396.2692.10.camel@edumazet-laptop>
References: <1286471555.2912.291.camel@edumazet-laptop>
	 <20101007103051.63b5177c@nehalam>
	 <20101008215604.GF2408@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:32849 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376Ab0JIGXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Oct 2010 02:23:37 -0400
Received: by wwj40 with SMTP id 40so1972056wwj.1
        for <netdev@vger.kernel.org>; Fri, 08 Oct 2010 23:23:36 -0700 (PDT)
In-Reply-To: <20101008215604.GF2408@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 08 octobre 2010 =C3=A0 14:56 -0700, Paul E. McKenney a =C3=A9=
crit :
> On Thu, Oct 07, 2010 at 10:30:51AM -0700, Stephen Hemminger wrote:
> > On Thu, 07 Oct 2010 19:12:35 +0200
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >=20
> > > We tried very hard to remove all possible dev_hold()/dev_put() pa=
irs in
> > > network stack, using RCU conversions.
> > >=20
> > > There is still an unavoidable device refcount change for every ds=
t we
> > > create/destroy, and this can slow down some workloads (routers or=
 some
> > > app servers)
> > >=20
> > > We can switch to a percpu refcount implementation, now dynamic pe=
r_cpu
> > > infrastructure is mature. On a 64 cpus machine, this consumes 256=
 bytes
> > > per device.
> >=20
> > It makes sense, but what about 256 cores and 1024 Vlans?
> > That adds up to 4M of memory which is might be noticeable.
>=20
> I bet that systems that have 256 cores have >100GB of memory, at whic=
h
> point 4MB is way down in the noise.

Well, first its 1MB added, and secondly we added percpu stats for vlan
devices, and this consumed 8x more :

(struct vlan_rx_stats is 32 bytes per cpu and per vlan
32*256*1024  ->  8 Mbytes

Some strange machines have many cores sharing a small amount of memory,
but I am not sure they want to run many net devices ;)



