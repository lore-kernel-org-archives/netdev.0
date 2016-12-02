From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 2/3] netns: add dummy struct inside "struct net_generic"
Date: Thu, 1 Dec 2016 22:53:09 -0800
Message-ID: <CAM_iQpUJ2KHhWYxuu0rJzwSLB_BdT_tGbuFCStpW97URcWmjpw@mail.gmail.com>
References: <20161202011258.GC31170@avx2> <CAM_iQpU=S=e3e5-TjLFLVVwTwuQeu8m6Mi=TPSSrjt25ceBRCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pavel Emelyanov <xemul@openvz.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35778 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755591AbcLBGxb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 01:53:31 -0500
Received: by mail-io0-f193.google.com with SMTP id h133so6711850ioe.2
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 22:53:30 -0800 (PST)
In-Reply-To: <CAM_iQpU=S=e3e5-TjLFLVVwTwuQeu8m6Mi=TPSSrjt25ceBRCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 1, 2016 at 9:42 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Dec 1, 2016 at 5:12 PM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
>>  struct net_generic {
>> -       unsigned int len;
>> -       struct rcu_head rcu;
>> +       struct {
>> +               unsigned int len;
>> +               struct rcu_head rcu;
>> +       } s;
>>
>>         void *ptr[0];
>>  };
>
> I think you can put them in a union, since rcu is only used
> for kfree_rcu() where len is not needed and rcu_head doesn't
> need to be initialized by callers.

Never mind, readers could be still reading ->len while we modify
->rcu. So they can't be in a union.
