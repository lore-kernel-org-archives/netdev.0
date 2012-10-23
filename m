From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] sock-diag: Report shutdown for inet and unix
 sockets
Date: Tue, 23 Oct 2012 13:42:36 -0400 (EDT)
Message-ID: <20121023.134236.1262093514433122608.davem@davemloft.net>
References: <5086C36B.6060508@parallels.com>
	<5086C5A6.7050101@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757251Ab2JWRmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:42:37 -0400
In-Reply-To: <5086C5A6.7050101@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Tue, 23 Oct 2012 20:28:22 +0400

> +static inline int shutdown_mask2u(int mask)
> +{
> +	/*
> +	 * map
> +	 * 	RCV_SHUTDOWN -> SHUT_RD
> +	 * 	SEND_SHUTDOWN -> SHUT_WR
> +	 * 	SHUTDOWN_MASK -> SHUT_RDWR
> +	 */
> +
> +	return mask - 1;
> +}

This is horrible.

You're returning "-1" when the socket hasn't been shutdown in any way.

Do this:

1) Use a '1' based encoding like the kernel codes so that '0' means
   no shutdown, as any sane interface would.  That's why we use that
   representation internally.

2) Get rid of all of this extension crap, and just report this value
   in the pad byte.  In older kernels it will just be zero, which is
   fine.
