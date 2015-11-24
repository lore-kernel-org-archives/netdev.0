From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: avoid packets leaking on socket receive queue
Date: Mon, 23 Nov 2015 23:45:27 -0500 (EST)
Message-ID: <20151123.234527.1692491746715821314.davem@davemloft.net>
References: <1448178365-14827-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbbKXEp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 23:45:29 -0500
In-Reply-To: <1448178365-14827-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Sun, 22 Nov 2015 15:46:05 +0800

> Even if we drain receive queue thoroughly in tipc_release() after tipc
> socket is removed from rhashtable, it is possible that some packets
> are in flight because some CPU runs receiver and did rhashtable lookup
> before we removed socket. They will achieve receive queue, but nobody
> delete them at all. To avoid this leak, we register a private socket
> destructor to purge receive queue, meaning releasing packets pending
> on receive queue will be delayed until the last reference of tipc
> socket will be released.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied.
