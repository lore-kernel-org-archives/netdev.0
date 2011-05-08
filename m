From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sun, 8 May 2011 05:32:42 -0700
Message-ID: <20110508123242.GI2641@linux.vnet.ibm.com>
References: <891B02256A0667292521A4BF@Ximines.local>
 <1304770926.2821.1157.camel@edumazet-laptop>
 <0F4A638C2A523577CDBC295E@Ximines.local>
 <1304785589.3207.5.camel@edumazet-laptop>
 <178E8895FB84C07251538EF7@Ximines.local>
 <1304793174.3207.22.camel@edumazet-laptop>
 <1304793749.3207.26.camel@edumazet-laptop>
 <1304838742.3207.45.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alex Bligh <alex@alex.org.uk>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:57602 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751325Ab1EHMjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2011 08:39:13 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p48CF0hS028141
	for <netdev@vger.kernel.org>; Sun, 8 May 2011 08:15:00 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p48CdBGr482776
	for <netdev@vger.kernel.org>; Sun, 8 May 2011 08:39:12 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p48CdBfH028251
	for <netdev@vger.kernel.org>; Sun, 8 May 2011 08:39:11 -0400
Content-Disposition: inline
In-Reply-To: <1304838742.3207.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 08, 2011 at 09:12:22AM +0200, Eric Dumazet wrote:
> Le samedi 07 mai 2011 =E0 20:42 +0200, Eric Dumazet a =E9crit :
> > Here is my trace here for one device deletion on one 8 core machine
> >=20
> > [  800.447012] synchronize_rcu() in 15787 us
> > [  800.455013] synchronize_rcu() in 7682 us
> > [  800.464019] rcu_barrier() in 8487 us
> >=20
> > Not that bad.

There is always synchronize_rcu_expedited() if you need lower latency
and can tolerate a bit higher CPU overhead.

							Thanx, Paul

> > $ grep RCU .config
> > # RCU Subsystem
> > CONFIG_TREE_RCU=3Dy
> > # CONFIG_PREEMPT_RCU is not set
> > CONFIG_RCU_TRACE=3Dy
> > CONFIG_RCU_FANOUT=3D32
> > # CONFIG_RCU_FANOUT_EXACT is not set
> > # CONFIG_RCU_FAST_NO_HZ is not set
> > CONFIG_TREE_RCU_TRACE=3Dy
> >=20
>=20
> By the way, if I change HZ from 1000 to 100 I now have ten times slow=
er
> result :
>=20
> # ip link add link eth0 eth0.103 type vlan id 103
> # time ip link del eth0.103
>=20
> real	0m0.430s
> user	0m0.000s
> sys	0m0.000s
>=20
> So all this is related to your HZ value, even in a CONFIG_NO_HZ=3Dy
> kernel. Alex, I guess you have HZ=3D250 ?
>=20
> # uname -a
> Linux svivoipvnx021 2.6.39-rc6-00214-g5511a34-dirty #574 SMP Sun May =
8
> 08:44:14 CEST 2011 x86_64 x86_64 x86_64 GNU/Linux
> # cat /proc/cmdline
>=20
> I enabled CONFIG_RCU_FAST_NO_HZ and got worse results (but not
> alsways... its very variable)
>=20
> # time ip link del eth0.103
>=20
> real	0m0.544s
> user	0m0.000s
> sys	0m0.000s
>=20
>=20
> # time ip link del eth0.103
>=20
> real	0m0.414s
> user	0m0.000s
> sys	0m0.000s
>=20
>=20
