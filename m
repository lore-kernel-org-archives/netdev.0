From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Sat, 24 Oct 2009 16:24:27 +0200
Message-ID: <4AE30E1B.5080008@gmail.com>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org> <200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com> <20091023211338.GA6145@linux.vnet.ibm.com> <4AE28429.6040608@gmail.com> <20091024054943.GA6638@linux.vnet.ibm.com> <4AE2BFB3.3060407@gmail.com> <20091024135214.GB6638@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org,
	Cosmin Ratiu <cratiu@ixiacom.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41393 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367AbZJXOYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 10:24:31 -0400
In-Reply-To: <20091024135214.GB6638@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney a =E9crit :
> On Sat, Oct 24, 2009 at 10:49:55AM +0200, Eric Dumazet wrote:
>>
>> On my dev machine, a synchronize_rcu() lasts between 2 an 12 ms
>=20
> That sounds like the right range, depending on what else is happening
> on the machine at the time.
>=20
> The synchronize_rcu_expedited() primitive would run in the 10s-100s
> of microseconds.  It involves a pair of wakeups and a pair of context
> switches on each CPU.
>=20

Hmm... I'll make some experiments Monday and post results, but it seems=
 very
promising.

Do you think the "on_each_cpu(flush_backlog, dev, 1);"
we perform right before calling netdev_wait_allrefs() could be changed
somehow to speedup rcu callbacks ? Maybe we ould avoid sending IPI twic=
e to
cpus ?

Thanks

