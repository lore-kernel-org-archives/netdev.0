From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: fix netlink_ack with large messages
Date: Sat, 09 Nov 2013 00:00:12 -0500 (EST)
Message-ID: <20131109.000012.1393414533296613338.davem@davemloft.net>
References: <9333f540a9b87adbdd15e274d12a9d60994fdb34.1383850578.git.jbenc@redhat.com>
	<20131108.150741.966018155704146843.davem@davemloft.net>
	<20131109000434.GD28793@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, netdev@vger.kernel.org, pablo@netfilter.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39387 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753Ab3KIFAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Nov 2013 00:00:15 -0500
In-Reply-To: <20131109000434.GD28793@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Sat, 9 Nov 2013 00:04:34 +0000

> I agree it seems over the top for pure ACKs but we also use
> netlink_ack() to report errors where it makes sense to quote
> the full message.

The user has the message, they gave it to us in the sendmsg()
we are responding to.  We absolutely do not need to give it
to them again.

If they care about referring to the contents of that message, they can
refer to it in their own copy and make sure they are really looking at
the same thing by comparing the sequence number in the netlink ACK to
the one they used in the netlink header they gave to the kernel in the
sendmsg() call.

What happens now is pure duplication, and for such huge netlink
messages it's really not smart at all.
