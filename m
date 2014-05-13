From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/8] tipc: decrease connection flow control
 window
Date: Tue, 13 May 2014 00:05:30 -0400 (EDT)
Message-ID: <20140513.000530.154961879638643331.davem@davemloft.net>
References: <1399641209-26112-1-git-send-email-jon.maloy@ericsson.com>
	<1399641209-26112-2-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34677 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248AbaEMEFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 00:05:34 -0400
In-Reply-To: <1399641209-26112-2-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Fri,  9 May 2014 09:13:22 -0400

> Memory overhead when allocating big buffers for data transfer may
> be quite significant. E.g., truesize of a 64 KB buffer turns out
> to be 132 KB, 2 x the requested size.
> 
> This invalidates the "worst case" calculation we have been
> using to determine the default socket receive buffer limit,
> which is based on the assumption that 1024x64KB = 67MB buffers
> may be queued up on a socket.
> 
> Since TIPC connections cannot survive hitting the buffer limit,
> we have to compensate for this overhead.
> 
> We do that in this commit by dividing the fix connection flow
> control window from 1024 (2*512) messages to 512 (2*256). Since
> older version nodes send out acks at 512 message intervals,
> compatibility with such nodes is guaranteed, although performance
> may be non-optimal in such cases.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> Reviewed-by: Ying Xue <ying.xue@windriver.com>

So all I have to do is open 64 sockets to make TIPC commit to 4GB
of ram at once?

I really think you need to rethink this, the socket limits are
there for a reason.
