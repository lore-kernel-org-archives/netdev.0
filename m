From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Use after free in __dst_destroy_metrics_generic
Date: Fri, 08 Sep 2017 10:28:57 -0700
Message-ID: <1504891737.15310.78.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org>
         <CAM_iQpXKfUkbyuuZEZXyPrVVCoPaxnCmCARz=Jf0VtU1m9NsZg@mail.gmail.com>
         <1504891013.15310.76.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170908.101936.1889796764038070767.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, subashab@codeaurora.org,
        netdev@vger.kernel.org, lorenzo@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:37672 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754260AbdIHR27 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 13:28:59 -0400
Received: by mail-pf0-f194.google.com with SMTP id a2so1709534pfj.4
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 10:28:59 -0700 (PDT)
In-Reply-To: <20170908.101936.1889796764038070767.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-08 at 10:19 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 08 Sep 2017 10:16:53 -0700
> 
> > On Fri, 2017-09-08 at 09:10 -0700, Cong Wang wrote:
> >> On Thu, Sep 7, 2017 at 5:52 PM, Subash Abhinov Kasiviswanathan
> >> <subashab@codeaurora.org> wrote:
> >> > We are seeing a possible use after free in ip6_dst_destroy.
> >> >
> >> > It appears as if memory of the __DST_METRICS_PTR(old) was freed in some path
> >> > and allocated
> >> > to ion driver. ion driver has also freed it. Finally the memory is freed by
> >> > the
> >> > fib gc and crashes since it is already deallocated.
> >> 
> >> Does the attach (compile-only) patch help anything?
> >> 
> >> From my _quick_ glance, it seems we miss the refcnt'ing
> >> right in __dst_destroy_metrics_generic().
> >> 
> >> Thanks!
> > 
> > But 4.9 kernels do not have yet the DST_METRICS_REFCOUNTED thing,
> > since this was added in 4.12
> 
> It was backported via -stable.

I hate working on lazy bug reports.
