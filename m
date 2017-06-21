From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sock: avoid dirtying incoming_cpu if not
 needed
Date: Wed, 21 Jun 2017 11:44:35 -0400 (EDT)
Message-ID: <20170621.114435.1437675833962204147.davem@davemloft.net>
References: <a5af66d2a71c1fe229bbeee40db4a9aa48dd969a.1498038209.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40470 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752992AbdFUQUs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 12:20:48 -0400
In-Reply-To: <a5af66d2a71c1fe229bbeee40db4a9aa48dd969a.1498038209.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Wed, 21 Jun 2017 11:45:31 +0200

> for connected socket, the incoming_cpu field in the sock struct
> is not going to change frequently, but we are setting it
> unconditionally for each packet.
> 
> Since sk_incoming_cpu and sk_flags share the same cacheline,
> and the latter is access by udp_recvmsg(), this cause a cache
> miss for each packet for UDP connected socket.
> 
> With this patch, we set the incoming cpu field only when the
> ingress cpu really changes.
> 
> This gives a small but measurable performance improvement for
> connected UDP socket.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied.
