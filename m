From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH][XFRM] Replace rwlock on xfrm_policy_afinfo with rcu
Date: Wed, 8 Aug 2012 14:44:02 +0800
Message-ID: <50220AB2.5030504@windriver.com>
References: <1344316904-2544-1-git-send-email-Priyanka.Jain@freescale.com> <1344407147.28967.212.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Priyanka Jain <Priyanka.Jain@freescale.com>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45274 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753741Ab2HHGjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 02:39:41 -0400
In-Reply-To: <1344407147.28967.212.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46irst, sorry to jump in.

On 2012=E5=B9=B408=E6=9C=8808=E6=97=A5 14:25, Eric Dumazet wrote:
> On Tue, 2012-08-07 at 10:51 +0530, Priyanka Jain wrote:
>> xfrm_policy_afinfo is read mosly data structure.
>> Write on xfrm_policy_afinfo is done only at the
>> time of configuration.
>> So rwlocks can be safely replaced with RCU.
>>
>> RCUs usage optimizes the performance.
>
>
>>   static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned =
short family)
>> @@ -2530,16 +2535,16 @@ static struct xfrm_policy_afinfo *xfrm_polic=
y_get_afinfo(unsigned short family)
>>   	struct xfrm_policy_afinfo *afinfo;
>>   	if (unlikely(family>=3D NPROTO))
>>   		return NULL;
>> -	read_lock(&xfrm_policy_afinfo_lock);
>> -	afinfo =3D xfrm_policy_afinfo[family];
>> +	rcu_read_lock();
>> +	afinfo =3D rcu_dereference(xfrm_policy_afinfo[family]);
>>   	if (unlikely(!afinfo))
>> -		read_unlock(&xfrm_policy_afinfo_lock);
>> +		rcu_read_unlock();
>
> This makes no sense to me : We cant safely return afinfo here.
>
> Note the current code is buggy as well, this is worrying.
>
> As soon as we exit from xfrm_policy_get_afinfo(), pointer might be
> invalid.
>
Yes, it might be invalid, but all the callers have checked the return
value, thus use it in a sane way.
So I don't follow "Note the current code is buggy as well".

Am I missing something here?


> Really, RCU conversion should be the right moment to spot those bugs =
and
> first fix them (for stable trees)
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--=20

Love each day!
--fan
