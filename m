From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net, sched: fix soft lockup in tc_classify
Date: Thu, 22 Dec 2016 11:05:10 -0800
Message-ID: <CAM_iQpW9Ly+fMEiBtHq4XwUgvt89-5uE2Bwdw1FXJGV3=eY1ZA@mail.gmail.com>
References: <1954223e8b7aa90ff835357e8a3ef7537be33e43.1482337600.git.daniel@iogearbox.net>
 <CAM_iQpXadrGWJYqizEkq+xmMKVV9krrcCWKur=ZCRZBS9Mx_8w@mail.gmail.com>
 <CAM_iQpX3Sk_YGDmvY-yj0CxPbG5qfT7P7ioNgY5Lb_DqsTWh6Q@mail.gmail.com>
 <585ADFEB.3030206@iogearbox.net> <CAM_iQpUEUmJpjQYV7HV+4NVtGe6D-yZs6=YizcDtf7dogkNR0Q@mail.gmail.com>
 <585AEF24.4070800@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Shahar Klein <shahark@mellanox.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Roi Dayan <roid@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33916 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750979AbcLVTFb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 14:05:31 -0500
Received: by mail-qk0-f196.google.com with SMTP id t184so14364244qkd.1
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2016 11:05:31 -0800 (PST)
In-Reply-To: <585AEF24.4070800@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 21, 2016 at 1:07 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>
> Ok, you mean for net. In that case I prefer the smaller sized fix to be
> honest. It also covers everything from the point where we fetch the chain
> via cops->tcf_chain() to the end of the function, which is where most of
> the complexity resides, and only the two mentioned commits do the relock,

I really wish the problem is only about relocking, but look at the code,
the deeper reason why we have this bug is the complexity of the logic
inside tc_ctl_tfilter(): 1) the replay logic is hard, we have to make it
idempotent; 2) the request logic itself is hard, because of tc filter design
and implementation.

This is why I worry more than just relocking.

> so as a fix I think it's fine as-is. As mentioned, if there's need to
> refactor tc_ctl_tfilter() net-next would be better, imho.

Refactor is a too strong word, just moving the replay out is not a refactor.
The end result will be still smaller than your commit d936377414fadbafb4,
which is already backported to stable.
