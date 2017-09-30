From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-ipv6: add support for sockopt(SOL_IPV6,
 IPV6_FREEBIND)
Date: Sat, 30 Sep 2017 05:31:10 +0100 (WEST)
Message-ID: <20170930.053110.46183655550876992.davem@davemloft.net>
References: <20170927043242.151591-1-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Cc: maze@google.com, netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40106 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750944AbdI3EbM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 00:31:12 -0400
In-Reply-To: <20170927043242.151591-1-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej ¯enczykowski <zenczykowski@gmail.com>
Date: Tue, 26 Sep 2017 21:32:42 -0700

> From: Maciej ¯enczykowski <maze@google.com>
> 
> So far we've been relying on sockopt(SOL_IP, IP_FREEBIND) being usable
> even on IPv6 sockets.
> 
> However, it turns out it is perfectly reasonable to want to set freebind
> on an AF_INET6 SOCK_RAW socket - but there is no way to set any SOL_IP
> socket option on such a socket (they're all blindly errored out).
> 
> One use case for this is to allow spoofing src ip on a raw socket
> via sendmsg cmsg.
> 
> Tested:
>   built, and booted
>   # python
>   >>> import socket
>   >>> SOL_IP = socket.SOL_IP
>   >>> SOL_IPV6 = socket.IPPROTO_IPV6
>   >>> IP_FREEBIND = 15
>   >>> IPV6_FREEBIND = 78
>   >>> s = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM, 0)
>   >>> s.getsockopt(SOL_IP, IP_FREEBIND)
>   0
>   >>> s.getsockopt(SOL_IPV6, IPV6_FREEBIND)
>   0
>   >>> s.setsockopt(SOL_IPV6, IPV6_FREEBIND, 1)
>   >>> s.getsockopt(SOL_IP, IP_FREEBIND)
>   1
>   >>> s.getsockopt(SOL_IPV6, IPV6_FREEBIND)
>   1
> 
> Signed-off-by: Maciej ¯enczykowski <maze@google.com>

Applied to net-next, thanks.
