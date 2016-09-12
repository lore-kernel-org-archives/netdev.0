From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net_sched: act_mirred: full rcu conversion
Date: Sun, 11 Sep 2016 23:12:04 -0700
Message-ID: <CAM_iQpXycdn9_LW_qYzUe5T97ABOj3KrivjCB5ho9wbKeFR0MQ@mail.gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com>
 <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
 <57D0FF87.604@gmail.com> <1473341283.15733.33.camel@edumazet-glaptop3.roam.corp.google.com>
 <1473348943.15733.57.camel@edumazet-glaptop3.roam.corp.google.com>
 <57D1881B.6090009@gmail.com> <1473349900.15733.59.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpV+ybrM_ebgwX5ZohmKvWZo-8znXkgJv1LhDAC9=3u9Xw@mail.gmail.com> <57D2DAD1.5000306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35654 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932613AbcILGMo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 02:12:44 -0400
Received: by mail-oi0-f65.google.com with SMTP id 2so20524663oif.2
        for <netdev@vger.kernel.org>; Sun, 11 Sep 2016 23:12:25 -0700 (PDT)
In-Reply-To: <57D2DAD1.5000306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 9, 2016 at 8:52 AM, John Fastabend <john.fastabend@gmail.com> wrote:
> On 16-09-08 10:26 PM, Cong Wang wrote:
>> On Thu, Sep 8, 2016 at 8:51 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> On Thu, 2016-09-08 at 08:47 -0700, John Fastabend wrote:
>>>
>>>> Works for me. FWIW I find this plenty straightforward and don't really
>>>> see the need to make the hash table itself rcu friendly.
>>>>
>>>> Acked-by: John Fastabend <john.r.fastabend@intel.com>
>>>>
>>>
>>> Yes, it seems this hash table is used in control path, with RTNL held
>>> anyway.
>>
>> Seriously? You never read hashtable in fast path?? I think you need
>> to wake up.
>>
>
> But the actions use refcnt'ing and should never be decremented to zero
> as long as they can still be referenced by an active filter. If each
> action handles its parameters like mirred/gact then I don't see why its
> necessary.

This is correct, by "read" I meant "dereference", the tc actions
are now permanently stored in hashtable directly, so "reading"
a tc action is reading from hashtable.

Sorry if this wasn't clear.
