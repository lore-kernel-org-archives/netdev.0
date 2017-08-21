From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net v2] ipv6: add rcu grace period before freeing fib6_node
Date: Mon, 21 Aug 2017 09:19:47 -0700
Message-ID: <CAEA6p_BW+VWhAgY0Ztufm_RWaEQoXTLXOPc0_94VEqRBmt4RZg@mail.gmail.com>
References: <20170820003408.133176-1-tracywwnj@gmail.com> <20170820.195954.75794556487638223.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f179.google.com ([209.85.217.179]:34748 "EHLO
        mail-ua0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753684AbdHUQTt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 12:19:49 -0400
Received: by mail-ua0-f179.google.com with SMTP id d12so6340231uag.1
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 09:19:49 -0700 (PDT)
In-Reply-To: <20170820.195954.75794556487638223.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Goodness.... where to start.
>
> If this bug has been around forever, why did you make this patch
> against net-next instead of net?  (I can tell just by looking at
> the patch because rt6_free_pcpu() is static in 'net' yet it is
> not static in the diff hunk which matches net-next)
>
> And if you made it against net-next, why are you saying "net" in
> your subject line instead of "[PATCH net-next v2]"?
>
> Please sort this out properly, and resubmit.
>
> Thank you.

It should be applied to "net". I will rebase my change and resubmit.
Sorry for the confusion.

Thanks.
Wei

On Sun, Aug 20, 2017 at 7:59 PM, David Miller <davem@davemloft.net> wrote:
> From: Wei Wang <weiwan@google.com>
> Date: Sat, 19 Aug 2017 17:34:08 -0700
>
>> From: Wei Wang <weiwan@google.com>
>>
>> We currently keep rt->rt6i_node pointing to the fib6_node for the route.
>> And some functions make use of this pointer to dereference the fib6_node
>> from rt structure, e.g. rt6_check(). However, as there is neither
>> refcount nor rcu taken when dereferencing rt->rt6i_node, it could
>> potentially cause crashes as rt->rt6i_node could be set to NULL by other
>> CPUs when doing a route deletion.
>> This patch introduces an rcu grace period before freeing fib6_node and
>> makes sure the functions that dereference it takes rcu_read_lock().
>>
>> Note: there is no "Fixes" tag because this bug was there in a very
>> early stage.
>>
>> Signed-off-by: Wei Wang <weiwan@google.com>
>> Acked-by: Eric Dumazet <edumazet@google.com>
>> ---
>> v2: removed one extra empty line
>
> Goodness.... where to start.
>
> If this bug has been around forever, why did you make this patch
> against net-next instead of net?  (I can tell just by looking at
> the patch because rt6_free_pcpu() is static in 'net' yet it is
> not static in the diff hunk which matches net-next)
>
> And if you made it against net-next, why are you saying "net" in
> your subject line instead of "[PATCH net-next v2]"?
>
> Please sort this out properly, and resubmit.
>
> Thank you.
