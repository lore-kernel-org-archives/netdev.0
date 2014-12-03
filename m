From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH net-next] ipv6: remove useless spin_lock/spin_unlock
Date: Wed, 3 Dec 2014 10:05:19 +0800
Message-ID: <547E6FDF.2040809@cn.fujitsu.com>
References: <547E6832.4070403@cn.fujitsu.com> <1417571879.5303.83.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:34785 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750862AbaLCCIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 21:08:00 -0500
In-Reply-To: <1417571879.5303.83.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/2014 09:57 AM, Eric Dumazet wrote:
> On Wed, 2014-12-03 at 09:32 +0800, Duan Jiong wrote:
>> xchg is atomic, so there is no necessary to use spin_lock/spin_unlock
>> to protect it.
>>
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>> ---
>>  net/ipv6/ipv6_sockglue.c | 2 --
>>  1 file changed, 2 deletions(-)
>>
>> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
>> index e1a9583..92ca907 100644
>> --- a/net/ipv6/ipv6_sockglue.c
>> +++ b/net/ipv6/ipv6_sockglue.c
>> @@ -112,9 +112,7 @@ struct ipv6_txoptions *ipv6_update_options(struct sock *sk,
>>  		}
>>  		opt = xchg(&inet6_sk(sk)->opt, opt);
>>  	} else {
>> -		spin_lock(&sk->sk_dst_lock);
>>  		opt = xchg(&inet6_sk(sk)->opt, opt);
>> -		spin_unlock(&sk->sk_dst_lock);
>>  	}
>>  	sk_dst_reset(sk);
>>  
> 
> Why keeping 2 copies of opt = xchg(&inet6_sk(sk)->opt, opt); then ?
> 

Thanks for you remind, i didn't notice that.
The else statement could be removed, opt = xchg(&inet6_sk(sk)->opt, opt); should be
moved out, and i will send v2.

Thanks,
  Duan

> 
> 
> 
