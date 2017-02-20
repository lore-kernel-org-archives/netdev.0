From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: possible deadlock in skb_queue_tail
Date: Mon, 20 Feb 2017 14:51:39 -0800
Message-ID: <CAM_iQpX9gBPOqGo_hwhNmFrUE=R1CdfJvUfkJ+HSK67ybk9LEg@mail.gmail.com>
References: <CAAeHK+yCwsZE9iv+OLHJaU+7FEka8UHy_t5vMqFUBpQ8srBbsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+yCwsZE9iv+OLHJaU+7FEka8UHy_t5vMqFUBpQ8srBbsQ@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 20, 2017 at 5:29 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> other info that might help us debug this:
>
>  Possible unsafe locking scenario:
>
>        CPU0                    CPU1
>        ----                    ----
>   lock(&(&pcpu->lock)->rlock);
>                                lock(&(&list->lock)->rlock#3);
>                                lock(&(&pcpu->lock)->rlock);
>   lock(&(&list->lock)->rlock#3);
>

They are different types of sockets and different lists of skb's,
one is netlink socket the other is udp socket, so I don't think
we could have a deadlock in this scenario, we probably need to
explicitly mark them as different lockdep classes.
