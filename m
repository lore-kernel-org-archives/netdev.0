From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next V3 4/4] net/sched: Introduce act_tunnel_key
Date: Fri, 26 Aug 2016 11:26:48 -0700
Message-ID: <CAM_iQpXvS5KQ-3AaPjtHHRrexr48tTMSXpuJPFkOsz6caJP5EA@mail.gmail.com>
References: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
 <1472141627-27339-5-git-send-email-hadarh@mellanox.com> <1472147334.14381.149.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36526 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751610AbcHZS1K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 14:27:10 -0400
Received: by mail-wm0-f66.google.com with SMTP id i138so309058wmf.3
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 11:27:09 -0700 (PDT)
In-Reply-To: <1472147334.14381.149.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2016 at 10:48 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Please find a better way than using a spinlock in this hot path.
>
> Maybe looking at
> 2ee22a90c7afac265bb6f7abea610b938195e2b8 net_sched: act_mirred: remove spinlock in fast path
> 56e5d1ca183d8616fab377d7d466c244b4dbb3b9 net_sched: act_gact: remove spinlock in fast path

This is not necessary at the moment, because:

1) Currently there are only a few actions using lockless, and they are
questionable, as we already discussed before, there could be some
race condition when you modify an existing action.

2) We need to change the tc action API in order to fully support RCU,
which is what I have been working on these days. I should come up
with something next Monday (if not this weekend).

So for this patchset, using spinlock is fine, just as many other actions.
I will take care of it later.
