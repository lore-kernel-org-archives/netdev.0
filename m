From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Single packet receiving in multiple ring buffers
Date: Thu, 29 May 2008 18:45:52 +0400
Message-ID: <20080529144551.GA29823@2ka.mipt.ru>
References: <20080525130023.GA27792@2ka.mipt.ru> <31256957387BB54C8B9AFE88AA5C0564044A1DC1@SDCEXCHANGE01.ad.amcc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kchudgar.linux@gmail.com,
	netdev@vger.kernel.org
To: Keyur Chudgar <kchudgar@amcc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:33334 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751706AbYE2OqA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 10:46:00 -0400
Content-Disposition: inline
In-Reply-To: <31256957387BB54C8B9AFE88AA5C0564044A1DC1@SDCEXCHANGE01.ad.amcc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Thu, May 29, 2008 at 07:14:45AM -0700, Keyur Chudgar (kchudgar@amcc.com) wrote:
> I can not program some hardware buffers with skb->data and others with
> pages. I don't know
> at runtime what size packets will come in. If I program first buffer
> with skb->data and other two with
> pages, what if the packet arrived only fits in first buffer? The other
> two buffers are wasted in this case.

Does your hardware support MTU (or kind of that like e1000, which
supports packets with size upto next power of two over MTU)?

> > If it is not convenient to use such scheme, you can always put data
> into pages and then copy tiny bit into skb->data to > be able to specify
> IP layer protocol, all the rest system will do for itself via
> pskb_may_copy() if needed.
> 
> What is the minimum size of pages that I can allocate? Is it 4K? If that
> is the case, then
> I may be wasting a lot of memory for smaller packets.

For small enough packets you can allocate new skb with exact size and
copy data from old page into new skb. It will be much faster, since
sockets will be charged with smaller size per packet. But usually you
have to preallocate at least MTU sized packets.

Page size is different on each arch, for x86 it is 4k by default.

-- 
	Evgeniy Polyakov
