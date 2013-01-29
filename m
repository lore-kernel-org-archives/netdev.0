From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: prevent l2tp_tunnel_delete racing with userspace
 close
Date: Tue, 29 Jan 2013 16:03:31 -0500 (EST)
Message-ID: <20130129.160331.1697248531078003094.davem@davemloft.net>
References: <1358867628-21217-1-git-send-email-tparkin@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, celston@katalix.com, jchapman@katalix.com
To: tparkin@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342Ab3A2VDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 16:03:33 -0500
In-Reply-To: <1358867628-21217-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Parkin <tparkin@katalix.com>
Date: Tue, 22 Jan 2013 15:13:48 +0000

> If a tunnel socket is created by userspace, l2tp hooks the socket destructor
> in order to clean up resources if userspace closes the socket or crashes.  It
> also caches a pointer to the struct sock for use in the data path and in the
> netlink interface.
> 
> While it is safe to use the cached sock pointer in the data path, where the
> skb references keep the socket alive, it is not safe to use it elsewhere as
> such access introduces a race with userspace closing the socket.  In
> particular, l2tp_tunnel_delete is prone to oopsing if a multithreaded
> userspace application closes a socket at the same time as sending a netlink
> delete command for the tunnel.
> 
> This patch fixes this oops by forcing l2tp_tunnel_delete to explicitly look up
> a tunnel socket held by userspace using sockfd_lookup().
> 
> Signed-off-by: Tom Parkin <tparkin@katalix.com>
> Signed-off-by: James Chapman <jchapman@katalix.com>

Applied.
