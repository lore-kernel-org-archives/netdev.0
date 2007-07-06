From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 2/2] shrink size of scatterlist on common i386/x86-64
Date: Fri, 06 Jul 2007 01:54:17 -0700 (PDT)
Message-ID: <20070706.015417.74747276.davem@davemloft.net>
References: <20070705170051.37ff2ab8@freepuppy.localdomain.hemminger.net>
	<20070705.171535.105173068.davem@davemloft.net>
	<1183707826.6005.177.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48876
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754532AbXGFIyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 04:54:11 -0400
In-Reply-To: <1183707826.6005.177.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 06 Jul 2007 17:43:46 +1000

> On Thu, 2007-07-05 at 17:15 -0700, David Miller wrote:
> > Also even with the scatterlist idea, we'd still need to do two
> > map calls, one for skb->data and one for the page vector.
> 
> We could make skb->shinfo(skb)->frags[0] the first segment and deprecate
> skb->data and skb->len.
> 
> OK, you can stop hitting me now...

The fly in that ointment is that referencing the backing
page of kmalloc() data is not safe currently, especially
with SLUB.

Jens Axboe ran into this while trying to implement sendfile()
via splice() several weeks ago, it's an ongoing battle that
even C. Lameter is even involved in now :-)
