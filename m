From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net sched actions: Add support for user
 cookies
Date: Sun, 15 Jan 2017 07:59:31 -0500
Message-ID: <17810e07-c918-1844-4adc-6527dd7ba229@mojatatu.com>
References: <1484430764-30788-1-git-send-email-jhs@emojatatu.com>
 <20170115091127.GA1795@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@mellanox.com,
        paulb@mellanox.com, john.fastabend@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com, hadarh@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36609 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750842AbdAOM7f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 07:59:35 -0500
Received: by mail-it0-f66.google.com with SMTP id o138so9664620ito.3
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 04:59:34 -0800 (PST)
In-Reply-To: <20170115091127.GA1795@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-15 04:11 AM, Jiri Pirko wrote:
> Subject should contain "V2"
>
> Sat, Jan 14, 2017 at 10:52:44PM CET, jhs@mojatatu.com wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> Introduce optional 128-bit action cookie.
>> Like all other cookie schemes in the networking world (eg in protocols
>> like http or existing kernel fib protocol field, etc) the idea is to save
>> user state that when retrieved serves as a correlator. The kernel
>> _should not_ intepret it.  The user can store whatever they wish in the
>> 128 bits.
>>
>> Sample exercise(using two 64bit values to represent the 128 bits):
>
> Looks like you did not update the description.
>

Yikes. Yes - will send v3.

>>

>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
> V1->V2 changelog would ne nice.
>

Will do.

>
>> ---
>> include/net/act_api.h        |  1 +
>> include/uapi/linux/pkt_cls.h | 11 +++++++++++
>> net/sched/act_api.c          | 28 ++++++++++++++++++++++++++--
>> 3 files changed, 38 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/net/act_api.h b/include/net/act_api.h
>> index 1d71644..0692458 100644
>> --- a/include/net/act_api.h
>> +++ b/include/net/act_api.h
>> @@ -41,6 +41,7 @@ struct tc_action {
>> 	struct rcu_head			tcfa_rcu;
>> 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
>> 	struct gnet_stats_queue __percpu *cpu_qstats;
>> +	struct tc_cookie	*act_ck;
>
> I wonder if we just can't do:
> struct tc_cookie act_ck;
> You would safe kzalloc. I don't have strong opinion though..
>

Lets spare some RAM. I'll keep it the way it is.

>
>> };
>> #define tcf_head	common.tcfa_head
>> #define tcf_index	common.tcfa_index
>> diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
>> index 1e5e1dd..063bc89 100644
>> --- a/include/uapi/linux/pkt_cls.h
>> +++ b/include/uapi/linux/pkt_cls.h
>> @@ -4,6 +4,16 @@
>> #include <linux/types.h>
>> #include <linux/pkt_sched.h>
>>
>> +#define MAX_TC_COOKIE_SZ 16
>
> I like to have some "namespace" prefix for user api.
> "TC_COOKIE_MAX_SIZE" perhaps?
>

I just cutnpasted from something familiar: MAX_PHYS_ITEM_ID_LEN ;->
Will make the change.

>> +
>> +/* This structure holds cookie structure that is passed from user
>> + * to the kernel for actions and classifiers
>> + */
>> +struct tc_cookie {
>> +	unsigned char ck[MAX_TC_COOKIE_SZ];
>> +	unsigned char ck_len;
>
> This struct should certainly not be in UAPI header.
>

I will move it.

>
>> +};
>> +
>> /* Action attributes */
>> enum {
>> 	TCA_ACT_UNSPEC,
>> @@ -12,6 +22,7 @@ enum {
>> 	TCA_ACT_INDEX,
>> 	TCA_ACT_STATS,
>> 	TCA_ACT_PAD,
>> +	TCA_ACT_COOKIE,
>> 	__TCA_ACT_MAX
>> };


>> +		memcpy((void *)a->act_ck->ck, nla_data(tb[TCA_ACT_COOKIE]),
>
>                        Unneeded (void *) cast.
>

ok. I think gcc whined for some reason.

Will post after some test.

cheers,
jamal
