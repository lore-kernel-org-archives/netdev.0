From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net/socket: use per af lockdep classes for
 sk queues
Date: Thu, 09 Mar 2017 08:39:14 -0800
Message-ID: <1489077554.28631.22.camel@edumazet-glaptop3.roam.corp.google.com>
References: <81575a876486789bb10ca20e21360fb635269b68.1489054753.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Florian Westphal <fw@strlen.de>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33985 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754497AbdCIRK7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 12:10:59 -0500
Received: by mail-pg0-f67.google.com with SMTP id b5so7440526pgg.1
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 09:09:54 -0800 (PST)
In-Reply-To: <81575a876486789bb10ca20e21360fb635269b68.1489054753.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-09 at 13:54 +0100, Paolo Abeni wrote:
> Currently the sock queue's spin locks get their lockdep
> classes by the default init_spin_lock() initializer:
> all socket families get - usually, see below - a single
> class for rx, another specific class for tx, etc.
> This can lead to false positive lockdep splat, as
> reported by Andrey.
> Moreover there are two separate initialization points
> for the sock queues, one in sk_clone_lock() and one
> in sock_init_data(), so that e.g. the rx queue lock
> can get one of two possible, different classes, depending
> on the socket being cloned or not.
> This change tries to address the above, setting explicitly
> a per address family lockdep class for each queue's
> spinlock. Also, move the duplicated initialization code to a
> single location.

Acked-by: Eric Dumazet <edumazet@google.com>
