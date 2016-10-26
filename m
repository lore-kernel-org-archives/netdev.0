From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: fix IP_CHECKSUM handling
Date: Wed, 26 Oct 2016 17:34:20 -0400 (EDT)
Message-ID: <20161026.173420.159369189889100689.davem@davemloft.net>
References: <1477270986.7065.102.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samanthakumar@google.com,
        willemb@google.com, tom@herbertland.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42390 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933361AbcJZVeW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 17:34:22 -0400
In-Reply-To: <1477270986.7065.102.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 23 Oct 2016 18:03:06 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> First bug was added in commit ad6f939ab193 ("ip: Add offset parameter to
> ip_cmsg_recv") : Tom missed that ipv4 udp messages could be received on
> AF_INET6 socket. ip_cmsg_recv(msg, skb) should have been replaced by
> ip_cmsg_recv_offset(msg, skb, sizeof(struct udphdr));
> 
> Then commit e6afc8ace6dd ("udp: remove headers from UDP packets before
> queueing") forgot to adjust the offsets now UDP headers are pulled
> before skb are put in receive queue.
> 
> Fixes: ad6f939ab193 ("ip: Add offset parameter to ip_cmsg_recv")
> Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
