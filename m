From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] sky2: flow control off
Date: Tue, 6 Feb 2007 19:57:57 -0800
Message-ID: <20070206195757.1bc81923@oldman>
References: <20070202153425.2d979fd4@freekitty>
	<45C91ABF.9030504@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:33235 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030247AbXBGD6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 22:58:12 -0500
In-Reply-To: <45C91ABF.9030504@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 06 Feb 2007 19:18:07 -0500
Jeff Garzik <jgarzik@pobox.com> wrote:

> Stephen Hemminger wrote:
> > Turn flow control off for sky2. When flow control is on, the transmitter
> > may get randomly stuck. Perhaps there is hardware problem, but until
> > Marvell provides errata information for workaround, it should default to off.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> > ---
> >  drivers/net/sky2.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> > index 822dd0b..a31dea5 100644
> > --- a/drivers/net/sky2.c
> > +++ b/drivers/net/sky2.c
> > @@ -3263,7 +3263,7 @@ #endif
> >  
> >  	/* Auto speed and flow control */
> >  	sky2->autoneg = AUTONEG_ENABLE;
> > -	sky2->flow_mode = FC_BOTH;
> > +	sky2->flow_mode = FC_NONE;
> 
> I ACK the patch... conditional on some -mm style testing and user ACKs.
> 
> Logic:  if there were no downsides to disabling flow control globally, 
> the world's networks would have already done so.  Flow control can be 
> quite helpful, so I while I understand the errata argument, I also want 
> to understand the full effect of this tiny patch.
> 

Actually, the E1000 had it off until recently. The downside is that if 
a system is connected on a switch with a gigabit to 100mbit port
and using a stupid protocol like NFS over UDP, then the packet
burst is sure to get truncated so the 8K fragmented UDP
never gets through.
