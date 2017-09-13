From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp/dccp: remove reqsk_put() from
 inet_child_forget()
Date: Tue, 12 Sep 2017 20:39:14 -0700 (PDT)
Message-ID: <20170912.203914.1695474417183964442.davem@davemloft.net>
References: <1505100843.15310.113.camel@edumazet-glaptop3.roam.corp.google.com>
        <CAASgV=txONWMR2_au12ASV40mP0mf6O=4DLoq3+FfGubqG4NQQ@mail.gmail.com>
        <1505170718.15310.134.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sp3485@columbia.edu, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, andrew.aday@columbia.edu
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37134 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751858AbdIMDjO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 23:39:14 -0400
In-Reply-To: <1505170718.15310.134.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Sep 2017 15:58:38 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Back in linux-4.4, I inadvertently put a call to reqsk_put() in
> inet_child_forget(), forgetting it could be called from two different
> points.
> 
> In the case it is called from inet_csk_reqsk_queue_add(), we want to
> keep the reference on the request socket, since it is released later by
> the caller (tcp_v{4|6}_rcv())
> 
> This bug never showed up because atomic_dec_and_test() was not signaling
> the underflow, and SLAB_DESTROY_BY RCU semantic for request sockets
> prevented the request to be put in quarantine.
> 
> Recent conversion of socket refcount from atomic_t to refcount_t finally
> exposed the bug.
> 
> So move the reqsk_put() to inet_csk_listen_stop() to fix this.
> 
> Thanks to Shankara Pailoor for using syzkaller and providing
> a nice set of .config and C repro.
 ...
> Fixes: ebb516af60e1 ("tcp/dccp: fix race at listener dismantle phase")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Shankara Pailoor <sp3485@columbia.edu>
> Tested-by: Shankara Pailoor <sp3485@columbia.edu>

Applied and queued up for -stable.

Thanks.
