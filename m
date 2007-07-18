From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Socket Buffers and Memory Managment
Date: Wed, 18 Jul 2007 22:22:40 +0100
Message-ID: <20070718222240.7fd519a7@oldman>
References: <551531.35231.qm@web82912.mail.mud.yahoo.com>
	<20070717204129.79e7fe0d@oldman>
	<469E4A31.6030603@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vinay ravuri <vinaynyc@yahoo.com>, netdev@vger.kernel.org
To: Roy Pledge <Roy.Pledge@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51654 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757914AbXGRVXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 17:23:25 -0400
In-Reply-To: <469E4A31.6030603@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Jul 2007 13:13:21 -0400
Roy Pledge <Roy.Pledge@freescale.com> wrote:

> Stephen Hemminger wrote:
> > 
> > You could play tricks with skb frags but it would be fragile
> > and not worth the trouble. The problem is that the receive
> > skb can stay in the system for a really long time (until the application
> > reads the data) so your fixed size buffer pool in hardware
> > would get exhausted.
> >  
> Perhaps you could elaborate on why this is considered fragile?  It seems to me 
> that as long as proper page management is performed, this mechanism should be 
> stable for processing non-contiguous receive buffers.  I agree that 
> replenishment needs to be addressed, but I see that as an independent issue from 
> using frag lists on receive.

Imagine you had a 4MB receive area. If you used fraglist to point to
the data area, you would still be at risk of receive lock up when you have
all the receive area used up in skb's waiting in the receive queue of the
sockets. You might get it to work if the receive are was very large (ie much
larger than tcp_rmem), but at that point you might as well as be able
to access all of system memory.

Using a DMA I/O engine would help, but you probably won't have one available.
