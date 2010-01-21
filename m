From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 02/11] sky2: fix DMA sync_single length error
Date: Wed, 20 Jan 2010 16:04:07 -0800
Message-ID: <20100120160407.3a365a92@nehalam>
References: <20100120.145218.259766536.davem@davemloft.net>
	<20100120232102.GD3072@del.dom.local>
	<20100120.153451.62650459.davem@davemloft.net>
	<20100120.154126.152942350.davem@davemloft.net>
	<20100120235920.GF3072@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33786 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752924Ab0AUAEj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 19:04:39 -0500
In-Reply-To: <20100120235920.GF3072@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Jan 2010 00:59:20 +0100
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On Wed, Jan 20, 2010 at 03:41:26PM -0800, David Miller wrote:
> > From: David Miller <davem@davemloft.net>
> > Date: Wed, 20 Jan 2010 15:34:51 -0800 (PST)
> > 
> > > Whereas 1 patch in the 1 place in the DMA API implementation would fix
> > > everything for everybody.
> > 
> > For the record I just checked DMAR and Intel-IOMMU and they
> > don't even implement the SYNC ops, they are NULL and thus
> > can't be effected by the changes being discussed here.
> > 
> > The generic DMA SYNC operations check for a NULL function
> > pointer in the DMA operations, and do nothing if it is NULL.
> > 
> > Thus, so far it is proven that only the DMA debugging code 
> > actually has this SYNC length requirement.
> 
> Thanks, I feel at least 75% safer ;-)
> 

The usage of jumbo frames on the Marvell Yukon-2 chip version that
Michael has is suspect. In order to do Jumbo frames, the driver has
turns off the store-forward buffer; this reduces the window for transmit
underrun, and triggers a problem.  I suspect the unwind logic for
transmit underrun is broken and may not be fixable without more hardware
information.  Turning off jumbo frame support for that chip type
is probably the safest solution.

