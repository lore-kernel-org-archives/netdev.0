From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: rfs: add a jump label
Date: Thu, 08 Dec 2016 10:31:13 -0800
Message-ID: <1481221873.4930.123.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481128150.4930.25.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161208.131900.434329215014851517.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pabeni@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34813 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752419AbcLHScR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 13:32:17 -0500
Received: by mail-pg0-f65.google.com with SMTP id e9so27505793pgc.1
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 10:32:15 -0800 (PST)
In-Reply-To: <20161208.131900.434329215014851517.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-08 at 13:19 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 07 Dec 2016 08:29:10 -0800
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > RFS is not commonly used, so add a jump label to avoid some conditionals
> > in fast path.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied, but I wonder how effective this will really be in the long run.

I guess this applies to about all jump labels.

As soon as the attribute is per namespace, we no longer can use them.

A conditional cost really depends on the expression complexity
(including cache line misses)

TCP stack might benefit from jump labels, like sysctl_tcp_low_latency
which is often set to 1 on hosts mostly using epoll()/poll()/select()
instead of blocking read()/recvmsg()
