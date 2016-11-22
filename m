From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 1/1] net sched filters: pass netlink message flags
 in event notification
Date: Tue, 22 Nov 2016 10:28:02 +0100
Message-ID: <58340FA2.7040006@iogearbox.net>
References: <1479334570-25159-1-git-send-email-mrv@mojatatu.com> <CAM_iQpU_ivg4eBV=88DH6qEcomrq0+G5M=c9rafLszf09PAP_w@mail.gmail.com> <CAM_iQpXPsDAfgGsKB7V_=+LnwnuqzgvY7amcPo7hs3VKGrviiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48027 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755534AbcKVJ2G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 04:28:06 -0500
In-Reply-To: <CAM_iQpXPsDAfgGsKB7V_=+LnwnuqzgvY7amcPo7hs3VKGrviiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2016 06:23 AM, Cong Wang wrote:
> On Thu, Nov 17, 2016 at 1:02 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Wed, Nov 16, 2016 at 2:16 PM, Roman Mashak <mrv@mojatatu.com> wrote:
>>> Userland client should be able to read an event, and reflect it back to
>>> the kernel, therefore it needs to extract complete set of netlink flags.
>>>
>>> For example, this will allow "tc monitor" to distinguish Add and Replace
>>> operations.
>>>
>>> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
>>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>>> ---
>>>   net/sched/cls_api.c | 5 +++--
>>>   1 file changed, 3 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>>> index 2b2a797..8e93d4a 100644
>>> --- a/net/sched/cls_api.c
>>> +++ b/net/sched/cls_api.c
>>> @@ -112,7 +112,7 @@ static void tfilter_notify_chain(struct net *net, struct sk_buff *oskb,
>>>
>>>          for (it_chain = chain; (tp = rtnl_dereference(*it_chain)) != NULL;
>>>               it_chain = &tp->next)
>>> -               tfilter_notify(net, oskb, n, tp, 0, event, false);
>>> +               tfilter_notify(net, oskb, n, tp, n->nlmsg_flags, event, false);
>>
>>
>> I must miss something, why does it make sense to pass n->nlmsg_flags
>> as 'fh' to tfilter_notify()??
>
> Ping... Any response?
>
> It still doesn't look correct to me. I will send a fix unless someone could
> explain this.

Sigh, I missed that this was applied already to -net (it certainly doesn't look
like -net material, but rather -net-next stuff) ... This definitely looks buggy
to me, the 0 as it was before was correct here (as it means we delete the whole
chain in this case).

If you could send a patch would be great. Thanks Cong!
