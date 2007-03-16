From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 1/5] AF_RXRPC: Add blkcipher accessors for using kernel data directly [try #2]
Date: Fri, 16 Mar 2007 13:57:45 +0000
Message-ID: <25094.1174053465@redhat.com>
References: <20070316133238.GA2173@infradead.org>  <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com> <20070316125016.3740.96837.stgit@warthog.cambridge.redhat.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, arjan@infradead.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46900 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933814AbXCPN6H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 09:58:07 -0400
In-Reply-To: <20070316133238.GA2173@infradead.org> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig <hch@infradead.org> wrote:

> I don't quite understand all these indirections.  What's the problem
> with just having a helper that builds the scatterlist for you?

I was trying to avoid building a scatterlist completely.  There's not much
point because the scatterlist approach involves finding out the page struct and
then kmapping it just so that the FCrypt algorithm can read 8 or 16 bytes of
data from kernel space.  Why do that if we can avoid it?  It's a waste of
processing time, and has to be done on every secure packet.

> We allow dma access to arbitary pieces of _dynamically_ allocated kernel
> memory, and I think using the crypto subsystem on the stack is not allowed
> at all.

FCrypt is only available in software as far as I know.  For producing and
checking packet signatures, using hardware support would be a waste of time as
the size of the crunched data is so small (a single 8-byte fragment per
packet).

> But the even bigger question is, how does this relate to rxrpc?

RxRPC has security features, up to and including full packet content encryption
if you select it.

> very odd line split

It's not really odd.  The "static" and "inline" don't actually add anything to
the function template.  They're merely scope limiters / optimisation
controllers, and so make a lot of sense placed on their own line.

David
