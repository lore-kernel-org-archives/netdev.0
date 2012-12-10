From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] inet_diag: fix oops for IPv4 AF_INET6 TCP
 SYN-RECV state
Date: Sun, 09 Dec 2012 19:01:29 -0500 (EST)
Message-ID: <20121209.190129.2104270281417362831.davem@davemloft.net>
References: <1355031803-14547-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473Ab2LJABd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 19:01:33 -0500
In-Reply-To: <1355031803-14547-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sun,  9 Dec 2012 00:43:21 -0500

> Fix inet_diag to be aware of the fact that AF_INET6 TCP connections
> instantiated for IPv4 traffic and in the SYN-RECV state were actually
> created with inet_reqsk_alloc(), instead of inet6_reqsk_alloc(). This
> means that for such connections inet6_rsk(req) returns a pointer to a
> random spot in memory up to roughly 64KB beyond the end of the
> request_sock.
> 
> With this bug, for a server using AF_INET6 TCP sockets and serving
> IPv4 traffic, an inet_diag user like `ss state SYN-RECV` would lead to
> inet_diag_fill_req() causing an oops or the export to user space of 16
> bytes of kernel memory as a garbage IPv6 address, depending on where
> the garbage inet6_rsk(req) pointed.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
