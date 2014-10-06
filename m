From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH] net: sched: cls_cgroup tear down exts and ematch from
 rcu callback
Date: Sun, 05 Oct 2014 18:48:20 -0700
Message-ID: <5431F4E4.8000209@gmail.com>
References: <20141003163333.20118.59609.stgit@nitbit.x32> <20141005.213146.1400362219156302379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org, jhs@mojatatu.com,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:63187 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbaJFBsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 21:48:35 -0400
Received: by mail-oi0-f51.google.com with SMTP id h136so173079oig.38
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 18:48:35 -0700 (PDT)
In-Reply-To: <20141005.213146.1400362219156302379.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2014 06:31 PM, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Fri, 03 Oct 2014 09:33:35 -0700
>
>> It is not RCU safe to destroy the action chain while there
>> is a possibility of readers accessing it. Move this code
>> into the rcu callback using the same rcu callback used in the
>> code patch to make a change to head.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>   ...
>> @@ -156,10 +156,8 @@ static void cls_cgroup_destroy(struct tcf_proto *tp)
>>   	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
>>
>>   	if (head) {
>> -		tcf_exts_destroy(&head->exts);
>> -		tcf_em_tree_destroy(head->net, &head->ematches);
>>   		RCU_INIT_POINTER(tp->root, NULL);
>> -		kfree_rcu(head, rcu);
>> +		call_rcu(&head->rcu, cls_cgroup_destroy_rcu);
>>   	}
>
> tcf_em_tree_destroy() takes head->tp as it's first argument in my
> net-next tree, maybe you need to respin this?
>

Yep, I'll respin this now sorry about that got a bit out of sync.

Thanks!

-- 
John Fastabend         Intel Corporation
