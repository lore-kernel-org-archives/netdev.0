From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] tcp: diag: Dont report negative values
 for rx queue
Date: Thu, 03 Dec 2009 16:06:23 -0800 (PST)
Message-ID: <20091203.160623.238913212.davem@davemloft.net>
References: <4B180970.4020609@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50754
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754737AbZLDAGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 19:06:16 -0500
In-Reply-To: <4B180970.4020609@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Dec 2009 19:54:40 +0100

> Both netlink and /proc/net/tcp interfaces can report transient
> negative values for rx queue.
> 
> ss ->
> State   Recv-Q Send-Q  Local Address:Port  Peer Address:Port
> ESTAB   -6     6       127.0.0.1:45956     127.0.0.1:3333 
> 
> netstat ->
> tcp   4294967290      6 127.0.0.1:37784  127.0.0.1:3333 ESTABLISHED
> 
> This is because we dont lock socket while computing 
> tp->rcv_nxt - tp->copied_seq,
> and another CPU can update copied_seq before rcv_next in RX path.
> 
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
