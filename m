From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/2] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods (v3)
Date: Sun, 21 Aug 2011 20:27:50 -0400
Message-ID: <20110822002641.GA2550@neilslaptop.think-freely.org>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
 <1311696338-4739-1-git-send-email-nhorman@tuxdriver.com>
 <1313593637.2776.9.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34018 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756122Ab1HVA2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2011 20:28:08 -0400
Content-Disposition: inline
In-Reply-To: <1313593637.2776.9.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2011 at 04:07:17PM +0100, Ben Hutchings wrote:
> On Tue, 2011-07-26 at 12:05 -0400, Neil Horman wrote:
> > Ok, after considering all your comments, Dave suggested this as an alternate
> > approach:
> > 
> > 1) We create a new priv_flag, IFF_SKB_TX_SHARED, to identify drivers capable of
> > handling shared skbs.  Default is to not set this flag
> > 
> > 2) Modify ether_setup to enable this flag, under the assumption that any driver
> > calling this  function is initalizing a real ethernet device and as such can
> > handle shared skbs since they don't tend to store state in the skb struct.
> > Pktgen can then query this flag when a user script attempts to issue the
> > clone_skb command and decide if it is to be alowed or not.
> [...]
> 
> A bunch of Ethernet drivers do skb_pad() or skb_padto() in their
> ndo_start_xmit implementations, either to avoid hardware bugs or because
> the MAC doesn't automatically pad to the minimum frame length.  This
> presumably means they can't generally handle shared skbs, though in the
> specific case of pktgen it should be safe as long as a single skb is not
> submitted by multiple threads at once.
> 
Agreed, given that pktgen is doing skb sharing in a serialized manner (i.e. one
thread of execution increasing skb->users rather than in multiple threads), the
skb_pad[to] cases are safe.  Are there cases in which shared skbs are
transmitted in parallel threads that we need to check for?
Neil

> Ben.
> 
> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 
