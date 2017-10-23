From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net v2 1/4] net/sched: Change tc_action refcnt and bindcnt
 to atomic
Date: Mon, 23 Oct 2017 08:39:52 -0700
Message-ID: <CAM_iQpVqhwwyb+9-7Y6po0fAaNhzdjLpSAT1FS7dLm8TuhVcZQ@mail.gmail.com>
References: <1508152718-28726-1-git-send-email-chrism@mellanox.com>
 <1508152718-28726-2-git-send-email-chrism@mellanox.com> <CAM_iQpXA5y8nqCRAxy-9VJTSf3Z7g-6pL1PL1omcwkZn1apFUw@mail.gmail.com>
 <VI1PR0501MB21439CB952C540F903969648AB4C0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
 <CAM_iQpWbfjCH0EFb8RYnOuZQtVtg-Mw-Kzv3GWq81qTVErN6hA@mail.gmail.com>
 <VI1PR0501MB21437552565B68DC71A7DEE1AB4D0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
 <CAM_iQpVA2SQ4eFWEQxjQwmoxwQnQiLgREETKdQLoADWt_xD4Bg@mail.gmail.com>
 <b9444485-8e34-48ac-2b4f-abbd9c6d455f@mojatatu.com> <CAM_iQpVMLJjyuSgGHZycgzRz6KHusyTODOAMbw2dj7jTb7bbQQ@mail.gmail.com>
 <VI1PR0501MB2143994E767A6C7C9BE1754AAB460@VI1PR0501MB2143.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Lucas Bates <lucasb@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        David Miller <davem@davemloft.net>
To: Chris Mi <chrism@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:54567 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932126AbdJWPkO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 11:40:14 -0400
Received: by mail-pg0-f44.google.com with SMTP id l24so12056170pgu.11
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 08:40:13 -0700 (PDT)
In-Reply-To: <VI1PR0501MB2143994E767A6C7C9BE1754AAB460@VI1PR0501MB2143.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 22, 2017 at 7:47 PM, Chris Mi <chrism@mellanox.com> wrote:
>
> It seems it is not easy to discard call_rcu().  I'm afraid even if we have a final solution
> without call_rcu(), it is not mature at the beginning as well. I mean we also need time

Why do you believe it is not easy? RTNL lock is already there,
list_splice_init_rcu() is there too. I can naturally divide my patches
for each module so that they are much easier to backport than
yours.


> to fix the possible bugs of the new design. And maybe to destroy the filters in parallel
> is the right direction. If this bug is the last bug brought by call_rcu(), then changing it
> may not be a good idea.

Again, you have to prove this is the last bug, I seriously doubt
it is.


>
> Patch 1 is straightforward to use atomic. Patch 2 is to convert the list to array.

Both are big in size.


> I think there is no harm to the new design.  Patch 3 and 4 are useful test case.

It definitely doesn't harm, but why do we waste time on it when we
know there is a better way? It is clearly not easy for backport either,
in fact it is harder w.r.t. size.


> We also need it with new design to make sure there is no regression.
>

Are you saying I can't trust your test cases? ;)


> So I think my patch set should not be held so long time.

I think your patches should be dropped except the last two,
I will take the last two for you.

Thanks!
