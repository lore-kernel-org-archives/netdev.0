From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rxrpc: Simplify connect() implementation and simplify
 sendmsg() op
Date: Thu, 09 Jun 2016 23:30:25 -0700 (PDT)
Message-ID: <20160609.233025.1997097561663090020.davem@davemloft.net>
References: <146550977184.3563.9271906788876997357.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54044 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203AbcFJGa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 02:30:28 -0400
In-Reply-To: <146550977184.3563.9271906788876997357.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Thu, 09 Jun 2016 23:02:51 +0100

> Simplify the RxRPC connect() implementation.  It will just note the
> destination address it is given, and if a sendmsg() comes along with no
> address, this will be assigned as the address.  No transport struct will be
> held internally, which will allow us to remove this later.
> 
> Simplify sendmsg() also.  Whilst a call is active, userspace refers to it
> by a private unique user ID specified in a control message.  When sendmsg()
> sees a user ID that doesn't map to an extant call, it creates a new call
> for that user ID and attempts to add it.  If, when we try to add it, the
> user ID is now registered, we now reject the message with -EEXIST.  We
> should never see this situation unless two threads are racing, trying to
> create a call with the same ID - which would be an error.
> 
> It also isn't required to provide sendmsg() with an address - provided the
> control message data holds a user ID that maps to a currently active call.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied to net-next, thanks.
