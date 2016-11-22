From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net 1/1] net sched filters: pass netlink message flags in
 event notification
Date: Mon, 21 Nov 2016 21:23:15 -0800
Message-ID: <CAM_iQpXPsDAfgGsKB7V_=+LnwnuqzgvY7amcPo7hs3VKGrviiA@mail.gmail.com>
References: <1479334570-25159-1-git-send-email-mrv@mojatatu.com> <CAM_iQpU_ivg4eBV=88DH6qEcomrq0+G5M=c9rafLszf09PAP_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35215 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750804AbcKVFXg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 00:23:36 -0500
Received: by mail-it0-f68.google.com with SMTP id b123so535470itb.2
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 21:23:36 -0800 (PST)
In-Reply-To: <CAM_iQpU_ivg4eBV=88DH6qEcomrq0+G5M=c9rafLszf09PAP_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2016 at 1:02 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Wed, Nov 16, 2016 at 2:16 PM, Roman Mashak <mrv@mojatatu.com> wrote:
>> Userland client should be able to read an event, and reflect it back to
>> the kernel, therefore it needs to extract complete set of netlink flags.
>>
>> For example, this will allow "tc monitor" to distinguish Add and Replace
>> operations.
>>
>> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>> ---
>>  net/sched/cls_api.c | 5 +++--
>>  1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>> index 2b2a797..8e93d4a 100644
>> --- a/net/sched/cls_api.c
>> +++ b/net/sched/cls_api.c
>> @@ -112,7 +112,7 @@ static void tfilter_notify_chain(struct net *net, struct sk_buff *oskb,
>>
>>         for (it_chain = chain; (tp = rtnl_dereference(*it_chain)) != NULL;
>>              it_chain = &tp->next)
>> -               tfilter_notify(net, oskb, n, tp, 0, event, false);
>> +               tfilter_notify(net, oskb, n, tp, n->nlmsg_flags, event, false);
>
>
> I must miss something, why does it make sense to pass n->nlmsg_flags
> as 'fh' to tfilter_notify()??

Ping... Any response?

It still doesn't look correct to me. I will send a fix unless someone could
explain this.
