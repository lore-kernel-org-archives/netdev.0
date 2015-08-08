From: Zang MingJie <zealot0630@gmail.com>
Subject: Re: [BUG] net/ipv4: inconsistent routing table
Date: Sat, 8 Aug 2015 18:36:22 +0800
Message-ID: <CAOrge3q16PRh3TEBaGUeYDhLzWhCCytn+sopTzBr_23cj1gmaw@mail.gmail.com>
References: <CAOrge3qi=7YPRO+VeCDvHsm_7SFC4Y=+JpwQtwAV3zk_q4fEAw@mail.gmail.com>
 <55C1D207.3040905@iogearbox.net> <55C24BAE.7090702@gmail.com>
 <CAOrge3ps456Zw8nnnVitU3t6sEQ=Z=6QzO5Zsp4s17MhhZxyKQ@mail.gmail.com>
 <55C3B8C8.9030507@redhat.com> <CAOrge3oRWUfdMjDgH8PSY_5Y8=KKv2Cr9T3ZLXvuNx6_eq7g0Q@mail.gmail.com>
 <55C4D803.3090108@redhat.com> <878u9njaon.fsf@stressinduktion.org> <CAOrge3qxOb_XrspuvYjV0pDDxUUoqGE3690KUQGoxZMxuD-NRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOrge3qxOb_XrspuvYjV0pDDxUUoqGE3690KUQGoxZMxuD-NRQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Days ago I mistakenly set the gateway address on my box, then add the
default router, after I deleted the address my box can't access
Internet and all things looks fine. It takes me several hours to
figure out it is an kernel bug.

>On Sat, Aug 8, 2015, 1:00 AM Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
>If we could rewind time, we could make local nexthops -EINVAL.

I don't think this is the proper solution. As almost all network OS
considers the routing table recursive, and it's next hop can be any
unicast ip address.

When the next hop is unreachable the entry won't be installed.

I suggest adding a new sysconf entry, when not set, behavior as the
same as now, when set recalculate the fib when necessary

BTW is there any way to check the fib table?
