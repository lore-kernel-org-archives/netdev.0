From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tcp: deal with listen sockets properly in
 tcp_abort.
Date: Tue, 22 Dec 2015 16:02:23 -0500 (EST)
Message-ID: <20151222.160223.1472844140629618186.davem@davemloft.net>
References: <1450710224-91722-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, tom@herbertland.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754846AbbLVVC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 16:02:26 -0500
In-Reply-To: <1450710224-91722-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Tue, 22 Dec 2015 00:03:44 +0900

> When closing a listen socket, tcp_abort currently calls
> tcp_done without clearing the request queue. If the socket has a
> child socket that is established but not yet accepted, the child
> socket is then left without a parent, causing a leak.
> 
> Fix this by setting the socket state to TCP_CLOSE and calling
> inet_csk_listen_stop with the socket lock held, like tcp_close
> does.
> 
> Tested using net_test. With this patch, calling SOCK_DESTROY on a
> listen socket that has an established but not yet accepted child
> socket results in the parent and the child being closed, such
> that they no longer appear in sock_diag dumps.
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied to net-next, which I assume is the intended target tree for
this patch.

Please make that explicit, always, in future submissions.

Thanks.
