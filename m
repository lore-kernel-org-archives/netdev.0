From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net/socket: use per af lockdep classes for
 sk queues
Date: Thu, 09 Mar 2017 16:37:09 -0800 (PST)
Message-ID: <20170309.163709.641014644590923924.davem@davemloft.net>
References: <81575a876486789bb10ca20e21360fb635269b68.1489054753.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, andreyknvl@google.com,
        xiyou.wangcong@gmail.com, fw@strlen.de
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46928 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753578AbdCJAhP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 19:37:15 -0500
In-Reply-To: <81575a876486789bb10ca20e21360fb635269b68.1489054753.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Thu,  9 Mar 2017 13:54:08 +0100

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
> v1 -> v2:
>  - renamed the init helper
> 
> rfc -> v1:
>  - no changes, tested with several different workload
> 
> Suggested-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thank you.
