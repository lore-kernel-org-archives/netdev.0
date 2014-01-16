From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/2] random32: add prandom_u32_lt_N and convert
 "misuses" of reciprocal_divide
Date: Thu, 16 Jan 2014 10:30:37 +0100
Message-ID: <52D7A6BD.3050903@redhat.com>
References: <1389828228-30312-1-git-send-email-dborkman@redhat.com>  <1389828228-30312-2-git-send-email-dborkman@redhat.com> <1389842050.31367.396.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42836 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752280AbaAPJar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 04:30:47 -0500
In-Reply-To: <1389842050.31367.396.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/16/2014 04:14 AM, Eric Dumazet wrote:
> On Thu, 2014-01-16 at 00:23 +0100, Daniel Borkmann wrote:
>
>> @@ -1220,7 +1219,7 @@ static unsigned int fanout_demux_hash(struct packet_fanout *f,
>>   				      struct sk_buff *skb,
>>   				      unsigned int num)
>>   {
>> -	return reciprocal_divide(skb->rxhash, num);
>> +	return (u32)(((u64) skb->rxhash * num) >> 32);
>>   }
>>
>
> This is unfortunate.

Hm, I agree, it would be better to have a function here. It was mostly
for the purpose of the 2nd patch to migrate users since the structure
was introduced, and thus they become incompatible.

> (This reverts one of your patch : f55d112e529386 )
>
> Please add a helper to explain what's going on here, and on many other
> spots we do this computation (as in get_rps_cpu()).
> Few people really understand this.

Indeed, that's why we also thought that we should fix some spots in
the second patch, also with the thought in mind, when upcoming users
have to use a structure to enforce this call combination.

Anyway, we'll wait for some more feedback anyway regarding the 2nd patch
and then respin.

> Or keep reciprocal_divide() as is, and introduce a new set of functions
> for people really wanting the precise divides.

That might also be a possible option, we could consider. Thanks!

>
>
>
