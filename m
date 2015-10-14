From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp/dccp: fix behavior of stale SYN_RECV
 request sockets
Date: Tue, 13 Oct 2015 18:27:58 -0700 (PDT)
Message-ID: <20151013.182758.307245280925758827.davem@davemloft.net>
References: <1444781574.4166.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55194 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201AbbJNBL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 21:11:58 -0400
In-Reply-To: <1444781574.4166.12.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Oct 2015 17:12:54 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When a TCP/DCCP listener is closed, its pending SYN_RECV request sockets
> become stale, meaning 3WHS can not complete.
> 
> But current behavior is wrong :
> incoming packets finding such stale sockets are dropped.
> 
> We need instead to cleanup the request socket and perform another
> lookup :
> - Incoming ACK will give a RST answer,
> - SYN rtx might find another listener if available.
> - We expedite cleanup of request sockets and old listener socket.
> 
> Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
