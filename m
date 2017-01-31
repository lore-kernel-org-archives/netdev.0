From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: suspicious RCU usage in nf_hook
Date: Tue, 31 Jan 2017 07:44:58 -0800
Message-ID: <1485877498.6360.115.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+bpmwj1WH7g6inQBm+7PvHepv9tTmYBUqkJYFvquGDYCQ@mail.gmail.com>
         <1485560124.6360.74.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpVvBPhP4q=Egsaoqf8ym-73jLZow8xDMbOq9RhYmL5XAQ@mail.gmail.com>
         <1485567090.6360.92.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpXiQMH1zMJM6sYFNUySUYjaHnLZ3T2d34GwCMQ9u6RkwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <edumazet@google.com>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXiQMH1zMJM6sYFNUySUYjaHnLZ3T2d34GwCMQ9u6RkwQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-01-30 at 22:19 -0800, Cong Wang wrote:

> 
> The context is process context (TX path before hitting qdisc), and
> BH is not disabled, so in_interrupt() doesn't catch it. Hmm, this
> makes me thinking maybe we really need to disable BH in this
> case for nf_hook()? But it is called in RX path too, and BH is
> already disabled there.

ipt_do_table() and similar netfilter entry points disable BH.

Maybe it is done too late.
