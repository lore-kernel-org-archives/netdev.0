From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Mon, 08 Apr 2013 12:14:34 -0400 (EDT)
Message-ID: <20130408.121434.1965501143066047212.davem@davemloft.net>
References: <20130408154519.18177.57709.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mvadkert@redhat.com
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49294 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934422Ab3DHQOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 12:14:36 -0400
In-Reply-To: <20130408154519.18177.57709.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Mon, 08 Apr 2013 11:45:19 -0400

> Commit 90ba9b1986b5ac4b2d184575847147ea7c4280a2 converted
> tcp_make_synack() to use alloc_skb() directly instead of calling
> sock_wmalloc(), the goal being the elimination of two atomic
> operations.  Unfortunately, in doing so the change broke certain
> SELinux/NetLabel configurations by no longer correctly assigning
> the sock to the outgoing packet.
> 
> This patch fixes this regression by doing the skb->sk assignment
> directly inside tcp_make_synack().
> 
> Reported-by: Miroslav Vadkerti <mvadkert@redhat.com>
> Signed-off-by: Paul Moore <pmoore@redhat.com>

Setting skb->sk without the destructor results in an SKB that can live
potentially forever with a stale reference to a destroyed socket.

You cannot fix the problem in this way.
