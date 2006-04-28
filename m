From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 20/32] rt2x00: byte ordering correctness
Date: Fri, 28 Apr 2006 14:46:33 +0100
Message-ID: <20060428134632.GA4526@infradead.org>
References: <200604280003.12743.IvDoorn@gmail.com> <20060428131430.GA3288@infradead.org> <200604281531.06896.IvDoorn@gmail.com> <200604281542.29534.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ivo van Doorn <ivdoorn@gmail.com>, netdev@vger.kernel.org,
	rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:1430 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1030401AbWD1Nqe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 09:46:34 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200604281542.29534.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2006 at 03:42:29PM +0200, Michael Buesch wrote:
> I guess you are confusing something here:
> MMIO access versus values in structs (for example) that 
> are accessed through DMA (for example).

so there's two general problems:

  mmio/pio   - linux expects the device to be le there by defalt and
               {read,write}{b,s,l} do the switch automatically
  dmaed data - you always need to switch data yourself, data is commonly
  	       either be or le

now there's devices that are always be for mmio or can be switched to it
during initialization.  For Linux you'd traditionally have to switch before
calling {read,write}{b,s,l} or use the __raw_ version that have other issues.
The ioread*/iowrite* APIs now have a BE version, too.

I've not heard about devices having this switch for dma payload, and it
would be rather usual as large parts of it are determined by some on the
wire protocol anyway.

> 
> -- 
> Greetings Michael.


---end quoted text---
