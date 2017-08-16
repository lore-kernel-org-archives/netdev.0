From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ipv6: fix NULL dereference in ip6_route_dev_notify()
Date: Wed, 16 Aug 2017 11:50:58 -0700
Message-ID: <CAM_iQpXjhUWPC1goetn2bwG=SPeqWcz+bZvMVWOD_2cbDcG-qw@mail.gmail.com>
References: <1502795391.4936.60.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35637 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751611AbdHPSvT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 14:51:19 -0400
Received: by mail-pg0-f43.google.com with SMTP id v189so26618414pgd.2
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 11:51:19 -0700 (PDT)
In-Reply-To: <1502795391.4936.60.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 15, 2017 at 4:09 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Based on a syzkaller report [1], I found that a per cpu allocation
> failure in snmp6_alloc_dev() would then lead to NULL dereference in
> ip6_route_dev_notify().
>
> It seems this is a very old bug, thus no Fixes tag in this submission.


It should be introduced by my commit which introduces these
in6_dev_put().

>
> Let's add in6_dev_put_clear() helper, as we will probably use
> it elsewhere (once available/present in net-next)
>

I don't understand why not just check ->rt6i_idev against NULL
for -net?

Ideally, we should let notifiers handle this, when we fail in one
of those notifiers, we should only rollback those succeeded
rather than all of them, but this may require more changes.

Thanks.
