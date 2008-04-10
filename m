From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 3/6] IPV4 : use xor rather than multiple ands for route
 compare
Date: Thu, 10 Apr 2008 11:26:57 +0200
Message-ID: <47FDDD61.9020709@cosmosbay.com>
References: <20080401004724.601457403@vyatta.com>	<47F1CD83.8090905@cosmosbay.com>	<20080401130842.579e0ebc@extreme> <20080410.015118.103465510.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.150]:12040 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752508AbYDJJ1H convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 05:27:07 -0400
In-Reply-To: <20080410.015118.103465510.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 1 Apr 2008 13:08:42 -0700
>
>  =20
>> The flow fields are all together, and the other parameters are local=
 variables
>> in registers so that compare should be in one cache line.
>>
>> --- a/net/ipv4/route.c	2008-03-31 17:12:30.000000000 -0700
>> +++ b/net/ipv4/route.c	2008-04-01 13:05:46.000000000 -0700
>> @@ -2079,12 +2079,12 @@ int ip_route_input(struct sk_buff *skb,=20
>>  	rcu_read_lock();
>>  	for (rth =3D rcu_dereference(rt_hash_table[hash].chain); rth;
>>  	     rth =3D rcu_dereference(rth->u.dst.rt_next)) {
>> -		if (rth->fl.fl4_dst =3D=3D daddr &&
>> -		    rth->fl.fl4_src =3D=3D saddr &&
>> -		    rth->fl.iif =3D=3D iif &&
>> -		    rth->fl.oif =3D=3D 0 &&
>> +		if (((rth->fl.fl4_dst ^ daddr) |
>> +		     (rth->fl.fl4_src ^ saddr) |
>> +		     (rth->fl.iif ^ iif) |
>> +		     rth->fl.oif |
>> +		     (rth->fl.fl4_tos ^ tos)) =3D=3D 0 &&
>>  		    rth->fl.mark =3D=3D skb->mark &&
>> -		    rth->fl.fl4_tos =3D=3D tos &&
>>  		    net_eq(dev_net(rth->u.dst.dev), net) &&
>>  		    rth->rt_genid =3D=3D atomic_read(&rt_genid)) {
>>  			dst_use(&rth->u.dst, jiffies);
>>    =20
>
> Eric, any objections to this version?
>  =20
No objections from me, thank you.

Acked-by: Eric Dumazet <dada1@cosmosbay.com>




