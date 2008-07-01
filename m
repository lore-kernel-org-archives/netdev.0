From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: kmemcheck detected possible information leak to userspace?
Date: Tue, 1 Jul 2008 15:21:06 +0400
Message-ID: <20080701112106.GB17015@2ka.mipt.ru>
References: <19f34abd0807010216k11a60382xf7a27b4b27f0819@mail.gmail.com> <20080701102459.GB30248@2ka.mipt.ru> <19f34abd0807010352t264fda16g826912a857e88140@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>,
	Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44673 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751503AbYGALVE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 07:21:04 -0400
Content-Disposition: inline
In-Reply-To: <19f34abd0807010352t264fda16g826912a857e88140@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 01, 2008 at 12:52:53PM +0200, Vegard Nossum (vegard.nossum@gmail.com) wrote:
> The u means uninitialized. So it seems not to be just the end. But I
> am not sure where the end of the buffer is anyway.
> 
> But there is one thing I forgot: Is this memory initialized by DMA? If
> so, the warning is bogus and I will go hide in shame.

It depends on driver, but sufficiently new hardware (or better say any
non-crappy hardware) will do dma transafer just into skb->data.

To catch it you can put kmemcheck hooks into pci_map* and friend
functions.

-- 
	Evgeniy Polyakov
