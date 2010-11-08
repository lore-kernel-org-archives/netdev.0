From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] af_unix: optimize unix_dgram_poll()
Date: Mon, 08 Nov 2010 13:44:44 -0800 (PST)
Message-ID: <20101108.134444.242133347.davem@davemloft.net>
References: <1288539505.2660.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davidel@xmailserver.org,
	alban.crequy@collabora.co.uk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57781
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755751Ab0KHVoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 16:44:20 -0500
In-Reply-To: <1288539505.2660.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 31 Oct 2010 16:38:25 +0100

> unix_dgram_poll() is pretty expensive to check POLLOUT status, because
> it has to lock the socket to get its peer, take a reference on the peer
> to check its receive queue status, and queue another poll_wait on
> peer_wait. This all can be avoided if the process calling
> unix_dgram_poll() is not interested in POLLOUT status. It makes
> unix_dgram_recvmsg() faster by not queueing irrelevant pollers in
> peer_wait.
> 
> On a test program provided by Alan Crequy :
> 
> Before:
> 
> real    0m0.211s
> user    0m0.000s
> sys     0m0.208s
> 
> After:
> 
> real    0m0.044s
> user    0m0.000s
> sys     0m0.040s
> 
> Suggested-by: Davide Libenzi <davidel@xmailserver.org>
> Reported-by: Alban Crequy <alban.crequy@collabora.co.uk>
> Acked-by: Davide Libenzi <davidel@xmailserver.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
