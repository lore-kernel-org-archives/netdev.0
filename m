From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/15] BE NIC driver - header and initialization
	functions
Date: Fri, 16 May 2008 06:06:42 -0400
Message-ID: <20080516100642.GA18884@infradead.org>
References: <20080515090240.5ecbd2e3@mailhost.serverengines.com> <Pine.LNX.4.64.0805161146110.1888@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Subbu Seetharaman <subbus@serverengines.com>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:45977 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbYEPKGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 06:06:45 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805161146110.1888@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2008 at 12:54:11PM +0300, Ilpo J?rvinen wrote:
> > +		pnob->event_q_pa = virt_to_phys(pnob->event_q);
> > +		pnob->event_q_pa = cpu_to_le64(pnob->event_q_pa);
> 
> ...First of all, points from using standard converters instead of 
> inventing your own :-).
> 
> But alas, it won't be accepted by sparse. You need to use appropriate 
> le/be8/16/32/64 types when dealing with endianesses and then make sparse 
> happy too by using conversion in proper places. 

And virt_to_phys is a big no-way.  The driver needs to use the proper
dma api helpers to deal with iommus and other non-trivial hardware.

