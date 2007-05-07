From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_info_hashfn leads to long hash chains
Date: Mon, 07 May 2007 16:09:11 -0700 (PDT)
Message-ID: <20070507.160911.35663865.davem@davemloft.net>
References: <20070429150336.GC10824@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57294
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754892AbXEGXJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 19:09:08 -0400
In-Reply-To: <20070429150336.GC10824@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Sun, 29 Apr 2007 11:03:36 -0400

> Hello
> 
> The patch below fixes a case where fib_find_info() is consume excessive 
> amounts of CPU during the creation of 10000 PPP interfaces.  In access 
> servers, each point to point link has the same local address, but a different 
> destination and interface.  Because the device is not included in the hash 
> calculation, the chain grows excessively large and we end up spinning the 
> CPU walking the list.  As near as I can tell, this shouldn't have any negative 
> sideeffects, but someone with a better understanding of fib_semantics.c will 
> need to check over it.  Cheers,

fib_create_info() makes sure that fi->fib_nhs is always at least one.
So the conditional can be removed.  After a fib_info is create, it's
fi->fib_nhs is immutable, it doesn't change.

In fact there are some checks for fi->fib_nhs == 0 elsewhere in this
code, those are bogus too, and I imagine you saw those when coding
up this patch. :-)
