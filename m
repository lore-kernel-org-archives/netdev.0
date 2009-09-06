From: David Miller <davem@davemloft.net>
Subject: Re: net_sched 02/07: make cls_ops->tcf_chain() optional
Date: Sun, 06 Sep 2009 02:06:49 -0700 (PDT)
Message-ID: <20090906.020649.242756996.davem@davemloft.net>
References: <4AA2520D.2060603@gmail.com>
	<4AA25A51.2040100@gmail.com>
	<4AA299C6.7070904@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34565
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752296AbZIFJGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2009 05:06:34 -0400
In-Reply-To: <4AA299C6.7070904@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 05 Sep 2009 19:03:02 +0200

> Jarek Poplawski wrote:
>> Jarek Poplawski wrote, On 09/05/2009 01:57 PM:
>> 
>>>>> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>>>>> index 09cdcdf..eaa8f43 100644
>>>>> --- a/net/sched/cls_api.c
>>>>> +++ b/net/sched/cls_api.c
>>>>> @@ -181,6 +181,9 @@ replay:
>>>>>  	if ((cops = q->ops->cl_ops) == NULL)
>>>>>  		return -EINVAL;
>>>>>  
>>>>> +	if (cops->tcf_chain == NULL)
>>>>> +		return -EOPNOTSUPP;
>>>>> +
>>>> You should probably repeat this in tc_dump_tfilter.
>>>  
>>>
>>> ...In case somebody finds the way to list a filter before
>>> adding it. ;-) But, since it's quite unlikely, let's foget it.
>> 
>> 
>> ...or simply tries to do it instead of meditating the code.
>> So this change is definitely needed in tc_dump_tfilter too.
> 
> Thanks Jarek. I'm on my way out the door, but I'll fix that tommorrow.

I'll add the following to patch 2:

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 8cbc66f..6a53694 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -433,6 +433,8 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 		goto out;
 	if ((cops = q->ops->cl_ops) == NULL)
 		goto errout;
+	if (cops->tcf_chain == NULL)
+		goto errout;
 	if (TC_H_MIN(tcm->tcm_parent)) {
 		cl = cops->get(q, tcm->tcm_parent);
 		if (cl == 0)
