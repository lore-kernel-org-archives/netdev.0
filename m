From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH 3/4] drivers/net/can/mscan/mpc5xxx_can.c: Add of_node_put
 to avoid memory leak
Date: Tue, 31 Aug 2010 18:55:45 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008311853040.2668@ask.diku.dk>
References: <1283269738-14612-1-git-send-email-julia@diku.dk>
 <1283269738-14612-4-git-send-email-julia@diku.dk> <20100831165153.GB28015@pengutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	kernel-janitors@vger.kernel.org,
	Grant Likely <grant.likely@secretlab.ca>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:41058 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751755Ab0HaQzr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 12:55:47 -0400
In-Reply-To: <20100831165153.GB28015@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Aug 2010, Wolfram Sang wrote:

> On Tue, Aug 31, 2010 at 05:48:57PM +0200, Julia Lawall wrote:
> > Add a call to of_node_put in the error handling code following a call to
> > of_find_matching_node.
> > 
> > This patch also moves the existing call to of_node_put after the call to
> > iounmap in the error handling code, to make it possible to jump to
> > of_node_put without doing iounmap.  These appear to be disjoint operations,
> > so the ordering doesn't matter.
> 
> Hmm, the function you change returns -ENODEV if a clock cannot be found, but
> the return type is u32. This should better be 0. Can you take care of this as
> well?

I'll look at it.  I was trying to make the returned value be signed, which 
seemed to have some slightly complicated repercussions, but a return value 
of 0 may work out much better.

julia
