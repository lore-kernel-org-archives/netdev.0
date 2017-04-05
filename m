From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net_sched: replace yield() with cond_resched()
Date: Wed, 5 Apr 2017 16:42:18 -0700
Message-ID: <CAM_iQpUa-w9k4EFafQCEpbmR0PANwkLieYMxGwi59373h8jHUg@mail.gmail.com>
References: <1491357139-27108-1-git-send-email-xiyou.wangcong@gmail.com>
 <1491364545.4536.90.camel@gmx.de> <CAM_iQpXpZjpS1ZG7hH-52jt41FzzyMZ0rss9PauaSD54XSQiXQ@mail.gmail.com>
 <1491371790.4536.151.camel@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Mike Galbraith <efault@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33011 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752436AbdDEXng (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 19:43:36 -0400
Received: by mail-wr0-f194.google.com with SMTP id g19so6729121wrb.0
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 16:42:39 -0700 (PDT)
In-Reply-To: <1491371790.4536.151.camel@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 4, 2017 at 10:56 PM, Mike Galbraith <efault@gmx.de> wrote:
> On Tue, 2017-04-04 at 22:19 -0700, Cong Wang wrote:
>> On Tue, Apr 4, 2017 at 8:55 PM, Mike Galbraith <efault@gmx.de> wrote:
>
>> > That won't help, cond_resched() has the same impact upon a lone
>> > SCHED_FIFO task as yield() does.. none.
>>
>> Hmm? In the comment you quote:
>>
>>  * If you want to use yield() to wait for something, use wait_event().
>>  * If you want to use yield() to be 'nice' for others, use cond_resched().
>>
>> So if cond_resched() doesn't help, why this misleading comment?
>
> This is not an oh let's be nice guys thing, it's a perfect match of...
>
> <copy/paste>
>  * while (!event)
>  *      yield();
> (/copy/paste>
>
> ..get off the CPU until this happens thing.  With nobody to yield the C
> PU to, some_qdisc_is_busy() will remain true forever more.


This is exactly the misleading part, a while-loop waiting for an event
can always be a be-nice-for-others thing, because if not we can just
spin as a spinlock. You probably want to improve that comment to
explain when cond_resched() is a right solution to replace yield(),
so that I could know when it is not.

Thanks.
