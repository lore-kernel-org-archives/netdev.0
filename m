From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv5 3/4] sparc64: Avoid irqsave/restore on vio.lock if
 in_softirq()
Date: Sat, 25 Oct 2014 14:28:22 -0400 (EDT)
Message-ID: <20141025.142822.141874034124023889.davem@davemloft.net>
References: <20141022221245.GE17252@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbaJYS2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2014 14:28:24 -0400
In-Reply-To: <20141022221245.GE17252@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 22 Oct 2014 18:12:45 -0400

> 
> For NAPIfied drivers , there is no need to
> synchronize by doing irqsave/restore on vio.lock in the I/O
> path.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Conditional locking is broken locking, and the bug you introduce
here is a good example of why that is.

If the vio->timer has to be triggered when vio_port_up() is
invoked, it will next run fron in_softirq() context regardless
of whether the user is sunvnet or sunvdc.  So it will elide
the locking regardless of who is using this vio context.

Never, ever, use conditional locking.

This locking is harmless overhead in a slow path, just leave
it alone for now.
