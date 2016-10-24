From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 1/1] net sched filters: fix notification of filter
 delete with proper handle
Date: Mon, 24 Oct 2016 11:03:19 +0200
Message-ID: <580DCE57.6070606@iogearbox.net>
References: <1477236912-5789-1-git-send-email-jhs@emojatatu.com> <580D3A14.5010705@iogearbox.net> <20161024084858.GD2781@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47050 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934500AbcJXJDY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 05:03:24 -0400
In-Reply-To: <20161024084858.GD2781@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/2016 10:48 AM, Jiri Pirko wrote:
> Mon, Oct 24, 2016 at 12:30:44AM CEST, daniel@iogearbox.net wrote:
>> On 10/23/2016 05:35 PM, Jamal Hadi Salim wrote:
>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> An actual commit message would be good especially if it's a fix
>> for -net tree plus stable. Thanks.
>
> Also a "Fixes:" tag would be nice to have :)

This kernel address leakage dates back to history tree:

Fixes: 4e54c4816bfe ("[NET]: Add tc extensions infrastructure.")

>>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>>> ---
>>>    net/sched/cls_api.c | 3 ++-
>>>    1 file changed, 2 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>>> index 2ee29a3..2b2a797 100644
>>> --- a/net/sched/cls_api.c
>>> +++ b/net/sched/cls_api.c
>>> @@ -345,7 +345,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
>>>    			if (err == 0) {
>>>    				struct tcf_proto *next = rtnl_dereference(tp->next);
>>>
>>> -				tfilter_notify(net, skb, n, tp, fh,
>>> +				tfilter_notify(net, skb, n, tp,
>>> +					       t->tcm_handle,
>>>    					       RTM_DELTFILTER, false);
>>>    				if (tcf_destroy(tp, false))
>>>    					RCU_INIT_POINTER(*back, next);
>>>
>>
