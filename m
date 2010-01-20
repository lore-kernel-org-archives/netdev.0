From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] sky2: Fix WARNING: at lib/dma-debug.c:902
 check_sync
Date: Wed, 20 Jan 2010 12:11:52 -0800
Message-ID: <1264018312.9030.76.camel@nseg_linux_HP1.broadcom.com>
References: <20100120094103.GA6225@ff.dom.local>
 <20100120100316.2b5b1b05@nehalam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@gmail.com>,
	"David Miller" <davem@davemloft.net>,
	"Michael Breuer" <mbreuer@majjas.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"flyboy@gmail.com" <flyboy@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Don Fry" <pcnet32@verizon.net>,
	"Francois Romieu" <romieu@fr.zoreil.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1895 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752688Ab0ATUWd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 15:22:33 -0500
In-Reply-To: <20100120100316.2b5b1b05@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2010-01-20 at 10:03 -0800, Stephen Hemminger wrote:
> On Wed, 20 Jan 2010 09:41:03 +0000
> Jarek Poplawski <jarkao2@gmail.com> wrote:
> > > Seems like an underlying bug in the DMA api. Maybe it just can't
> > > handle operations on partial mapping.
> > > 
> > > Other drivers with same problem:
> > >   bnx2, cassini, pcnet32, r8169, rrunner, skge, sungem, tg3, 
> > 
> > It seems using the same length (even without pci_unmap_len()) is
> > crucial here, but I hope maintainers (added to CC) will take care.
> > 

I'm still unsure how to do dma_sync properly in bnx2.  In the current
code, we always dma_sync_for_cpu a small portion of the SKB because the
rx descriptor is at the beginning of the SKB.  We get the packet length,
for example, from the rx descriptor.

If it's a big packet, we'll simply unmap the entire SKB buffer (with the
beginning portion already dma_sync'ed).  If the packet is smaller than
what we dma_sync'ed, we'll just copy the data to a new SKB.  We'll then
dma_sync_for_device the portion of the original buffer and recycle the
whole buffer back to the device for new packets.

So, is it correct to just change the dma_sync length to the full length
of the buffer?  It doesn't sound right to me.

Thanks.


