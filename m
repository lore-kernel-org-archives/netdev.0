From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] inet: fix sleeping inside inet_wait_for_connect()
Date: Wed, 2 Nov 2016 13:01:11 -0700
Message-ID: <CAM_iQpXp_an9xN2SObttO=f2ePp=MZdE1fb8fPuYqjrcZPCfJw@mail.gmail.com>
References: <1478041476-5568-1-git-send-email-xiyou.wangcong@gmail.com> <1478051697.7065.360.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Peter Zijlstra <peterz@infradead.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36433 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753009AbcKBUBd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 16:01:33 -0400
Received: by mail-oi0-f67.google.com with SMTP id 128so2721267oih.3
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 13:01:32 -0700 (PDT)
In-Reply-To: <1478051697.7065.360.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 1, 2016 at 6:54 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-11-01 at 16:04 -0700, Cong Wang wrote:
>> Andrey reported this kernel warning:
>
>> Unlike commit 26cabd31259ba43f68026ce3f62b78094124333f
>> ("sched, net: Clean up sk_wait_event() vs. might_sleep()"), the
>> sleeping function is called before schedule_timeout(), this is indeed
>> a bug. Fix this by moving the wait logic to the new API, it is similar
>> to commit ff960a731788a7408b6f66ec4fd772ff18833211
>> ("netdev, sched/wait: Fix sleeping inside wait event").
>>
>> Reported-by: Andrey Konovalov <andreyknvl@google.com>
>> Cc: Andrey Konovalov <andreyknvl@google.com>
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: Peter Zijlstra <peterz@infradead.org>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>
>
> Excellent.
>
> I guess we could also define sk_wait_event_woken()
> and use it instead of sk_wait_event(), and also in
> inet_wait_for_connect()

Agreed, I will send some followup patches to address this,
probably all release_sock() before a schedule_*() need
to fix.

Thanks!
