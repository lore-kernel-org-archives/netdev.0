From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet_diag: fix access to tcp cc information
Date: Fri, 17 Apr 2015 13:28:52 -0400 (EDT)
Message-ID: <20150417.132852.665045419921409481.davem@davemloft.net>
References: <1429233035.7346.240.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45290 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754946AbbDQR2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 13:28:54 -0400
In-Reply-To: <1429233035.7346.240.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Apr 2015 18:10:35 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Two different problems are fixed here :
> 
> 1) inet_sk_diag_fill() might be called without socket lock held.
>    icsk->icsk_ca_ops can change under us and module be unloaded.
>    -> Access to freed memory.
>    Fix this using rcu_read_lock() to prevent module unload.
> 
> 2) Some TCP Congestion Control modules provide information
>    but again this is not safe against icsk->icsk_ca_ops
>    change and nla_put() errors were ignored. Some sockets
>    could not get the additional info if skb was almost full.
> 
> Fix this by returning a status from get_info() handlers and
> using rcu protection as well.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
