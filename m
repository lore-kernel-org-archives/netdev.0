From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Use after free in __dst_destroy_metrics_generic
Date: Fri, 08 Sep 2017 10:16:53 -0700
Message-ID: <1504891013.15310.76.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org>
         <CAM_iQpXKfUkbyuuZEZXyPrVVCoPaxnCmCARz=Jf0VtU1m9NsZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Lorenzo Colitti <lorenzo@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:38882 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753338AbdIHRQ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 13:16:56 -0400
Received: by mail-pg0-f52.google.com with SMTP id v66so5807355pgb.5
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 10:16:56 -0700 (PDT)
In-Reply-To: <CAM_iQpXKfUkbyuuZEZXyPrVVCoPaxnCmCARz=Jf0VtU1m9NsZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-08 at 09:10 -0700, Cong Wang wrote:
> On Thu, Sep 7, 2017 at 5:52 PM, Subash Abhinov Kasiviswanathan
> <subashab@codeaurora.org> wrote:
> > We are seeing a possible use after free in ip6_dst_destroy.
> >
> > It appears as if memory of the __DST_METRICS_PTR(old) was freed in some path
> > and allocated
> > to ion driver. ion driver has also freed it. Finally the memory is freed by
> > the
> > fib gc and crashes since it is already deallocated.
> 
> Does the attach (compile-only) patch help anything?
> 
> From my _quick_ glance, it seems we miss the refcnt'ing
> right in __dst_destroy_metrics_generic().
> 
> Thanks!

But 4.9 kernels do not have yet the DST_METRICS_REFCOUNTED thing,
since this was added in 4.12
