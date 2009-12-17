From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: e100 REGRESSION in 2.6.32 (PATCH v2)
Date: Thu, 17 Dec 2009 09:21:49 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.0912170919010.2612@jbrandeb-desk1.amr.corp.intel.com>
References: <Pine.LNX.4.44L0.0912171046070.2645-100000@iolanthe.rowland.org> <200912171810.45575.roger.oksanen@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alan Stern <stern@rowland.harvard.edu>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Kernel development list <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:25899 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759486AbZLQRVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2009 12:21:53 -0500
In-Reply-To: <200912171810.45575.roger.oksanen@cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 17 Dec 2009, Roger Oksanen wrote:
> e100: Fix broken cbs accounting due to missing memset.
> 
> Alan Stern noticed that e100 caused slab corruption.
> commit 98468efddb101f8a29af974101c17ba513b07be1 changed
> the allocation of cbs to use dma pools that don't return zeroed memory,
> especially the cb->status field used to track which cb to clean, causing
> (the visible) double freeing of skbs and a wrong free cbs count.
> 
> Now the cbs are explicitly zeroed at allocation time.
> 
> Reported-by: Alan Stern <stern@rowland.harvard.edu>
> Tested-by: Alan Stern <stern@rowland.harvard.edu>
> Signed-off-by: Roger Oksanen <roger.oksanen@cs.helsinki.fi>

Change looks reasonable, ACK.

should we also consider a followon patch to zero memory allocated with 
pci_pools?  Seems useful.

Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
