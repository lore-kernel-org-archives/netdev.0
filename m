From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/13] tg3: Increase the PCI MRRS
Date: Thu, 15 Nov 2007 14:41:03 -0800 (PST)
Message-ID: <20071115.144103.24280158.davem@davemloft.net>
References: <1194655141.5745.272.camel@teletran1>
	<20071112.212135.172019737.davem@davemloft.net>
	<1195165211.20497.107.camel@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50696
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761748AbXKOWlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 17:41:03 -0500
In-Reply-To: <1195165211.20497.107.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Thu, 15 Nov 2007 14:20:10 -0800

> On Mon, 2007-11-12 at 21:21 -0800, David Miller wrote:
> > From: "Matt Carlson" <mcarlson@broadcom.com>
> > Date: Fri, 09 Nov 2007 16:39:01 -0800
> > 
> > > Previous devices hardcoded the PCI Maximum Read Request Size to 4K.  To
> > > better comply with the PCI spec, the hardware now defaults the MRRS to
> > > 512 bytes.  This will yield poor driver performance if left untouched.
> > > This patch increases the MRRS to 4K on driver initialization.
> > > 
> > > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > 
> > I've applied this patch, but...
> > 
> > I sense that the PCI spec wants devices to use an MRRS value of 512 in
> > order to get better fairness on a PCI-E segment amongst multiple
> > devices.
> > 
> > From that perspective, jacking up the MRRS to 4096 unilaterally seems
> > like a very bad idea.  If this was necessary for good performance, I'm
> > sure the PCI spec folks would have choosen a higher value.
> > 
> > Or is this some tg3 specific performance issue?
> 
> Keeping the MRRS at 512 introduces DMA latencies that effectively
> prevent us from achieving linerate.  With a packet size of ~1.5K and the
> MRRS at 512 bytes, the DMA will be broken into at least 3 DMA reads.
> Each DMA read takes ~1usec to initiate.  It is this overhead that starts
> to cut into total throughput.

Ok, but wouldn't every networking device on PCI need to do this then?

I want to hear what you think about this wrt. what I mentioned about
fairness above.  What's the point of PCI specifying a limit to comply
with if nobody complies with the limit for localized performance
reasons?

I think this is an important issue.  Someone down the road is going to
see bad disk throughput when doing lots of network transfers and
wonder why that is.  It will be hard to debug, but it won't be
difficult for us to do something proactive about this right now to
prevent that problem from happening in the first place.

Thanks.
