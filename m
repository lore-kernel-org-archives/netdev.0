From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] fix udp pull header breakage
Date: Mon, 11 Apr 2016 15:31:56 -0400 (EDT)
Message-ID: <20160411.153156.115903140123859564.davem@davemloft.net>
References: <1460043899-56894-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fcooper@ti.com, samanthakumar@google.com,
	willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbcDKTb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 15:31:58 -0400
In-Reply-To: <1460043899-56894-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Thu,  7 Apr 2016 11:44:57 -0400

> Commit e6afc8ace6dd ("udp: remove headers from UDP packets before
> queueing") modified udp receive processing to pull headers before
> enqueue and to not expect them on dequeue.
> 
> The patch missed protocols on top of udp with in-kernel
> implementations that have their own skb_recv_datagram calls and
> dequeue logic. Modify these datapaths to also no longer expect
> a udp header at skb->data.
> 
> Sunrpc and rxrpc are the only two protocols that call this
> function and contain references to udphr (some others, like tipc,
> are based on encap_rcv, which acts before enqueue, before the
> the header pull).

Series applied, thanks for fixing this regression so quickly.
