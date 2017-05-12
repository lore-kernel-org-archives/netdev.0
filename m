From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Fri, 12 May 2017 10:49:13 -0700
Message-ID: <CAM_iQpXcj149a79w6x5NXAAwZnfjwd0RJ_x7YtdrqfecEmPUiw@mail.gmail.com>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
 <20170508.143557.105629611489969352.davem@davemloft.net> <1494288080.7796.59.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170508.212211.1291611254198273979.davem@davemloft.net> <1494296302.7796.61.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpWQoLppsMfDOQWsdifGd56CAY24tCNm0Jm02QCe7ZThOw@mail.gmail.com>
 <1494348962.7796.88.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXADa6AyQ3X-EbmRPGCQArgPWygvHMYgWtfUYV082oF3Q@mail.gmail.com>
 <CAM_iQpVhdzeen+ZJ3jyK7Qb=yVuoRSZ7BFB3RoVMShY8KPBTZA@mail.gmail.com>
 <1494370367.7796.92.camel@edumazet-glaptop3.roam.corp.google.com>
 <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com>
 <1494371348.7796.95.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com>
 <alpine.LFD.2.20.1705100937330.1938@ja.home.ssi.bg> <CAM_iQpX22qTqo4yfM_Je1bvJHxjAGK_tvm5KgQSnJzsYq7K55Q@mail.gmail.com>
 <alpine.LFD.2.20.1705102141320.1928@ja.home.ssi.bg> <CAM_iQpW0fJJXPS=FoTf-o4f5-mOC=mZYNP8=uqiUOmvX+CDwWw@mail.gmail.com>
 <CAM_iQpWxDKHF4N1xor7qj+5s91GrctgcGnzN0buw18qs7__-gQ@mail.gmail.com> <1494564948.7796.128.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38497 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757496AbdELRte (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 13:49:34 -0400
Received: by mail-wm0-f44.google.com with SMTP id 142so78952946wma.1
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 10:49:34 -0700 (PDT)
In-Reply-To: <1494564948.7796.128.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 11, 2017 at 9:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-05-11 at 18:22 -0700, Cong Wang wrote:
>> On Thu, May 11, 2017 at 5:07 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> > So, if I understand you correctly it is safe to NULL'ing
>> > nh_dev in NETDEV_UNREGISTER_FINAL, right?
>> >
>> > If still not, how about transfer nh_dev's to loopback_dev
>> > too in NETDEV_UNREGISTER? Like we transfer dst->dev.
>> >
>> > I don't want to touch the fast path to check for NULL, as
>> > it will change more code and slow down performance.
>>
>> Finally I come up with the attached patch. Please let me know if
>> I still miss anything.
>
> You have not addressed my prior feedback, unless I am mistaken ?
>
> fib_route_seq_show() and others do not expect fi->fib_dev suddenly
> becoming NULL.
>
> RCU contract is more complicated than simply adding rcu grace period
> before delete.
>

If you mean the lack of rcu_dereference() in fib_route_seq_show() ,
yeah, I don't fix it because I think it should be in a separate patch,
it is not this patch which introduces RCU to nh_dev as I explained
previously.

Or you mean anything else?
