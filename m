From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH RFC] net/socket: use per af lockdep classes for sk queues
Date: Fri, 24 Feb 2017 10:14:47 -0800
Message-ID: <CAM_iQpV3cmUa3YwQ=9Mg78oXJsh8pnWgnejf3ddt+aZx2rCEUg@mail.gmail.com>
References: <a6eb8644399fef96b27dae1a917274c394caab2f.1487942713.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Florian Westphal <fw@strlen.de>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38748 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750995AbdBXSPJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 13:15:09 -0500
Received: by mail-wm0-f48.google.com with SMTP id r141so20775529wmg.1
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 10:15:08 -0800 (PST)
In-Reply-To: <a6eb8644399fef96b27dae1a917274c394caab2f.1487942713.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 24, 2017 at 5:29 AM, Paolo Abeni <pabeni@redhat.com> wrote:
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

Looks good.

Thanks for working on it!
