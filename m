From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv4: Fix incorrect free in ICMP receive
Date: Fri, 16 Jan 2015 03:09:20 -0500 (EST)
Message-ID: <20150116.030920.1013449869229821602.davem@davemloft.net>
References: <05e337f44c7a71ac317194cfa3dcdf62.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57968 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753584AbbAPIJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 03:09:24 -0500
In-Reply-To: <05e337f44c7a71ac317194cfa3dcdf62.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: subashab@codeaurora.org
Date: Fri, 16 Jan 2015 07:48:36 -0000

> An exception is seen in ICMP ping receive path where the skb
> destructor sock_rfree() tries to access a freed socket. This happens
> because ping_rcv() releases socket reference with sock_put() and this
> internally frees up the socket. Later icmp_rcv() will try to free the
> skb and as part of this, skb destructor is called and panics as the
> socket is freed already in ping_rcv().

At the point in which foo_sock_destruct() is called, the 'sk' is not
freed.  We're operating on it inside of the destruct function itself.
