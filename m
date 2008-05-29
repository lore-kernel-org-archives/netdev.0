From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Single packet receiving in multiple ring buffers
Date: Thu, 29 May 2008 19:35:27 +0400
Message-ID: <20080529153527.GA6561@2ka.mipt.ru>
References: <20080529144551.GA29823@2ka.mipt.ru> <31256957387BB54C8B9AFE88AA5C0564044A1DD0@SDCEXCHANGE01.ad.amcc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kchudgar.linux@gmail.com,
	netdev@vger.kernel.org
To: Keyur Chudgar <kchudgar@amcc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:54064 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751183AbYE2Pfl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 11:35:41 -0400
Content-Disposition: inline
In-Reply-To: <31256957387BB54C8B9AFE88AA5C0564044A1DD0@SDCEXCHANGE01.ad.amcc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 29, 2008 at 08:06:25AM -0700, Keyur Chudgar (kchudgar@amcc.com) wrote:
> > Does your hardware support MTU (or kind of that like e1000, which
> supports packets with size upto next power of two over > MTU)? 
> 
> Yes, it does support MTU. The problem I am discussing will be for jumbo
> frames only.

Then I do not exactly understand a problem, you allocate say 1500 bytes
skb and number of pages (use PAGE_SIZE for arch driver is being loaded),
depending on arch you can even use a single page for the whole packet.
Then install descriptors according to sizes (first one will have size
1500 bytes, second and third ones will be PAGE_SIZE).

With jumbo frames you will waste some descriptors and some pages, but
small-sized traffic will hit only descriptor associated with skb->data,
so you will detach page from skb and submit it to stack, allocate new
one and attach that pages to new skb. If size is too small you can
allocate new small skb and copy data there (I recalled, it is called
copybreak) and submit it to stack instead of one, where DMA was
completed.

> > Page size is different on each arch, for x86 it is 4k by default.
> OK.

You can check PAGE_SIZE for particular arch NIC is used.

-- 
	Evgeniy Polyakov
