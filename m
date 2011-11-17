From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: avoid to double release dst in tcp_v4_connect
Date: Thu, 17 Nov 2011 16:56:01 -0500 (EST)
Message-ID: <20111117.165601.715150304040818603.davem@davemloft.net>
References: <1321518828-4288-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab1KQV4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 16:56:03 -0500
In-Reply-To: <1321518828-4288-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu, 17 Nov 2011 16:33:48 +0800

> From: RongQing.Li <roy.qing.li@gmail.com> 
> 
> When tcp_connect failed in tcp_v4_connect, the dst will be
> released in error handler of tcp_v4_connect, but dst has been
> set to sk->sk_dst_cache which will be released again when
> destroy this sk.
> 
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>

We set 'rt' to NULL at these statements specifically to handle this
situation, ip_rt_put(NULL) will do nothing.

I don't think this change is necessary.
