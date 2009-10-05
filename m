From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] icmp: No need to call sk_write_space()
Date: Mon, 05 Oct 2009 00:12:10 -0700 (PDT)
Message-ID: <20091005.001210.118975662.davem@davemloft.net>
References: <4ABBEFD3.6060407@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54619
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753617AbZJEHMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 03:12:15 -0400
In-Reply-To: <4ABBEFD3.6060407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 25 Sep 2009 00:16:51 +0200

> We can make icmp messages tx completion callback a litle bit faster.
> 
> Setting SOCK_USE_WRITE_QUEUE sk flag tells sock_wfree() to
> not call sk_write_space() on a socket we know no thread is posssibly
> waiting for write space. (on per cpu kernel internal icmp sockets only)
> 
> This avoids the sock_def_write_space() call and 
> read_lock(&sk->sk_callback_lock)/read_unlock(&sk->sk_callback_lock) calls
> as well.
> 
> We avoid three atomic ops.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6
