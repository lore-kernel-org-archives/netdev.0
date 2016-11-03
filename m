From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix return value for partial writes
Date: Thu, 03 Nov 2016 16:12:53 -0400 (EDT)
Message-ID: <20161103.161253.1115708840443382693.davem@davemloft.net>
References: <1478122910.7065.396.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soheil@google.com, willemb@google.com,
        ycheng@google.com, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42382 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758107AbcKCUMy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:12:54 -0400
In-Reply-To: <1478122910.7065.396.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Nov 2016 14:41:50 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> After my commit, tcp_sendmsg() might restart its loop after
> processing socket backlog.
> 
> If sk_err is set, we blindly return an error, even though we
> copied data to user space before.
> 
> We should instead return number of bytes that could be copied,
> otherwise user space might resend data and corrupt the stream.
> 
> This might happen if another thread is using recvmsg(MSG_ERRQUEUE)
> to process timestamps.
> 
> Issue was diagnosed by Soheil and Willem, big kudos to them !
> 
> Fixes: d41a69f1d390f ("tcp: make tcp_sendmsg() aware of socket backlog")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
