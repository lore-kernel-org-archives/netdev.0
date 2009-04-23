From: Christoph Lameter <cl@linux.com>
Subject: Re: about latencies
Date: Thu, 23 Apr 2009 18:06:43 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904231803550.28139@qirst.com>
References: <49F0E579.5030200@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:48406 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759878AbZDWWPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 18:15:23 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9AE6A82C23F
	for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 18:25:55 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 42Lwn2Szak6w for <netdev@vger.kernel.org>;
	Thu, 23 Apr 2009 18:25:55 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 776ED82C251
	for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 18:25:49 -0400 (EDT)
In-Reply-To: <49F0E579.5030200@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Apr 2009, Eric Dumazet wrote:

> sock_wfree()
>   -> sock_def_write_space()
>      -> _read_lock()
>      -> __wake_up_sync_key()
>   and lot of functions calls to wakeup the task, for nothing since it
> will just schedule again. Lot of cache lines dirtied...

Right.

> We could improve this.
>
> 1) dst_release at xmit time, should save a cache line ping-pong on general case
> 2) sock_wfree() in advance, done at transmit time (generally the thread/cpu doing the send)
> 3) changing bnx2_poll_work() to first call bnx2_rx_int(), then bnx2_tx_int() to consume tx.

Good idea that would get rid of the IRQ delay if the process is asking for
data. We'd only be batching if no one is asking for data?

> What do you think ?

Sounds good.
