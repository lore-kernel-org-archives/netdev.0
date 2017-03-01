From: Eric Dumazet <edumazet@google.com>
Subject: Re: net: use-after-free in neigh_timer_handler/sock_wfree
Date: Wed, 1 Mar 2017 15:15:54 -0800
Message-ID: <CANn89iKERkynDdVA1Wzn4MLfXY9E+c5QRU_qXJT_=Ya4_2og+A@mail.gmail.com>
References: <CACT4Y+Y6T3hLkgEKR5o3spjjSdTj0HXys2qeVZ9CA7MKsZc15Q@mail.gmail.com>
 <CAM_iQpWGAwXu7yO_XsX2Rk-whLvZPLSXd5Btok=L9VSCV5gr=Q@mail.gmail.com>
 <CAM_iQpUdpjXS-yq8McZne+hobWv+pQS-Q0Fk4w0i0mXJQQ8fhQ@mail.gmail.com>
 <CANn89iJyDtZxj0Qksi7P7-FpEW4MDP6HpJTcb9o_yRXJQtym_g@mail.gmail.com> <CAM_iQpVb62N=0veNSvCfgE7RfGcR=EKOgCtyF3c9t5b+Rk_avg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVb62N=0veNSvCfgE7RfGcR=EKOgCtyF3c9t5b+Rk_avg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 1, 2017 at 3:09 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:

>
> But I doubt skb_orphan() is the solution here, shouldn't we just
> update sk->sk_wmem_alloc with skb->truesize changes?

Is it worth it ? Apart from syszkaller I mean...

We started with something that had a real impact on real workloads.

158f323b9868b59967ad96957c4ca388161be321 net: adjust skb->truesize in
pskb_expand_head()

Note that auditing the stack took me a while.
