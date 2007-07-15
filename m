From: Bryan Wu <bryan.wu@analog.com>
Subject: Re: [PATCH 1/3] Blackfin ethernet driver: on chip ethernet MAC
	controller driver
Date: Sun, 15 Jul 2007 17:52:30 +0800
Message-ID: <1184493150.3140.65.camel@roc-laptop>
References: <1184438993.3140.23.camel@roc-laptop>
	 <200707142138.36619.mb@bu3sch.de> <1184491016.3140.52.camel@roc-laptop>
	 <200707151136.05223.mb@bu3sch.de>
Reply-To: bryan.wu@analog.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bryan.wu@analog.com, Jeff Garzik <jeff@garzik.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:22773 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756367AbXGOJwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 05:52:39 -0400
In-Reply-To: <200707151136.05223.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-07-15 at 11:36 +0200, Michael Buesch wrote:
> On Sunday 15 July 2007 11:16:56 Bryan Wu wrote:
> > In current Blackfin DMA allocation/free, the return value from 
> > bfin_mac_alloc() is used as the dma_handle, here it is the
> > tx_desc/rx_desc. 
> > The "dma_handle" is useless in the following code.
> 
> I think a comment has to be added, at least, as it's very confusing.

No problem, it should be.
> 
> > This is some magic code for PHY ID. In the future, we will rewrite some
> > code based on kernel phy abstraction layer to support more phy device.
> 
> Ok, nice idea.
> 
> > > Unwind the allocations above, if registering fails.
> > > 
> > 
> > In fact, it is safe. Because if registering fails, bf537mac_probe will
> > return none zero to bfin_mac_probe which will do free_netdev.
> 
> Hm, weren't there some DMA allocations, too? Are they free'd properly?
> 

Oh, the DMA allocation happens in bf537mac_open not in bf537mac_probe.
so when registering fails, only free_netdev should be ok.

I sent out a new driver patch for #2 try, please give us some comments

Thanks
- Bryan Wu
