From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next v2 4/4] net_sched: kill u32_node pointer in Qdisc
Date: Fri, 25 Aug 2017 14:37:40 +0200
Message-ID: <20170825123740.GF2023@nanopsycho>
References: <20170824235130.28503-1-xiyou.wangcong@gmail.com>
 <20170824235130.28503-5-xiyou.wangcong@gmail.com>
 <c54bd7cc-ab56-6aac-2e24-85e9e8e1c708@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37939 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754279AbdHYMhn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 08:37:43 -0400
Received: by mail-wm0-f53.google.com with SMTP id z132so1858857wmg.1
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 05:37:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <c54bd7cc-ab56-6aac-2e24-85e9e8e1c708@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Aug 25, 2017 at 02:29:57PM CEST, jhs@mojatatu.com wrote:
>On 17-08-24 07:51 PM, Cong Wang wrote:
>> It is ugly to hide a u32-filter-specific pointer inside Qdisc,
>> this breaks the TC layers:
>> 
>> 1. Qdisc is a generic representation, should not have any specific
>>     data of any type
>> 
>> 2. Qdisc layer is above filter layer, should only save filters in
>>     the list of struct tcf_proto.
>> 
>> This pointer is used as the head of the chain of u32 hash tables,
>> that is struct tc_u_hnode, because u32 filter is very special,
>> it allows to create multiple hash tables within one qdisc and
>> across multiple u32 filters.
>> 
>> Instead of using this ugly pointer, we can just save it in a global
>> hash table key'ed by (dev ifindex, qdisc handle), therefore we can
>> still treat it as a per qdisc basis data structure conceptually.
>> 
>> Of course, because of network namespaces, this key is not unique
>> at all, but it is fine as we already have a pointer to Qdisc in
>> struct tc_u_common, we can just compare the pointers when collision.
>> 
>> And this only affects slow paths, has no impact to fast path,
>> thanks to the pointer ->tp_c.
>> 
>> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>> Cc: Jiri Pirko <jiri@resnulli.us>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
>Nice work. should open the doors for Jiri now.

One of the doors, couple more left :)

>
>Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
>cheers,
>jamal
