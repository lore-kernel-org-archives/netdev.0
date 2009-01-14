From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Tue, 13 Jan 2009 16:05:05 -0800 (PST)
Message-ID: <20090113.160505.178961721.davem@davemloft.net>
References: <4967D36E.6020207@cosmosbay.com>
	<20090109225309.GC4819@1wt.eu>
	<4967DF10.2010107@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, ben@zeus.com, jarkao2@gmail.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52121
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752722AbZANAFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 19:05:04 -0500
In-Reply-To: <4967DF10.2010107@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 10 Jan 2009 00:34:40 +0100

> David, do you think we still must call __tcp_splice_read() only once
> in tcp_splice_read() if SPLICE_F_NONBLOCK is set ?

You seem to be working that out in another thread :-)

> [PATCH] tcp: splice as many packets as possible at once
> 
> As spotted by Willy Tarreau, current splice() from tcp socket to pipe is not
> optimal. It processes at most one segment per call.
> This results in low performance and very high overhead due to syscall rate
> when splicing from interfaces which do not support LRO.
> 
> Willy provided a patch inside tcp_splice_read(), but a better fix
> is to let tcp_read_sock() process as many segments as possible, so
> that tcp_rcv_space_adjust() and tcp_cleanup_rbuf() are called less
> often.
> 
> With this change, splice() behaves like tcp_recvmsg(), being able
> to consume many skbs in one system call. With typical 1460 bytes
> of payload per frame, that means splice(SPLICE_F_NONBLOCK) can return
> 16*1460 = 23360 bytes.
> 
> Signed-off-by: Willy Tarreau <w@1wt.eu>
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

I've applied this, thanks!
