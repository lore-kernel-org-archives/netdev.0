From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Fix WARNING: at lib/dma-debug.c:902 check_sync
Date: Wed, 20 Jan 2010 12:30:33 -0800
Message-ID: <20100120123033.0746b11e@nehalam>
References: <20100120094103.GA6225@ff.dom.local>
	<20100120100316.2b5b1b05@nehalam>
	<1264018312.9030.76.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
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
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754474Ab0ATUcO@vger.kernel.org>
In-Reply-To: <1264018312.9030.76.camel@nseg_linux_HP1.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 20 Jan 2010 12:11:52 -0800
"Michael Chan" <mchan@broadcom.com> wrote:

> 
> On Wed, 2010-01-20 at 10:03 -0800, Stephen Hemminger wrote:
> > On Wed, 20 Jan 2010 09:41:03 +0000
> > Jarek Poplawski <jarkao2@gmail.com> wrote:
> > > > Seems like an underlying bug in the DMA api. Maybe it just can't
> > > > handle operations on partial mapping.
> > > > 
> > > > Other drivers with same problem:
> > > >   bnx2, cassini, pcnet32, r8169, rrunner, skge, sungem, tg3, 
> > > 
> > > It seems using the same length (even without pci_unmap_len()) is
> > > crucial here, but I hope maintainers (added to CC) will take care.
> > > 
> 
> I'm still unsure how to do dma_sync properly in bnx2.  In the current
> code, we always dma_sync_for_cpu a small portion of the SKB because the
> rx descriptor is at the beginning of the SKB.  We get the packet length,
> for example, from the rx descriptor.
> 
> If it's a big packet, we'll simply unmap the entire SKB buffer (with the
> beginning portion already dma_sync'ed).  If the packet is smaller than
> what we dma_sync'ed, we'll just copy the data to a new SKB.  We'll then
> dma_sync_for_device the portion of the original buffer and recycle the
> whole buffer back to the device for new packets.
> 
> So, is it correct to just change the dma_sync length to the full length
> of the buffer?  It doesn't sound right to me.

It looks like the size passed to sync_single has to match size of original
mapping.
