From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ipv4: igmp: fix a use after free
Date: Thu, 8 Jun 2017 23:05:10 -0700
Message-ID: <CAM_iQpUd0uO63zPzC6ijYRcRAZSrW_C_trWA5vyRM_9OsHLU-A@mail.gmail.com>
References: <CAAeHK+xmSxokDidhzP1VWgmbbwege4OaGvOA4PwTP1scs6J5zA@mail.gmail.com>
 <1496929425.736.73.camel@edumazet-glaptop3.roam.corp.google.com>
 <CADvbK_fWOFWZxKc8gbzeDeU1ALq5GHxKvoGsPt+GsdAP0a601w@mail.gmail.com>
 <1496954011.736.86.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVu+sF4zGhGCYDV6J-+rN69zuMGGvGJpLajhYS-QfdUfQ@mail.gmail.com> <1496972227.736.90.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Xin Long <lucien.xin@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34401 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751515AbdFIGFc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 02:05:32 -0400
Received: by mail-wm0-f68.google.com with SMTP id 70so10190148wme.1
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 23:05:31 -0700 (PDT)
In-Reply-To: <1496972227.736.90.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 8, 2017 at 6:37 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-06-08 at 17:59 -0700, Cong Wang wrote:
>> On Thu, Jun 8, 2017 at 1:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > I mentioned (in https://lkml.org/lkml/2017/5/31/619 ) that we might need
>> > to defer freeing after rcu grace period but for some reason decided it
>> > was not needed.
>>
>> This one makes sense, it is the second time I saw the use-after-free
>> in igmp code, both are because we don't respect the RCU rule to free
>> an element in the list.
>>
>> >
>> > What about :
>>
>> But not sure if all ip_ma_put() callers want ip_mc_clear_src().
>
> That would lead to a memory leak if this was the case ?

Maybe, but looking at igmpv3_clear_delrec() again, seems
we can just acquire pmc->lock in ip_mc_clear_src() to serialize
with the readers?
