From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Single packet receiving in multiple ring buffers
Date: Thu, 29 May 2008 20:41:47 +0400
Message-ID: <20080529164146.GA7520@2ka.mipt.ru>
References: <20080529153527.GA6561@2ka.mipt.ru> <31256957387BB54C8B9AFE88AA5C0564044A1DF1@SDCEXCHANGE01.ad.amcc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kchudgar.linux@gmail.com,
	netdev@vger.kernel.org
To: Keyur Chudgar <kchudgar@amcc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:38309 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750854AbYE2QmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 12:42:10 -0400
Content-Disposition: inline
In-Reply-To: <31256957387BB54C8B9AFE88AA5C0564044A1DF1@SDCEXCHANGE01.ad.amcc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 29, 2008 at 09:09:30AM -0700, Keyur Chudgar (kchudgar@amcc.com) wrote:
> > With jumbo frames you will waste some descriptors and some pages, but
> small-sized traffic will hit only descriptor 
> > associated with skb->data, so you will detach page from skb and submit
> it to stack, allocate new one and attach that 
> > pages to new skb. If size is too small you can allocate new small skb
> and copy data there (I recalled, it is called
> > copybreak) and submit it to stack instead of one, where DMA was
> completed.
> 
> This will be a good idea. Can you let me know how can I detach and
> attach the page from/to skb?

There is no simple function to detach page, but attaching is being done via
skb_fill_page_desc(). You can check how sky2 does it for example.


-- 
	Evgeniy Polyakov
