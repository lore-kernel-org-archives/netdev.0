From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC net-next] net ipv6: convert fib6_table rwlock to a percpu
 lock
Date: Mon, 31 Jul 2017 16:10:07 -0700
Message-ID: <20170731161007.61c2d958@xeon-e3>
References: <1a5ad2f0585aa66496b27e123d1c38b75552df4c.1501520674.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com,
        Shaohua Li <shli@fb.com>, Wei Wang <weiwan@google.com>
To: Shaohua Li <shli@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:38855 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751217AbdGaXKJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 19:10:09 -0400
Received: by mail-pg0-f43.google.com with SMTP id l64so89628pge.5
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 16:10:09 -0700 (PDT)
In-Reply-To: <1a5ad2f0585aa66496b27e123d1c38b75552df4c.1501520674.git.shli@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Jul 2017 10:18:57 -0700
Shaohua Li <shli@kernel.org> wrote:

> From: Shaohua Li <shli@fb.com>
> 
> In a syn flooding test, the fib6_table rwlock is a significant
> bottleneck. While converting the rwlock to rcu sounds straighforward,
> but is very challenging if it's possible. A percpu spinlock is quite
> trival for this problem since updating the routing table is a rare
> event. In my test, the server receives around 1.5 Mpps in syn flooding
> test without the patch in a dual sockets and 56-CPU system. With the
> patch, the server receives around 3.8Mpps, and perf report doesn't show
> the locking issue.
> 
> Cc: Wei Wang <weiwan@google.com>

You just reinvented brlock...

RCU is not that hard, why not do it right?
