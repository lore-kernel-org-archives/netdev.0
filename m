From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Wed, 23 Apr 2008 18:08:49 -0700 (PDT)
Message-ID: <20080423.180849.240014014.davem@davemloft.net>
References: <m34p9smrmp.fsf@maximus.localdomain>
	<20080423.154953.161012169.davem@davemloft.net>
	<m3iqy8f57m.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, paulkf@microgate.com, jchapman@katalix.com,
	alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34706
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752831AbYDXBIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 21:08:51 -0400
In-Reply-To: <m3iqy8f57m.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Thu, 24 Apr 2008 02:48:29 +0200

> David Miller <davem@davemloft.net> writes:
> 
> > No, it was added as an optimization since the private
> > area was allocated together with the struct netdev, and
> > thus at a constant offset computable a compile time.
> 
> That's essentially what I meant. And it has changed, call it whatever
> you wish.

The core kernel code sets dev->priv to the alloc_netdev() allocated
memory region.

It doesn't do that just for fun.

Any code which overrides that setting is asking for trouble.
What if the code kernel code that set it, needed to use it
during device release for some reason?
