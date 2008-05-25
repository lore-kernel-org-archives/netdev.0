From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Single packet receiving in multiple ring buffers
Date: Sun, 25 May 2008 17:00:24 +0400
Message-ID: <20080525130023.GA27792@2ka.mipt.ru>
References: <20080523120041.GA16850@2ka.mipt.ru> <31256957387BB54C8B9AFE88AA5C0564044A1951@SDCEXCHANGE01.ad.amcc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kchudgar.linux@gmail.com,
	netdev@vger.kernel.org
To: Keyur Chudgar <kchudgar@amcc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:56856 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753455AbYEYNAn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 May 2008 09:00:43 -0400
Content-Disposition: inline
In-Reply-To: <31256957387BB54C8B9AFE88AA5C0564044A1951@SDCEXCHANGE01.ad.amcc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 23, 2008 at 09:08:10AM -0700, Keyur Chudgar (kchudgar@amcc.com) wrote:
> > So, from perfomance viewpoint it looks like the best decision is to
> have first part of the packet in skb->data and the 
> > rest in attached pages.
> 
> If we follow this approach as to have first part of the packet in
> skb->data and the rest in attached pages,
> We will need to copy from page (which is programmed initially in buffer
> for hw) to skb->data (which is newly allocated)each time, even if the
> packet was of only single buffer. We can not program skb->data pointers
> and addresses of pages intermix in the buffers for hw.

I meant that you initialize hardware buffers to point to skb->data and
then to pages, not always to pages. In this case controller will DMA
data to skb->data and the rest of the packet into attached pages. If it
is not convenient to use such scheme, you can always put data into pages
and then copy tiny bit into skb->data to be able to specify IP layer
protocol, all the rest system will do for itself via pskb_may_copy() if
needed.

Essentially copy of such small amount of data like 40-60 bytes of all
headers is so small, that you will unlikely detect it in register
access, allocation noise, tcp state processing and eventual copy to
userspace, but nevertheless you can try to optimize it out of course.

-- 
	Evgeniy Polyakov
