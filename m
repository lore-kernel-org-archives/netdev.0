From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Use after free in __dst_destroy_metrics_generic
Date: Sat, 16 Sep 2017 11:21:59 -0700
Message-ID: <CAM_iQpVjJo4gKHGdaJh8mcV5gX+ssmv46UT+25+8-hKk1UUnDg@mail.gmail.com>
References: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org>
 <CAM_iQpXKfUkbyuuZEZXyPrVVCoPaxnCmCARz=Jf0VtU1m9NsZg@mail.gmail.com>
 <1505509219.16139.6.camel@edumazet-glaptop3.roam.corp.google.com>
 <alpine.LFD.2.20.1709160103190.1770@ja.home.ssi.bg> <0b4e9dbc852c4df7401dc770f357ae6a@codeaurora.org>
 <alpine.LFD.2.20.1709161422010.2651@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Lorenzo Colitti <lorenzo@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:49923 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751253AbdIPSWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 16 Sep 2017 14:22:20 -0400
Received: by mail-pf0-f170.google.com with SMTP id l188so2956035pfc.6
        for <netdev@vger.kernel.org>; Sat, 16 Sep 2017 11:22:20 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.20.1709161422010.2651@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 16, 2017 at 5:40 AM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Fri, 15 Sep 2017, Subash Abhinov Kasiviswanathan wrote:
>
>> >     May be I'm missing some posting but I don't see if
>> > the patch was tested successfully.
>> >
>> Hi Julian
>>
>> I've had this patch being tested for the last 3-4 days in our regression rack
>> and I haven't seen the same issue being reproduced or even a related crash
>> or leak in dst.
>
>         For now I see only its bug-hiding side effects, i.e.
> it does not call kfree. Now if there is no double-free
> there should be a leak, not for dst but for metrics.


You make very good points. I need to take a deeper look.


>
>> The original issue was reported only once to us from the regression rack only
>> so the exact steps to reproduce is unknown.
>
>         OK, lets see, may be others can explain what happens.
>

This makes me thinking if it is possible that we no longer have
the guarantee of metrics address aligned to at least 4?
This seems unlikely since kmalloc() should return at least
word-size-aligned address.
