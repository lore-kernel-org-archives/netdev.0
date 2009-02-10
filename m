From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 002/002] de2104x: support for systems lacking cache coherence
Date: Tue, 10 Feb 2009 02:45:46 +0100
Message-ID: <m3ab8v3vzp.fsf@intrepid.localdomain>
References: <46e1c7760902090022g1d903ca0nf314f0c1cc6b07c8@mail.gmail.com>
	<m3vdrja6oe.fsf@intrepid.localdomain>
	<46e1c7760902091122m6ec7fbb5nefd9cc9789880c0f@mail.gmail.com>
	<20090209.145156.172588416.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: risto.suominen@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:43213 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751450AbZBJBpt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2009 20:45:49 -0500
In-Reply-To: <20090209.145156.172588416.davem@davemloft.net> (David Miller's message of "Mon\, 09 Feb 2009 14\:51\:56 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> The issue are descriptors that are _written_ by both the cpu
> and the device.  That is the problematic case here.

Do you mean both CPU and 21040 write to the same descriptor at (nearly)
the same time? Is it TX, RX or both?

I wonder, how would the patch help it?

The patch seems to align the descriptors on cache line boundary. That
IMHO means the corruption is caused by the 21040 writing to e.g. desc
#0, CPU writing to desc #1, which causes the cache line write bringing
the old desc #0 back.

Is it possible to use uncached memory for coherent allocations (with no
write side effects) on this machine?
-- 
Krzysztof Halasa
