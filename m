From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix accept4() flags not work
Date: Mon, 09 Jan 2017 16:37:49 -0500 (EST)
Message-ID: <20170109.163749.326273890394714115.davem@davemloft.net>
References: <1483872450-2706-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linyu.Yuan@alcatel-sbell.com.cn
To: cugyly@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51744 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755886AbdAIVhv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 16:37:51 -0500
In-Reply-To: <1483872450-2706-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <cugyly@163.com>
Date: Sun,  8 Jan 2017 18:47:30 +0800

> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> user input flags store to newsock which should be used.
> 
> Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

It is the file flags of the parent listening socket that determines if
the accept() blocks or not.

The man page for accept() is clear about this:

	... and the socket is not marked as nonblocking

meaning the parent listening socket.

The "flags" argument of accept4() is purely for setting flags on
the accepted new child socket, it has no influence whatsoever
about the blocking of the accept() call or not.  That behavior
is determined in the context of the listening socket.
