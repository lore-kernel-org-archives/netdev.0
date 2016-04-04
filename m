From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] udp: support SO_PEEK_OFFSET
Date: Mon, 04 Apr 2016 17:49:47 -0400 (EDT)
Message-ID: <20160404.174947.926111909781290127.davem@davemloft.net>
References: <1459726193-20863-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samanthakumar@google.com,
	edumazet@google.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50633 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755093AbcDDVt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 17:49:57 -0400
In-Reply-To: <1459726193-20863-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Sun,  3 Apr 2016 19:29:49 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Support peeking at a non-zero offset for UDP sockets. Match the
> existing behavior on Unix datagram sockets.
> 
> 1/4 makes the sk_peek_offset functions safe to use outside locks
> 2/4 removes udp headers before enqueue, to simplify offset arithmetic
> 3/4 introduces SO_PEEK_OFFSET support
> 4/4 moves sk->sk_peek_off on read, to match Unix socket semantics.

I don't see how you can separate patches #3 and #4.

Once you hook up the socket operation, the user can successfully use
the feature and therefore must receive the full set of semantics.

You hook up the op in patch #3 but only give the full proper semantics
in #4.
