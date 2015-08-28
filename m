From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: FIB tracepoints
Date: Thu, 27 Aug 2015 22:47:07 -0700 (PDT)
Message-ID: <20150827.224707.1927135676881589733.davem@davemloft.net>
References: <55DFEC92.8050700@cumulusnetworks.com>
	<20150827.221643.2144480812551172735.davem@davemloft.net>
	<55DFF14A.90203@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbbH1FrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 01:47:10 -0400
In-Reply-To: <55DFF14A.90203@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 27 Aug 2015 22:27:38 -0700

> ie., it does matter. src was declared a u32 and trying to pass &src to
> the printk fails. Been down this road a lot.

It's not printk that's failing, it's the tracing library in userspace
that's being stupid about this.

That's where the "FAILED TO PARSE" thing comes from.

This event parsing code is imposing restrictions that do not exist in
the kernel printk.  And in fact I can't think of a justification for
them, why should this code even care as long as the thing is at least
4 bytes.
