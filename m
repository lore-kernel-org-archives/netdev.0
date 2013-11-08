From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: fix netlink_ack with large messages
Date: Fri, 08 Nov 2013 15:07:41 -0500 (EST)
Message-ID: <20131108.150741.966018155704146843.davem@davemloft.net>
References: <9333f540a9b87adbdd15e274d12a9d60994fdb34.1383850578.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757582Ab3KHUHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 15:07:43 -0500
In-Reply-To: <9333f540a9b87adbdd15e274d12a9d60994fdb34.1383850578.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Thu,  7 Nov 2013 19:57:45 +0100

> Commit c05cdb1b864f ("netlink: allow large data transfers from user-space")
> does not handle cases where netlink_ack is used to report an error. In such
> case, the original message is copied to the ack message, which needs to be
> large enough.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

I have two problems with this change.

First of all, if netlink_ack() has this problem, do not extend the
netlink_alloc_large_skb() usage to dumps too as your patch is
doing here.

Secondly, it seems sort of over the top to quote such enormous
messages, and in fact wasteful.  We have the sequence number in
the netlink header, so the user can tell exactly which message
we are erroring.

Just quoting such huge requests in ACKs by default doesn't seem
to make any sense.  I would say that we should have a way to
turn off the quoting, or at least limit it, and turn this knob
off for things like nftables that can hit these kinds of cases.

Pablo, what do you think?
