From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rxrpc: Wake up the transmitter if Rx window size
 increases on the peer
Date: Fri, 10 Mar 2017 09:35:19 -0800 (PST)
Message-ID: <20170310.093519.229256071004713229.davem@davemloft.net>
References: <148913212914.28383.13034499448460205789.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59744 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755050AbdCJRf1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 12:35:27 -0500
In-Reply-To: <148913212914.28383.13034499448460205789.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Fri, 10 Mar 2017 07:48:49 +0000

> The RxRPC ACK packet may contain an extension that includes the peer's
> current Rx window size for this call.  We adjust the local Tx window size
> to match.  However, the transmitter can stall if the receive window is
> reduced to 0 by the peer and then reopened.
> 
> This is because the normal way that the transmitter is re-energised is by
> dropping something out of our Tx queue and thus making space.  When a
> single gap is made, the transmitter is woken up.  However, because there's
> nothing in the Tx queue at this point, this doesn't happen.
> 
> To fix this, perform a wake_up() any time we see the peer's Rx window size
> increasing.
> 
> The observable symptom is that calls start failing on ETIMEDOUT and the
> following:
> 
> 	kAFS: SERVER DEAD state=-62
> 
> appears in dmesg.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks David.
