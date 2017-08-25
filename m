From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next v2 4/4] net_sched: kill u32_node pointer in Qdisc
Date: Fri, 25 Aug 2017 08:29:57 -0400
Message-ID: <c54bd7cc-ab56-6aac-2e24-85e9e8e1c708@mojatatu.com>
References: <20170824235130.28503-1-xiyou.wangcong@gmail.com>
 <20170824235130.28503-5-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34969 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755854AbdHYM37 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 08:29:59 -0400
Received: by mail-io0-f180.google.com with SMTP id k22so7164106iod.2
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 05:29:59 -0700 (PDT)
In-Reply-To: <20170824235130.28503-5-xiyou.wangcong@gmail.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-24 07:51 PM, Cong Wang wrote:
> It is ugly to hide a u32-filter-specific pointer inside Qdisc,
> this breaks the TC layers:
> 
> 1. Qdisc is a generic representation, should not have any specific
>     data of any type
> 
> 2. Qdisc layer is above filter layer, should only save filters in
>     the list of struct tcf_proto.
> 
> This pointer is used as the head of the chain of u32 hash tables,
> that is struct tc_u_hnode, because u32 filter is very special,
> it allows to create multiple hash tables within one qdisc and
> across multiple u32 filters.
> 
> Instead of using this ugly pointer, we can just save it in a global
> hash table key'ed by (dev ifindex, qdisc handle), therefore we can
> still treat it as a per qdisc basis data structure conceptually.
> 
> Of course, because of network namespaces, this key is not unique
> at all, but it is fine as we already have a pointer to Qdisc in
> struct tc_u_common, we can just compare the pointers when collision.
> 
> And this only affects slow paths, has no impact to fast path,
> thanks to the pointer ->tp_c.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Nice work. should open the doors for Jiri now.

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
