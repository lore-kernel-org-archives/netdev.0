From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udplite: call proper backlog handlers
Date: Thu, 24 Nov 2016 15:32:42 -0500 (EST)
Message-ID: <20161124.153242.718978368287315233.davem@davemloft.net>
References: <CAAeHK+zZSc28e4LMg-YvEztKO4X0VVxqCStkZW8LL4ZA_rYyMQ@mail.gmail.com>
        <CANn89iKewy1iMa=dUGpE=8UjHUi4o=s=6P_-ngLr_S_ZDByTwg@mail.gmail.com>
        <1479834405.8455.437.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, herbert@gondor.apana.org.au, bcrl@kvack.org,
        willemb@google.com, andreyknvl@google.com,
        samanthakumar@google.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479834405.8455.437.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Nov 2016 09:06:45 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> In commits 93821778def10 ("udp: Fix rcv socket locking") and
> f7ad74fef3af ("net/ipv6/udp: UDP encapsulation: break backlog_rcv into
> __udpv6_queue_rcv_skb") UDP backlog handlers were renamed, but UDPlite
> was forgotten.
> 
> This leads to crashes if UDPlite header is pulled twice, which happens
> starting from commit e6afc8ace6dd ("udp: remove headers from UDP packets
> before queueing")
> 
> Bug found by syzkaller team, thanks a lot guys !
> 
> Note that backlog use in UDP/UDPlite is scheduled to be removed starting
> from linux-4.10, so this patch is only needed up to linux-4.9
> 
> Fixes: 93821778def1 ("udp: Fix rcv socket locking")
> Fixes: f7ad74fef3af ("net/ipv6/udp: UDP encapsulation: break backlog_rcv into __udpv6_queue_rcv_skb")
> Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable, thanks Eric.
