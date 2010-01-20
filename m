From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Fix WARNING: at lib/dma-debug.c:902 check_sync
Date: Wed, 20 Jan 2010 10:03:16 -0800
Message-ID: <20100120100316.2b5b1b05@nehalam>
References: <20100120094103.GA6225@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Michael Breuer <mbreuer@majjas.com>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35140 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753766Ab0ATSFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 13:05:11 -0500
In-Reply-To: <20100120094103.GA6225@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Jan 2010 09:41:03 +0000
Jarek Poplawski <jarkao2@gmail.com> wrote:

> [ previously: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit() ]
> On Tue, Jan 19, 2010 at 05:10:13PM -0800, Stephen Hemminger wrote:
> > On Tue, 19 Jan 2010 20:01:10 -0500
> > Michael Breuer <mbreuer@majjas.com> wrote:
> > 
> > > On 1/19/2010 5:45 PM, Jarek Poplawski wrote:
> > > > On Tue, Jan 19, 2010 at 03:06:01PM -0500, Michael Breuer wrote:
> > > >    
> > > >> On 1/19/2010 2:59 PM, Jarek Poplawski wrote:
> > > >>      
> > > >>> On Tue, Jan 19, 2010 at 10:47:27AM -0500, Michael Breuer wrote:
> > > >>> ...
> > > >>>        
> > > >>>> Still get the warning... but now 60 bytes.
> > > >>>> Jan 19 10:43:50 mail kernel: ------------[ cut here ]------------
> > > >>>> Jan 19 10:43:50 mail kernel: WARNING: at lib/dma-debug.c:902
> ...
> > > That not only compiled, but it cleared the error as well. Additionally, 
> > > I used to see a bit of a delay receiving the login prompt when first 
> > > connecting to the box by ssh. That delay is gone with this patch. I'd 
> > > guess that the warning wasn't quite as innocuous as I thought.
> > > Note: tested on 2.6.32.4.  I'll leave this up for a bit before 
> > > attempting to move back to head.
> > 
> > Seems like an underlying bug in the DMA api. Maybe it just can't
> > handle operations on partial mapping.
> > 
> > Other drivers with same problem:
> >   bnx2, cassini, pcnet32, r8169, rrunner, skge, sungem, tg3, 
> 
> It seems using the same length (even without pci_unmap_len()) is
> crucial here, but I hope maintainers (added to CC) will take care.
> 
> Btw, it's not tested yet, but it might affect CONFIG_DMAR problems.

The list of places to inspect is:

$ git grep -l sync_single_for_cpu $(git grep -l skb_copy_from_linear_data)
drivers/infiniband/ulp/ipoib/ipoib_cm.c
drivers/message/fusion/mptlan.c
drivers/net/b44.c
drivers/net/bnx2.c
drivers/net/cassini.c
drivers/net/chelsio/sge.c
drivers/net/cxgb3/sge.c
drivers/net/irda/vlsi_ir.c
drivers/net/myri_sbus.c
drivers/net/r8169.c
drivers/net/rrunner.c
drivers/net/skge.c
drivers/net/sky2.c
drivers/net/sungem.c
drivers/net/sunhme.c
drivers/net/tg3.c
drivers/net/tokenring/3c359.c
drivers/net/tokenring/olympic.c
drivers/net/tulip/de2104x.c
drivers/net/via-velocity.c
drivers/net/wireless/ipw2x00/ipw2100.c
drivers/net/wireless/ipw2x00/ipw2200.c
