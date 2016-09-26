From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Subject: Re: [PATCH net-next] net/sched: pkt_cls: change tc actions order to
 be as the user sets
Date: Mon, 26 Sep 2016 09:02:30 +0300
Message-ID: <CAJL1qvGnPsjbzp9Z_6GkXzJqrxAAgYY6uE_0mCWb=H-EhcB8-A@mail.gmail.com>
References: <1474812524-29089-1-git-send-email-hadarh@mellanox.com>
 <19723e0f-50b0-77fa-2884-c5bb6e182df9@mojatatu.com> <CAM_iQpVBhckM4f43T0Lc2Bt28nVFBAjORHt5d=1_m9AfoPJtSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:34709 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761222AbcIZGCg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 02:02:36 -0400
Received: by mail-oi0-f42.google.com with SMTP id a62so196134671oib.1
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 23:02:31 -0700 (PDT)
In-Reply-To: <CAM_iQpVBhckM4f43T0Lc2Bt28nVFBAjORHt5d=1_m9AfoPJtSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 26, 2016 at 7:31 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sun, Sep 25, 2016 at 7:39 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 16-09-25 10:08 AM, Hadar Hen Zion wrote:
>>>
>>> Currently the created tc actions list is reversed against the order
>>> set by the user.
>>> Change the actions list order to be the same as was set by the user.
>>>
>>
>>
>> Did something break? It seems to matter most for dumping. But even that
>> didnt breaking. Looking at the latest net tree, i tried:
>>
>
> The reason is we use action->order as an nested attribute, so
> the order in the list doesn't matter, only action->order itself matters.

The order in the list matters for offload drivers who use the
"tcf_exts_to_list" function and action->order parameter isn't usable
for them.
Why not keeping the actions in the same order as the user? isn't it
more elegant?

Hadar


>
> See tcf_action_dump():
>
>    nest = nla_nest_start(skb, a->order);
