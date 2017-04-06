From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/ipv4: use-after-free in ipv4_mtu
Date: Thu, 06 Apr 2017 03:49:10 -0700
Message-ID: <1491475750.10124.72.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAeHK+zJ20r8O=MhPY69UPK7sObODp2ByK5136JXgw5U9SMofw@mail.gmail.com>
         <CANn89iKuT+VBZqbJ4=hTAgUbnhuZ0berg0PK+imd1CKuWLy1eQ@mail.gmail.com>
         <CAM_iQpUittpMt-8BpNePWv7iTDasCZuNYTEPnu=K-4sFK5qiBg@mail.gmail.com>
         <1491360338.10124.39.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpUk_=oeGoYLb4DGc2+mNw+3Z08mw4wVNKAaDZgsbB1i+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:35196 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754302AbdDFKtN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 06:49:13 -0400
In-Reply-To: <CAM_iQpUk_=oeGoYLb4DGc2+mNw+3Z08mw4wVNKAaDZgsbB1i+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-05 at 15:33 -0700, Cong Wang wrote:

> Good find! I missed the refcnt in rt_set_nexthop() before that commit.
> 
> We need to revert that commit to restore the refcnt for fib_info.

Well, there are other spots , in decnet and IPv6.

This is why my original mail stated the problem was in the calls to :

dst_init_metrics(&rt->dst, fi->fib_metrics, true);

Lets do not think in "reverting" spirit, but adding the missing bits.

The problem here is that the metrics should not be freed until last user
is gone.

So maybe a refcount should be added to metrics, and we do not have to
add a fib pointer again in all dsts.

Thanks.
