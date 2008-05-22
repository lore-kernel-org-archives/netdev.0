From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Single packet receiving in multiple ring buffers
Date: Thu, 22 May 2008 22:49:07 +0400
Message-ID: <20080522184906.GA32582@2ka.mipt.ru>
References: <20080522181401.GA14056@2ka.mipt.ru> <31256957387BB54C8B9AFE88AA5C0564044A1846@SDCEXCHANGE01.ad.amcc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Keyur Chudgar <kchudgar.linux@gmail.com>, netdev@vger.kernel.org
To: Keyur Chudgar <kchudgar@amcc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51837 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418AbYEVStK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 14:49:10 -0400
Content-Disposition: inline
In-Reply-To: <31256957387BB54C8B9AFE88AA5C0564044A1846@SDCEXCHANGE01.ad.amcc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 22, 2008 at 11:27:27AM -0700, Keyur Chudgar (kchudgar@amcc.com) wrote:
> > better attach a page to each hardware descriptor and put pages from
> each part into single skb via skb_fill_page_desc().
> This is a good idea. But I can see, if I do this, then what I have in
> skb is only fraglist containing the data, and
> skb->data doesn't have anything. If this is the case, then the stack or
> anybody else would not be able to use
> the macros work on data pointer, like skb->push, pull, put, and even the
> header pointers like h, nh, mac etc.
> Can you please give some thoughts about this?

You have to copy part of the data (up to and including transport headers)
into skb->data.
Or you can dma part of the packet into skb->data and part into attached
pages, which reside in skb_shinfo(skb)->frags (seupt via skb_fill_page_desc())

-- 
	Evgeniy Polyakov
