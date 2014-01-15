From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv2 net-next 3/4] flowcache: Fixup flow cache part in xfrm
 policy
Date: Wed, 15 Jan 2014 15:19:40 +0800
Message-ID: <52D6368C.4060005@windriver.com>
References: <1389663588-29678-1-git-send-email-fan.du@windriver.com> <1389663588-29678-4-git-send-email-fan.du@windriver.com> <20140114185907.GB1971@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Sabrina Dubroca <sd@queasysnail.net>,
	=?UTF-8?B?546L6IGq?= <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:64604 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbaAOHTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 02:19:53 -0500
In-Reply-To: <20140114185907.GB1971@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2014=E5=B9=B401=E6=9C=8815=E6=97=A5 02:59, Sabrina Dubroca wrote:
> 2014-01-14, 09:39:46 +0800, Fan Du wrote:
>> Bump flow cache genid, and flush flow cache should also be made
>> in per net style.
>>
>> Signed-off-by: Fan Du<fan.du@windriver.com>
>> ---
>>   net/xfrm/xfrm_policy.c |    7 ++++---
>>   1 file changed, 4 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
>> index e205c4b..d39c90f 100644
>> --- a/net/xfrm/xfrm_policy.c
>> +++ b/net/xfrm/xfrm_policy.c
>> @@ -661,7 +661,7 @@ int xfrm_policy_insert(int dir, struct xfrm_poli=
cy *policy, int excl)
>>   		hlist_add_head(&policy->bydst, chain);
>>   	xfrm_pol_hold(policy);
>>   	net->xfrm.policy_count[dir]++;
>> -	atomic_inc(&flow_cache_genid);
>> +	atomic_inc(&net->xfrm.flow_cache_genid);
>>
>>   	/* After previous checking, family can either be AF_INET or AF_IN=
ET6 */
>>   	if (policy->family =3D=3D AF_INET)
>> @@ -2567,14 +2567,14 @@ static void __xfrm_garbage_collect(struct ne=
t *net)
>>
>>   void xfrm_garbage_collect(struct net *net)
>>   {
>> -	flow_cache_flush();
>> +	flow_cache_flush(net);
>>   	__xfrm_garbage_collect(net);
>>   }
>>   EXPORT_SYMBOL(xfrm_garbage_collect);
>>
>>   static void xfrm_garbage_collect_deferred(struct net *net)
>>   {
>> -	flow_cache_flush_deferred();
>> +	flow_cache_flush_deferred(net);
>>   	__xfrm_garbage_collect(net);
>>   }
>>
>> @@ -2947,6 +2947,7 @@ static int __net_init xfrm_net_init(struct net=
 *net)
>>   	spin_lock_init(&net->xfrm.xfrm_policy_sk_bundle_lock);
>>   	mutex_init(&net->xfrm.xfrm_cfg_mutex);
>>
>> +	flow_cache_init(net);
>>   	return 0;
>>
>>   out_sysctl:
>
>
> You didn't address Cong Wang's comments for v1:

Sorry, seems company email server didn't forward below message to me=E3=
=80=82=E3=80=82=E3=80=82
but I saw yours. I'm happy to forge the relevant patches into one singl=
e
patch in next next version :) if Steffen doesn't complain.

>
> 2014-01-13, 11:42:47 -0800, Cong Wang wrote:
>> On Sun, Jan 12, 2014 at 11:49 PM, Fan Du<fan.du@windriver.com>  wrot=
e:
>>>   void xfrm_garbage_collect(struct net *net)
>>>   {
>>> -       flow_cache_flush();
>>> +       flow_cache_flush(net);
>>>          __xfrm_garbage_collect(net);
>>>   }
>>>   EXPORT_SYMBOL(xfrm_garbage_collect);
>>>
>>>   static void xfrm_garbage_collect_deferred(struct net *net)
>>>   {
>>> -       flow_cache_flush_deferred();
>>> +       flow_cache_flush_deferred(net);
>>>          __xfrm_garbage_collect(net);
>>>   }
>>>
>>
>> You changed the prototypes of flow_cache_flush*() in the previous
>> patch, so, here you break bisect. They have to be in one commit.
>
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
