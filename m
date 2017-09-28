From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: in packet_do_bind, test fanout with
 bind_lock held
Date: Thu, 28 Sep 2017 10:25:02 -0700 (PDT)
Message-ID: <20170928.102502.2269082759734068360.davem@davemloft.net>
References: <20170926161937.60597-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49864 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751978AbdI1RZD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 13:25:03 -0400
In-Reply-To: <20170926161937.60597-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Tue, 26 Sep 2017 12:19:37 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Once a socket has po->fanout set, it remains a member of the group
> until it is destroyed. The prot_hook must be constant and identical
> across sockets in the group.
> 
> If fanout_add races with packet_do_bind between the test of po->fanout
> and taking the lock, the bind call may make type or dev inconsistent
> with that of the fanout group.
> 
> Hold po->bind_lock when testing po->fanout to avoid this race.
> 
> I had to introduce artificial delay (local_bh_enable) to actually
> observe the race.
> 
> Fixes: dc99f600698d ("packet: Add fanout support.")
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> Reviewed-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
