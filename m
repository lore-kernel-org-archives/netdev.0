From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 1/1] net_sched fix: reclassification needs to
 consider ether protocol changes
Date: Wed, 17 Feb 2016 06:19:59 -0500
Message-ID: <56C4575F.5080609@mojatatu.com>
References: <1455626225-16382-1-git-send-email-jhs@emojatatu.com>
 <56C33E58.9090007@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:35199 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161157AbcBQLUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 06:20:01 -0500
Received: by mail-io0-f180.google.com with SMTP id g203so33239791iof.2
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 03:20:01 -0800 (PST)
In-Reply-To: <56C33E58.9090007@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-16 10:20 AM, Daniel Borkmann wrote:
> On 02/16/2016 01:37 PM, Jamal Hadi Salim wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> actions could change the etherproto in particular with ethernet
>> tunnelled data. Typically such actions, after peeling the outer header,
>> will ask for the packet to be  reclassified. We then need to restart
>> the classification with the new proto header.
>>
>> Example setup used to catch this:
>> sudo tc qdisc add dev $ETH ingress
>> sudo $TC filter add dev $ETH parent ffff: pref 1 protocol 802.1Q \
>> u32 match u32 0 0 flowid 1:1 \
>> action vlan pop reclassify
>>
>> Fixes: 3b3ae880266d ("net: sched: consolidate tc_classify{,_compat}")
>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>> ---
>>   net/sched/sch_api.c | 7 ++++---
>>   1 file changed, 4 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
>> index b5c2cf2..22ab634 100644
>> --- a/net/sched/sch_api.c
>> +++ b/net/sched/sch_api.c
>> @@ -1818,13 +1818,14 @@ done:
>>   int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>>           struct tcf_result *res, bool compat_mode)
>>   {
>> -    __be16 protocol = tc_skb_protocol(skb);
>>   #ifdef CONFIG_NET_CLS_ACT
>> -    const struct tcf_proto *old_tp = tp;
>>       int limit = 0;
>> +#endif
>> +    const struct tcf_proto *old_tp = tp;
>> +    __be16 protocol;
>>
>>   reclassify:
>> -#endif
>> +    protocol = tc_skb_protocol(skb);
>>       for (; tp; tp = rcu_dereference_bh(tp->next)) {
>>           int err;
>>
>
> But, how is that better than the one-liner I suggested to you in
> my earlier mail?
>

Thats how the original code was (and what i tested). I dont have time
to test right now but i will send an update with your suggestion.

cheers,
jamal
