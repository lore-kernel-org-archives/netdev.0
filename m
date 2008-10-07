From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 07 Oct 2008 11:24:51 +0200
Message-ID: <48EB2AE3.3080200@cosmosbay.com>
References: <20081006185026.GA10383@minyard.local>	 <48EA8197.6080502@cosmosbay.com> <1223367480.26330.7.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: minyard@acm.org, Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	paulmck@linux.vnet.ibm.com
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp27.orange.fr ([80.12.242.94]:54771 "EHLO smtp27.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752617AbYJGJZA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 05:25:00 -0400
In-Reply-To: <1223367480.26330.7.camel@lappy.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra a =E9crit :
> On Mon, 2008-10-06 at 23:22 +0200, Eric Dumazet wrote:
>=20
>> Or just add SLAB_DESTROY_BY_RCU to slab creation in proto_register()
>> for "struct proto udp_prot/udpv6_prot" so that kmem_cache_free()=20
>> done in sk_prot_free() can defer freeing to RCU...
>=20
> Be careful!, SLAB_DESTROY_BY_RCU just means the slab page gets
> RCU-freed, this means that slab object pointers stay pointing to vali=
d
> memory, but it does _NOT_ mean those slab objects themselves remain
> valid.
>=20
> The slab allocator is free to re-use those objects at any time -
> irrespective of the rcu-grace period. Therefore you will have to be a=
ble
> to validate that the object you point to is indeed the object you
> expect, otherwise strange and wonderful things will happen.
>=20
Thanks for this clarification. I guess we really need a rcu head then :=
)



