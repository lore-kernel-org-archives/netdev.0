From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] neigh: increase queue_len_bytes to match
 wmem_default
Date: Tue, 29 Aug 2017 16:11:05 -0700 (PDT)
Message-ID: <20170829.161105.2284035808066192697.davem@davemloft.net>
References: <353aa37f-c62b-f5af-8c89-f67af6509497@gmail.com>
        <1504029689.11498.79.camel@edumazet-glaptop3.roam.corp.google.com>
        <1504044961.11498.100.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41156 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751275AbdH2XLG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 19:11:06 -0400
In-Reply-To: <1504044961.11498.100.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 29 Aug 2017 15:16:01 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Florian reported UDP xmit drops that could be root caused to the
> too small neigh limit.
> 
> Current limit is 64 KB, meaning that even a single UDP socket would hit
> it, since its default sk_sndbuf comes from net.core.wmem_default
> (~212992 bytes on 64bit arches).
> 
> Once ARP/ND resolution is in progress, we should allow a little more
> packets to be queued, at least for one producer.
> 
> Once neigh arp_queue is filled, a rogue socket should hit its sk_sndbuf
> limit and either block in sendmsg() or return -EAGAIN.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks for following up on this.
