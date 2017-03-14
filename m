From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: net: deadlock between ip_expire/sch_direct_xmit
Date: Tue, 14 Mar 2017 16:34:18 +0100
Message-ID: <1489505658.2413.12.camel@redhat.com>
References: <CACT4Y+ZrHr0Cqw5RPeZ6QW16auOPyKSCOea6AciHBswAT3t14Q@mail.gmail.com>
         <1489502504.28631.115.camel@edumazet-glaptop3.roam.corp.google.com>
         <1489503785.2413.10.camel@redhat.com>
         <CANn89iLB8UvDCQVoWZHeDKXX6te0x7C9NGsoJ_X9+8cF+mm0cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iLB8UvDCQVoWZHeDKXX6te0x7C9NGsoJ_X9+8cF+mm0cg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-03-14 at 08:09 -0700, Eric Dumazet wrote:
> On Tue, Mar 14, 2017 at 8:03 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> 
> > I'm wondering if we really need to keep the fragment queue lock held
> > while sending the icmp packet ? we hold a reference to the struct, so
> > it can't be deleted, and AFAICS after ipq_kill() nobody else could
> > access/modify that queue.
> > 
> > That lock is there pretty much forever, but perhaps is only a leftover
> > and we can release it just after ipq_kill() ?
> 
> Maybe, but for peace of mind I would make sure this code path owns the
> skb (head) before releasing the lock.
> 
> Seems something to try for net-next ?

Agreed.

I asked because I was in doubt I missed something obvious.

Thank you,

Paolo
