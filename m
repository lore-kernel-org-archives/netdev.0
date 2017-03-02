From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: use-after-free in neigh_timer_handler/sock_wfree
Date: Wed, 1 Mar 2017 21:25:54 -0800
Message-ID: <CAM_iQpU7AAVPvvw1921=UJ9E8ktvEo3ONaUkDEeD_yVN5+jwSA@mail.gmail.com>
References: <CACT4Y+Y6T3hLkgEKR5o3spjjSdTj0HXys2qeVZ9CA7MKsZc15Q@mail.gmail.com>
 <CAM_iQpWGAwXu7yO_XsX2Rk-whLvZPLSXd5Btok=L9VSCV5gr=Q@mail.gmail.com>
 <CAM_iQpUdpjXS-yq8McZne+hobWv+pQS-Q0Fk4w0i0mXJQQ8fhQ@mail.gmail.com>
 <CANn89iJyDtZxj0Qksi7P7-FpEW4MDP6HpJTcb9o_yRXJQtym_g@mail.gmail.com>
 <CAM_iQpVb62N=0veNSvCfgE7RfGcR=EKOgCtyF3c9t5b+Rk_avg@mail.gmail.com> <CANn89iKERkynDdVA1Wzn4MLfXY9E+c5QRU_qXJT_=Ya4_2og+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35530 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750959AbdCBF1A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 00:27:00 -0500
In-Reply-To: <CANn89iKERkynDdVA1Wzn4MLfXY9E+c5QRU_qXJT_=Ya4_2og+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 1, 2017 at 3:15 PM, Eric Dumazet <edumazet@google.com> wrote:
> On Wed, Mar 1, 2017 at 3:09 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
>>
>> But I doubt skb_orphan() is the solution here, shouldn't we just
>> update sk->sk_wmem_alloc with skb->truesize changes?
>
> Is it worth it ? Apart from syszkaller I mean...
>
> We started with something that had a real impact on real workloads.
>
> 158f323b9868b59967ad96957c4ca388161be321 net: adjust skb->truesize in
> pskb_expand_head()
>
> Note that auditing the stack took me a while.

I don't know how sk refcnt could work correctly without making
sk_wmem_alloc correctly. We certainly could just call skb_orphan()
is we don't need skb->sk any more, probably like the frag case,
but for this case, the neigh one, the skb's sitting in neigh->arp_queue
are not going to be freed unless in failed case, therefore skb->sk
should not be orphaned so early.
