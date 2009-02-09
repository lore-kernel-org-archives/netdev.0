From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 002/002] de2104x: support for systems lacking cache
 coherence
Date: Mon, 09 Feb 2009 14:51:56 -0800 (PST)
Message-ID: <20090209.145156.172588416.davem@davemloft.net>
References: <46e1c7760902090022g1d903ca0nf314f0c1cc6b07c8@mail.gmail.com>
	<m3vdrja6oe.fsf@intrepid.localdomain>
	<46e1c7760902091122m6ec7fbb5nefd9cc9789880c0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: risto.suominen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38512
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752160AbZBIWwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 17:52:02 -0500
In-Reply-To: <46e1c7760902091122m6ec7fbb5nefd9cc9789880c0f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Risto Suominen <risto.suominen@gmail.com>
Date: Mon, 9 Feb 2009 21:22:03 +0200

> 2009/2/9 Krzysztof Halasa <khc@pm.waw.pl>:
> >
> > That means the consistent/coherent mapping isn't really
> > consistent/coherent (uncached), right? Perhaps there is some way to fix
> > this instead of changing the drivers to avoid the problematic area?
> >
> Yes.
> 
> The other way could be to add a config parameter that allows to
> explicitly set CONFIG_NOT_COHERENT_CACHE. I have not tried this,
> probably because the necessary code wasn't in arch/powerpc until
> 2.6.21.
> 
> Anyway, now I have tested with 2.6.24, and the problem still exists.

Ok.

The issue are descriptors that are _written_ by both the cpu
and the device.  That is the problematic case here.

e100 had a similar problem and changes were made there too to
accomodate such system types.

If only the cpu or only the device writes to the descriptor
(which is the most common design these days) there are no
problems.

So as promised I'll have to relook at this patch :-)
