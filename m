From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH v2 1/1] net_sched fix: reclassification needs
 to consider ether protocol changes
Date: Thu, 18 Feb 2016 12:53:15 +0100
Message-ID: <56C5B0AB.8040802@iogearbox.net>
References: <1455709055-30881-1-git-send-email-jhs@emojatatu.com>	<1455709055-30881-2-git-send-email-jhs@emojatatu.com> <CAM_iQpX+b7F87gx4PcEhs0xFA6KtUssJAQo7+Jo9g9kLcOfB6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57459 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425548AbcBRLxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 06:53:20 -0500
In-Reply-To: <CAM_iQpX+b7F87gx4PcEhs0xFA6KtUssJAQo7+Jo9g9kLcOfB6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/17/2016 06:27 PM, Cong Wang wrote:
> On Wed, Feb 17, 2016 at 3:37 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
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
>> action  vlan pop reclassify
>>
>> Fixes: 3b3ae880266d ("net: sched: consolidate tc_classify{,_compat}")
>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>> ---
>>   net/sched/sch_api.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
>> index b5c2cf2..af46fee 100644
>> --- a/net/sched/sch_api.c
>> +++ b/net/sched/sch_api.c
>> @@ -1822,7 +1822,6 @@ int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>>   #ifdef CONFIG_NET_CLS_ACT
>>          const struct tcf_proto *old_tp = tp;
>>          int limit = 0;
>> -
>
> Why remove this empty line? I think it is still useful. :)
>
> Also your patch should be targeted to -net instead of -net-next, since it
> fixes a bug.

Yeah, good point. That should go to -net (minus the unrelated white space change).

Thanks,
Daniel
