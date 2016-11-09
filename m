From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sock: fix sendmmsg for partial sendmsg
Date: Wed, 09 Nov 2016 13:18:45 -0500 (EST)
Message-ID: <20161109.131845.1786294086774828048.davem@davemloft.net>
References: <1478288209-30893-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, willemb@google.com,
        ncardwell@google.com, soheil@google.com
To: soheil.kdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38180 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752504AbcKISSr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:18:47 -0500
In-Reply-To: <1478288209-30893-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Date: Fri,  4 Nov 2016 15:36:49 -0400

> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> Do not send the next message in sendmmsg for partial sendmsg
> invocations.
> 
> sendmmsg assumes that it can continue sending the next message
> when the return value of the individual sendmsg invocations
> is positive. It results in corrupting the data for TCP,
> SCTP, and UNIX streams.
> 
> For example, sendmmsg([["abcd"], ["efgh"]]) can result in a stream
> of "aefgh" if the first sendmsg invocation sends only the first
> byte while the second sendmsg goes through.
> 
> Datagram sockets either send the entire datagram or fail, so
> this patch affects only sockets of type SOCK_STREAM and
> SOCK_SEQPACKET.
> 
> Fixes: 228e548e6020 ("net: Add sendmmsg socket system call")
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied and queued up for -stable, thanks.
