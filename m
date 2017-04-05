From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net_sched: replace yield() with cond_resched()
Date: Tue, 4 Apr 2017 22:19:43 -0700
Message-ID: <CAM_iQpXpZjpS1ZG7hH-52jt41FzzyMZ0rss9PauaSD54XSQiXQ@mail.gmail.com>
References: <1491357139-27108-1-git-send-email-xiyou.wangcong@gmail.com> <1491364545.4536.90.camel@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Mike Galbraith <efault@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35618 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751121AbdDEFUF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 01:20:05 -0400
Received: by mail-wr0-f194.google.com with SMTP id t20so298738wra.2
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 22:20:04 -0700 (PDT)
In-Reply-To: <1491364545.4536.90.camel@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 4, 2017 at 8:55 PM, Mike Galbraith <efault@gmx.de> wrote:
> On Tue, 2017-04-04 at 18:52 -0700, Cong Wang wrote:
>
>> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
>> index 1a2f9e9..4725d2f 100644
>> --- a/net/sched/sch_generic.c
>> +++ b/net/sched/sch_generic.c
>> @@ -925,7 +925,7 @@ void dev_deactivate_many(struct list_head *head)
>>       /* Wait for outstanding qdisc_run calls. */
>>       list_for_each_entry(dev, head, close_list)
>>               while (some_qdisc_is_busy(dev))
>> -                     yield();
>> +                     cond_resched();
>>  }
>
> That won't help, cond_resched() has the same impact upon a lone
> SCHED_FIFO task as yield() does.. none.

Hmm? In the comment you quote:

 * If you want to use yield() to wait for something, use wait_event().
 * If you want to use yield() to be 'nice' for others, use cond_resched().

So if cond_resched() doesn't help, why this misleading comment?

I picked the latter one, because the former is harder to implement
properly (at least for -net) we need qdisc's to notify this waiter once
they finish transmitting packets, which means we probably need
a per-netdevice wait struct.
