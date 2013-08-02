From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net] xfrm: Delete hold_timer when destroy policy
Date: Fri, 2 Aug 2013 09:22:08 +0800
Message-ID: <51FB09C0.7090807@windriver.com>
References: <1375351716-3265-1-git-send-email-fan.du@windriver.com> <20130801120146.GD25511@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:48424 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753589Ab3HBBUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 21:20:02 -0400
In-Reply-To: <20130801120146.GD25511@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B408=E6=9C=8801=E6=97=A5 20:01, Steffen Klassert wrote:
> On Thu, Aug 01, 2013 at 06:08:36PM +0800, Fan Du wrote:
>> Both policy timer and hold_timer need to be deleted when destroy pol=
icy
>> Bad mood today, maybe I'm wrong about this...
>>
>> Signed-off-by: Fan Du<fan.du@windriver.com>
>> ---
>>   net/xfrm/xfrm_policy.c |    2 +-
>>   1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
>> index d8da6b8..f7078eb 100644
>> --- a/net/xfrm/xfrm_policy.c
>> +++ b/net/xfrm/xfrm_policy.c
>> @@ -308,7 +308,7 @@ void xfrm_policy_destroy(struct xfrm_policy *pol=
icy)
>>   {
>>   	BUG_ON(!policy->walk.dead);
>>
>> -	if (del_timer(&policy->timer))
>> +	if (del_timer(&policy->timer) || del_timer(&policy->polq.hold_time=
r))
>>   		BUG();
>>
>
> The timers should be already deleted when xfrm_policy_destroy() is
> called. This is just to check if that really happened and to
> catch this bug if not. So it's not a bug fix, it just helps to
> catch a potential bug. I'll consider to take this into ipsec-next
> after some testing.
>

On the contrary, please take a look at callers of xfrm_policy_destroy.
Code flow is as below:

   xfrm_policy_alloc() /* setup timer/hold_timer here */ (1)

   /* do something with this policy, insert or something else */

   goto err; /* bail out if bad things happens */

   return ok

err:
   xfrm_policy_destroy() /*So both timers in (1) need to be deleted */

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
