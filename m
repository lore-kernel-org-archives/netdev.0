From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2/2] sky2: Add unidirectional fiber link support
Date: Fri, 27 Aug 2010 14:22:17 -0700
Message-ID: <20100827142217.5fccc098@nehalam>
References: <1282938138-17844-1-git-send-email-Kyle.D.Moffett@boeing.com>
	<12
 82938138-17844-3-git-send-email-Kyle.D.Moffett@boeing.com>
	<20100827133825.494b8098@nehalam>
	<81DAD951-0909-4D3A-8451-AEE3F9B07054@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kyle Moffett <kyle@moffetthome.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Moffett, Kyle D" <Kyle.D.Moffett@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42537 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752655Ab0H0VWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 17:22:30 -0400
In-Reply-To: <81DAD951-0909-4D3A-8451-AEE3F9B07054@boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Aug 2010 15:51:58 -0500
"Moffett, Kyle D" <Kyle.D.Moffett@boeing.com> wrote:

> On Aug 27, 2010, at 16:38, Stephen Hemminger wrote:
> > On Fri, 27 Aug 2010 15:42:18 -0400 Kyle Moffett <Kyle.D.Moffett@boeing.com> wrote:
> >> +	/* 
> >> +	 * Once interrupts are reenabled, reset the PHY again to make sure
> >> +	 * that we didn't miss a link-up interrupt.  This is especially
> >> +	 * likely to occur if we're in fiber-txonly mode, as a link-up
> >> +	 * interrupt is generated almost immediately after we finish
> >> +	 * programming the PHY.
> >> +	 */
> >> +	sky2_phy_reinit(sky2);
> > 
> > Won't this cause a renegotiation causing up to 2 second delay?
> 
> Well, I suppose that's possible, but we've only just reset and enabled the PHY moments before, so I don't see where you could get an *extra* 2-second delay.  On the other hand, I suppose it would be much nicer if there was an easy way to fake an extra interrupt there instead of reinitializing the whole PHY.  I'm not all that comfortable with my understanding of the interrupt logic in the sky2 driver, so I figured I would just reuse all the necessary locking from sky2_phy_reinit().
> 
> Do you have any comments or criticisms of the particular "duplex" method of configuring the unidirectional link support?

No that is fine, but the FIB doesn't really understand RX only links
so I expect users will do stupid things.
