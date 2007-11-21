From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/8] ibm_newemac: Fix possible lockup on close
Date: Thu, 22 Nov 2007 06:53:11 +1100
Message-ID: <1195674791.6970.95.camel@pasglop>
References: <1195625198.76200.922309668615.qpush@grosgo>
	 <20071121060729.71A1FDDE01@ozlabs.org>  <20071121154123.GB23589@lst.de>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:43405 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753402AbXKUTzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 14:55:08 -0500
In-Reply-To: <20071121154123.GB23589@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2007-11-21 at 16:41 +0100, Christoph Hellwig wrote:
> On Wed, Nov 21, 2007 at 05:06:39PM +1100, Benjamin Herrenschmidt wrote:
> > It's a bad idea to call flush_scheduled_work from within a
> > netdev->stop because the linkwatch will occasionally take the
> > rtnl lock from a workqueue context, and thus that can deadlock.
> > 
> > This reworks things a bit in that area to avoid the problem.
> 
> So from the name of the driver you want to keep the previous emac
> driver around.  Is there a good reason for that?

Until arch/ppc is gone... the previous driver works with arch/ppc the
new one with arch/powerpc.

If we kill arch/ppc in .25, then we'll remove the old driver and rename
the new one. If not, that will wait til .26

I'm hard at work porting as much of 4xx over I can to get to the point
where we -can- kill arch/ppc but I'm not done yet.

Cheers,
Ben.

