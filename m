From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net/sched: pkt_cls: change tc actions order to
 be as the user sets
Date: Sun, 25 Sep 2016 21:31:40 -0700
Message-ID: <CAM_iQpVBhckM4f43T0Lc2Bt28nVFBAjORHt5d=1_m9AfoPJtSg@mail.gmail.com>
References: <1474812524-29089-1-git-send-email-hadarh@mellanox.com> <19723e0f-50b0-77fa-2884-c5bb6e182df9@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:38662 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751375AbcIZEcB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 00:32:01 -0400
Received: by mail-it0-f53.google.com with SMTP id n143so64799731ita.1
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 21:32:01 -0700 (PDT)
In-Reply-To: <19723e0f-50b0-77fa-2884-c5bb6e182df9@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 25, 2016 at 7:39 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-09-25 10:08 AM, Hadar Hen Zion wrote:
>>
>> Currently the created tc actions list is reversed against the order
>> set by the user.
>> Change the actions list order to be the same as was set by the user.
>>
>
>
> Did something break? It seems to matter most for dumping. But even that
> didnt breaking. Looking at the latest net tree, i tried:
>

The reason is we use action->order as an nested attribute, so
the order in the list doesn't matter, only action->order itself matters.

See tcf_action_dump():

   nest = nla_nest_start(skb, a->order);
