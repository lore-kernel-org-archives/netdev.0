From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] net/socket: use per af lockdep classes for sk queues
Date: Fri, 24 Feb 2017 09:50:43 -0800
Message-ID: <1487958643.9415.112.camel@edumazet-glaptop3.roam.corp.google.com>
References: <a6eb8644399fef96b27dae1a917274c394caab2f.1487942713.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Florian Westphal <fw@strlen.de>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35490 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdBXRuq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 12:50:46 -0500
Received: by mail-pg0-f65.google.com with SMTP id 1so3791980pgz.2
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 09:50:45 -0800 (PST)
In-Reply-To: <a6eb8644399fef96b27dae1a917274c394caab2f.1487942713.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-02-24 at 14:29 +0100, Paolo Abeni wrote:
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
> 
> Suggested-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---

I have not tested the patch, but it looks pretty reasonable to me,
thanks !
