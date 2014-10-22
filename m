From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: Add TCP_FREEZE socket option
Date: Wed, 22 Oct 2014 12:14:18 -0400 (EDT)
Message-ID: <20141022.121418.1477947755244353588.davem@davemloft.net>
References: <1413992196-4891-1-git-send-email-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kristian.evensen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbaJVQOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 12:14:41 -0400
In-Reply-To: <1413992196-4891-1-git-send-email-kristian.evensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kristian Evensen <kristian.evensen@gmail.com>
Date: Wed, 22 Oct 2014 17:36:36 +0200

> This patch introduces support for Freeze-TCP [1].

By your description I would not expect the application to get involved
with the actual final zero window advertisement decision at all.

Instead, I would expect the device layer to trigger a notification
during a "technology change" or whatever you want to call losing
connectivity, whichi TCP can receive and use to start sending zero
windows over all TCP connections using that path.

So the socket option enables or disables the facility, but doesn't
actually trigger the zero window advertisement.  A real device based
event does that.

The application has no business watching for the loss of connectivity,
and I am certain you do not want that logice in every application in
order for it to take advantage of this.

And therefore there should be a global option that turns this on for
the entire system by default.

This requires a lot more work than you have done here, you need to
add all the notification handling, the logic in TCP to look at the
attached route on send and trigger zero window probes if the device
event has happened, etc.
