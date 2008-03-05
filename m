From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 06/12][NETNS][IPV6] route6 - make route6 per namespace
Date: Wed, 05 Mar 2008 10:33:15 +0100
Message-ID: <47CE68DB.3000207@fr.ibm.com>
References: <20080304210326.169013927@mai.toulouse-stg.fr.ibm.com> <20080304211023.817913201@mai.toulouse-stg.fr.ibm.com> <20080305.080225.41277542.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	benjamin.thery@bull.net
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:28031 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757364AbYCEJgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 04:36:06 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m259a48V334318
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 09:36:04 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m259a4pv1769584
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 09:36:04 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m259a3bA029220
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 09:36:03 GMT
In-Reply-To: <20080305.080225.41277542.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20080304211023.817913201@mai.toulouse-stg.fr.ibm.com> (at=
 Tue, 04 Mar 2008 22:03:32 +0100), Daniel Lezcano <dlezcano@fr.ibm.com>=
 says:
>=20
>> This patch makes the routing engine use the network namespaces
>> to access routing informations:
>> Add a network namespace parameter to ipv6_route_ioctl and=20
>> propagate the network namespace value to all the routing code
>> that have not yet been changed.
>>
>> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
>> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
>> ---
>>  include/net/ip6_route.h |    4 +
>>  net/ipv6/af_inet6.c     |    3 -
>>  net/ipv6/route.c        |   98 ++++++++++++++++++++++++------------=
------------
>>  3 files changed, 54 insertions(+), 51 deletions(-)
>>
> :
>> @@ -2544,6 +2545,7 @@ static void ip6_route_net_exit(struct ne
>>  	proc_net_remove(net, "ipv6_route");
>>  	proc_net_remove(net, "rt6_stats");
>>  #endif
>> +	rt6_ifdown(net, NULL);
>>  }
>> =20
>>  static struct pernet_operations ip6_route_net_ops =3D {
>> @@ -2592,7 +2594,6 @@ fib6_rules_init:
>>  xfrm6_init:
>>  	xfrm6_fini();
>>  out_fib6_init:
>> -	rt6_ifdown(&init_net, NULL);
>>  	fib6_gc_cleanup();
>>  out_kmem_cache:
>>  	kmem_cache_destroy(ip6_dst_ops.kmem_cachep);
>=20
> Please do not change the calling path here.

The calling path is still the same. Instead of having rt6_ifdown called=
=20
before fib6_gc_cleanup, it is the first function called into=20
fib6_gc_cleanup via unregister_pernet_subsys.

This is because we need to call rt6_ifdown when a network namespace=20
exits or when the system shutdown (aka init_net exits).

   -- Daniel



