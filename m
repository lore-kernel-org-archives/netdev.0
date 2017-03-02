From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix potential double free issue for
 fastopen_req
Date: Thu, 02 Mar 2017 14:06:31 -0800 (PST)
Message-ID: <20170302.140631.2180464369793479736.davem@davemloft.net>
References: <20170301212948.96840-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ycheng@google.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42534 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750941AbdCCFOi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 00:14:38 -0500
In-Reply-To: <20170301212948.96840-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Wed,  1 Mar 2017 13:29:48 -0800

> From: Wei Wang <weiwan@google.com>
> 
> tp->fastopen_req could potentially be double freed if a malicious
> user does the following:
> 1. Enable TCP_FASTOPEN_CONNECT sockopt and do a connect() on the socket.
> 2. Call connect() with AF_UNSPEC to disconnect the socket.
> 3. Make this socket a listening socket by calling listen().
> 4. Accept incoming connections and generate child sockets. All child
>    sockets will get a copy of the pointer of fastopen_req.
> 5. Call close() on all sockets. fastopen_req will get freed multiple
>    times.
> 
> Fixes: 19f6d3f3c842 ("net/tcp-fastopen: Add new API support")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Wei Wang <weiwan@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, and queued up for -stable.
