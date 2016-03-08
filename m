From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/11] rxrpc: Add a common object cache
Date: Tue, 08 Mar 2016 15:15:14 -0500 (EST)
Message-ID: <20160308.151514.2100824747766658409.davem@davemloft.net>
References: <20160307143806.18567.30020.stgit@warthog.procyon.org.uk>
	<23389.1457390714@warthog.procyon.org.uk>
	<30372.1457442148@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44268 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbcCHUPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 15:15:17 -0500
In-Reply-To: <30372.1457442148@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Tue, 08 Mar 2016 13:02:28 +0000

> David Howells <dhowells@redhat.com> wrote:
> 
>> Does it make sense to maintain a FIFO list of connections (though this would
>> mean potentially taking a spinlock every time I get a packet)?
> 
> It occurs to me that only inactive connections would need to be on an LRU
> list.  Any connection with packets or active calls to deal with wouldn't be on
> the list.

In that kind of scheme you have to decide if it's possible to elide a
response in order to intentionally keep objects off the "inactive" LRU
list.  I bet there is.
