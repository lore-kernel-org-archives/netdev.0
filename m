From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Sat, 24 Oct 2009 10:49:55 +0200
Message-ID: <4AE2BFB3.3060407@gmail.com>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org> <200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com> <20091023211338.GA6145@linux.vnet.ibm.com> <4AE28429.6040608@gmail.com> <20091024054943.GA6638@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org,
	Cosmin Ratiu <cratiu@ixiacom.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48887 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218AbZJXIuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 04:50:10 -0400
In-Reply-To: <20091024054943.GA6638@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney a =E9crit :
> On Sat, Oct 24, 2009 at 06:35:53AM +0200, Eric Dumazet wrote:
>=20
>> Maybe we could call it once only, if we had to call 1 times
>> the jiffie delay ?
>=20
> This could be a very useful approach!
>=20
> However, please keep in mind that although synchronize_rcu_expedited(=
)
> forces a grace period, it does nothing to speed the invocation of oth=
er
> RCU callbacks.  In short, synchronize_rcu_expedited() is a faster ver=
sion
> of synchronize_rcu(), but doesn't necessarily help other synchronize_=
rcu()
> or call_rcu() invocations.
>=20
> The reason I point this out is that it looks to me that the code belo=
w is
> waiting for some other task which is in turn waiting on a grace perio=
d.
> But I don't know this code, so could easily be confused.
>=20

Normally, we need a synchronize_rcu() calls, but I feel its bit more th=
an really
needed here.

On my dev machine, a synchronize_rcu() lasts between 2 an 12 ms


messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.580259] synchr=
onize_net() 4045596 ns
messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.588262] synchr=
onize_net() 7769327 ns
messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.625014] synchr=
onize_net() 4772052 ns
messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.633008] synchr=
onize_net() 7773896 ns
messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.669260] synchr=
onize_net() 3958141 ns
messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.677259] synchr=
onize_net() 7755817 ns
messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.712011] synchr=
onize_net() 2502544 ns
messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.720011] synchr=
onize_net() 7767748 ns
messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.754259] synchr=
onize_net() 2087946 ns
messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.762258] synchr=
onize_net() 7738054 ns
messages:Oct 21 19:13:14 svivoipvnx001-00 kernel: [ 2515.796011] synchr=
onize_net() 3392760 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.808025] synchr=
onize_net() 11814619 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.848010] synchr=
onize_net() 8970220 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.856015] synchr=
onize_net() 7800782 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.893008] synchr=
onize_net() 6650174 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.897012] synchr=
onize_net() 3744808 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.940202] synchr=
onize_net() 8354366 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.952137] synchr=
onize_net() 11693215 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.985010] synchr=
onize_net() 2355970 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2515.989009] synchr=
onize_net() 3771419 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.028137] synchr=
onize_net() 7661195 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.036152] synchr=
onize_net() 7800056 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.083135] synchr=
onize_net() 6774026 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.089145] synchr=
onize_net() 5727189 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.130385] synchr=
onize_net() 10133932 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.134399] synchr=
onize_net() 3773058 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.170136] synchr=
onize_net() 4479194 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.178138] synchr=
onize_net() 7710466 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.217198] synchr=
onize_net() 4323437 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.226206] synchr=
onize_net() 8723108 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.268013] synchr=
onize_net() 6221155 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.280007] synchr=
onize_net() 11719297 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.324008] synchr=
onize_net() 11654511 ns
messages:Oct 21 19:13:15 svivoipvnx001-00 kernel: [ 2516.332009] synchr=
onize_net() 7744182 ns

