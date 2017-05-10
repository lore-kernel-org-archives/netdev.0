From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Wed, 10 May 2017 09:32:12 -0700
Message-ID: <CAM_iQpVFoyDCemfr_fVD7+zN6-Cb5sv_c9XRqA7Oa9sx5cj2fg@mail.gmail.com>
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
 <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com> <1494373805.7796.98.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33528 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754335AbdEJQci (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 12:32:38 -0400
Received: by mail-wm0-f67.google.com with SMTP id y10so975673wmh.0
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 09:32:38 -0700 (PDT)
In-Reply-To: <1494373805.7796.98.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 9, 2017 at 4:50 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2017-05-09 at 16:35 -0700, Cong Wang wrote:
>
>> All of them take RCU read lock, so, as I explained in the code comment,
>> they all should be fine because of synchronize_net() on unregister path.
>> Do you see anything otherwise?
>
> They might take rcu lock, but compiler is still allowed to read
> fi->fib_dev multiple times, and crashes might happen.
>
> You will need to audit all code and fix it, using proper
> rcu_dereference() or similar code ensuring compiler wont do stupid
> things.
>

Point taken. But without my patch, nh_dev is supposed to be protected
by RCU too, it is freed in a rcu callback and dereferenced like:

struct in_device *in_dev = __in_dev_get_rcu(nh->nh_dev);
