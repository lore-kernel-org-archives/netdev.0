From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 002/002] de2104x: support for systems lacking cache
 coherence
Date: Mon, 09 Feb 2009 17:50:04 -0800 (PST)
Message-ID: <20090209.175004.122797043.davem@davemloft.net>
References: <46e1c7760902091122m6ec7fbb5nefd9cc9789880c0f@mail.gmail.com>
	<20090209.145156.172588416.davem@davemloft.net>
	<m3ab8v3vzp.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: risto.suominen@gmail.com, netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47571
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752208AbZBJBuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 20:50:10 -0500
In-Reply-To: <m3ab8v3vzp.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Tue, 10 Feb 2009 02:45:46 +0100

> David Miller <davem@davemloft.net> writes:
> 
> > The issue are descriptors that are _written_ by both the cpu
> > and the device.  That is the problematic case here.
> 
> Do you mean both CPU and 21040 write to the same descriptor at (nearly)
> the same time? Is it TX, RX or both?
> 
> I wonder, how would the patch help it?

The problem is when the chip is writing to one neighbouring descriptor
of one which the cpu is writing to at the same time.

> The patch seems to align the descriptors on cache line boundary. That
> IMHO means the corruption is caused by the 21040 writing to e.g. desc
> #0, CPU writing to desc #1, which causes the cache line write bringing
> the old desc #0 back.

Right.

> Is it possible to use uncached memory for coherent allocations (with no
> write side effects) on this machine?

Good question.
