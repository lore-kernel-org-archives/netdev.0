From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] inet_diag: fix access to tcp cc information
Date: Fri, 17 Apr 2015 10:31:38 +0200
Message-ID: <5530C4EA.9020205@iogearbox.net>
References: <1429233035.7346.240.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48546 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427AbbDQIbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 04:31:43 -0400
In-Reply-To: <1429233035.7346.240.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/17/2015 03:10 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Two different problems are fixed here :
>
> 1) inet_sk_diag_fill() might be called without socket lock held.
>     icsk->icsk_ca_ops can change under us and module be unloaded.
>     -> Access to freed memory.
>     Fix this using rcu_read_lock() to prevent module unload.
>
> 2) Some TCP Congestion Control modules provide information
>     but again this is not safe against icsk->icsk_ca_ops
>     change and nla_put() errors were ignored. Some sockets
>     could not get the additional info if skb was almost full.
>
> Fix this by returning a status from get_info() handlers and
> using rcu protection as well.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks Eric!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
