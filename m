From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: clear pfmemalloc on outgoing skb
Date: Fri, 03 Feb 2017 16:24:08 -0500 (EST)
Message-ID: <20170203.162408.851464918447697481.davem@davemloft.net>
References: <1485983078-2372-1-git-send-email-jbacik@fb.com>
        <1486096808.21871.67.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbacik@fb.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53780 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752331AbdBCVYJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:24:09 -0500
In-Reply-To: <1486096808.21871.67.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Feb 2017 20:40:08 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Josef Bacik diagnosed following problem :
> 
>    I was seeing random disconnects while testing NBD over loopback.
>    This turned out to be because NBD sets pfmemalloc on it's socket,
>    however the receiving side is a user space application so does not
>    have pfmemalloc set on its socket. This means that
>    sk_filter_trim_cap will simply drop this packet, under the
>    assumption that the other side will simply retransmit. Well we do
>    retransmit, and then the packet is just dropped again for the same
>    reason.
> 
> It seems the better way to address this problem is to clear pfmemalloc
> in the TCP transmit path. pfmemalloc strict control really makes sense
> on the receive path. 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Josef Bacik <jbacik@fb.com>

Applied.
