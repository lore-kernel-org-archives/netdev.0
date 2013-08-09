From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH] net/usb: rtl8150: allocate URB transfer_buffer and
 setup_packet separately
Date: Fri, 9 Aug 2013 21:50:09 +0300 (EEST)
Message-ID: <alpine.DEB.2.10.1308092149270.3114@fry.nucleusys.com>
References: <20130807133653.15587.35442.stgit@localhost6.localdomain6> <alpine.DEB.2.10.1308081809120.4258@fry.nucleusys.com> <5203F4D4.8090609@iki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:40212 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030353Ab3HISuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 14:50:24 -0400
In-Reply-To: <5203F4D4.8090609@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Aug 2013, Jussi Kivilinna wrote:

> On 08.08.2013 18:14, Petko Manolov wrote:
> > On Wed, 7 Aug 2013, Jussi Kivilinna wrote:
> > 
> >> rtl8150 allocates URB transfer_buffer and setup_packet as part of same 
> >> structure 'struct async_req'. This can cause same cacheline to be 
> >> DMA-mapped twice with same URB. This can lead to memory corruption on 
> >> some systems.
> > 
> > I can see performance impact due to the double mapping.  However, memory 
> > corruption seems a bit too much for sane cache and DMA controllers.  Out 
> > of interest - which is the architecture that will potentially corrupt the 
> > memory.
> 
> rtlwifi driver had similar structure to allocate both setup_packet and 
> transfer_buffer in single go (overlapping dma-mapping cachelines) and 
> this caused problems on ARM/sunxi. Problems means: memory corruptions at 
> random locations, device freezes and lock-ups.

Broken controllers?..
