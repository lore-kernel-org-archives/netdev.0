From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] af_unix: fix unix_dgram_poll() behavior for
 EPOLLOUT event
Date: Mon, 08 Nov 2010 13:44:38 -0800 (PST)
Message-ID: <20101108.134438.15240252.davem@davemloft.net>
References: <1288444678.2680.966.camel@edumazet-laptop>
	<20101030224703.065e70f6@chocolatine.cbg.collabora.co.uk>
	<1288539383.2660.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alban.crequy@collabora.co.uk, netdev@vger.kernel.org,
	davidel@xmailserver.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57776
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755753Ab0KHVoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 16:44:14 -0500
In-Reply-To: <1288539383.2660.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 31 Oct 2010 16:36:23 +0100

> [PATCH 1/2] af_unix: fix unix_dgram_poll() behavior for EPOLLOUT event
> 
> Alban Crequy reported a problem with connected dgram af_unix sockets and
> provided a test program. epoll() would miss to send an EPOLLOUT event
> when a thread unqueues a packet from the other peer, making its receive
> queue not full.
> 
> This is because unix_dgram_poll() fails to call sock_poll_wait(file,
> &unix_sk(other)->peer_wait, wait);
> if the socket is not writeable at the time epoll_ctl(ADD) is called. 
> 
> We must call sock_poll_wait(), regardless of 'writable' status, so that
> epoll can be notified later of states changes.
> 
> Misc: avoids testing twice (sk->sk_shutdown & RCV_SHUTDOWN)
> 
> Reported-by: Alban Crequy <alban.crequy@collabora.co.uk>
> Cc: Davide Libenzi <davidel@xmailserver.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
