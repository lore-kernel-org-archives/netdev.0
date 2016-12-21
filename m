From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: add a missing barrier in tcp_tasklet_func()
Date: Wed, 21 Dec 2016 15:31:05 -0500 (EST)
Message-ID: <20161221.153105.1045097172899590296.davem@davemloft.net>
References: <1482327763.8944.26.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, madalin.bucur@nxp.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35368 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753842AbcLUUbH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 15:31:07 -0500
In-Reply-To: <1482327763.8944.26.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Dec 2016 05:42:43 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Madalin reported crashes happening in tcp_tasklet_func() on powerpc64
> 
> Before TSQ_QUEUED bit is cleared, we must ensure the changes done
> by list_del(&tp->tsq_node); are committed to memory, otherwise
> corruption might happen, as an other cpu could catch TSQ_QUEUED
> clearance too soon.
> 
> We can notice that old kernels were immune to this bug, because
> TSQ_QUEUED was cleared after a bh_lock_sock(sk)/bh_unlock_sock(sk)
> section, but they could have missed a kick to write additional bytes,
> when NIC interrupts for a given flow are spread to multiple cpus.
> 
> Affected TCP flows would need an incoming ACK or RTO timer to add more
> packets to the pipe. So overall situation should be better now.
> 
> Fixes: b223feb9de2a ("tcp: tsq: add shortcut in tcp_tasklet_func()")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Madalin Bucur <madalin.bucur@nxp.com>
> Tested-by: Madalin Bucur <madalin.bucur@nxp.com>

Applied, thanks Eric.
