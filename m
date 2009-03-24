From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] conntrack: Reduce conntrack count in	nf_conntrack_free()
Date: Tue, 24 Mar 2009 16:27:06 +0100
Message-ID: <49C8FBCA.40402@cosmosbay.com>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se>	 <49C77D71.8090709@trash.net>	 <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se>	 <49C780AD.70704@trash.net>	 <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se>	 <49C7CB9B.1040409@trash.net>	 <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se>	 <49C8A415.1090606@cosmosbay.com>	 <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se>	 <49C8CCF4.5050104@cosmosbay.com> <1237907850.12351.80.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	avorontsov@ru.mvista.com, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: mbizon@freebox.fr, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45372 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760546AbZCXP1o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 11:27:44 -0400
In-Reply-To: <1237907850.12351.80.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maxime Bizon a =E9crit :
> On Tue, 2009-03-24 at 13:07 +0100, Eric Dumazet wrote:
>=20
> Hi Eric,
>=20
>> We use RCU to defer freeing of conntrack structures. In DOS situatio=
n,
>> RCU might accumulate about 10.000 elements per CPU in its internal
>> queues. To get accurate conntrack counts (at the expense of slightly
>> more RAM used), we might consider conntrack counter not taking into
>> account "about to be freed elements, waiting in RCU queues". We thus
>> decrement it in nf_conntrack_free(), not in the RCU callback.
>=20
> Your patch fixes the problem on my board too (embedded mips router
> 250Mhz), thanks.
>=20
> Yet I'm concerned about what you said concerning RAM usage. I have a
> very small amount on memory left on my board (less than 4M), and I tu=
ned
> ip route cache size and nf_conntrack_max to make sure I won't go OOM.
>=20
> With your patch, does it mean 10000 conntrack entries can be allocate=
d
> while nf_conntrack_max is say only 2048 ?

Well... yes, RCU can have this 'interesting' OOM property.

=46or small machines, you really want to lower RCU parameters, because
as you said, we also push route cache entries in RCU queue, my patch
being applied or not (But using call_rcu_bh(), so we have lower latenci=
es
I think)

We are working on a SLAB_DESTROY_BY_RCU implementation so that
conntrack wont use call_rcu() anymore, give us a couple of days :)

Paul, could we have /sys knobs to be able to tune qhimark, blimit & qlo=
wmark ?

Thanks

