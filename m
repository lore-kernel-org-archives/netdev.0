From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: avoid wakeups for pure ACK
Date: Wed, 27 Feb 2013 13:04:44 -0500 (EST)
Message-ID: <20130227.130444.2188252064827683663.davem@davemloft.net>
References: <1361984703.11403.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	ycheng@google.com, ak@linux.intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758009Ab3B0SEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 13:04:47 -0500
In-Reply-To: <1361984703.11403.43.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Feb 2013 09:05:03 -0800

> Processing pure ACK on behalf of the thread blocked in tcp_recvmsg()
> is a waste of resources, as thread has to immediately sleep again
> because it got no payload.

More than one thread can be operating on the socket, the other one
could be waiting for the window to open up in order to do a send.  Are
you absolutely sure that we won't have a problem in that situation?
In fact I wonder if that does the right thing right now.
