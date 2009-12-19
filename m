From: David Miller <davem@davemloft.net>
Subject: Re: e100 REGRESSION in 2.6.32 (PATCH v2)
Date: Fri, 18 Dec 2009 20:19:14 -0800 (PST)
Message-ID: <20091218.201914.102544489.davem@davemloft.net>
References: <Pine.LNX.4.44L0.0912171046070.2645-100000@iolanthe.rowland.org>
	<200912171810.45575.roger.oksanen@cs.helsinki.fi>
	<alpine.WNT.2.00.0912170919010.2612@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roger.oksanen@cs.helsinki.fi, stern@rowland.harvard.edu,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	e1000-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36598
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756039AbZLSETN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 23:19:13 -0500
In-Reply-To: <alpine.WNT.2.00.0912170919010.2612@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Thu, 17 Dec 2009 09:21:49 -0800 (Pacific Standard Time)

> 
> On Thu, 17 Dec 2009, Roger Oksanen wrote:
>> e100: Fix broken cbs accounting due to missing memset.
>> 
>> Alan Stern noticed that e100 caused slab corruption.
>> commit 98468efddb101f8a29af974101c17ba513b07be1 changed
>> the allocation of cbs to use dma pools that don't return zeroed memory,
>> especially the cb->status field used to track which cb to clean, causing
>> (the visible) double freeing of skbs and a wrong free cbs count.
>> 
>> Now the cbs are explicitly zeroed at allocation time.
>> 
>> Reported-by: Alan Stern <stern@rowland.harvard.edu>
>> Tested-by: Alan Stern <stern@rowland.harvard.edu>
>> Signed-off-by: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
> 
> Change looks reasonable, ACK.

Applied, thanks everyone.  I'll try to requeue the e100 stuff
together into -stable again now that this is resolved.

> should we also consider a followon patch to zero memory allocated with 
> pci_pools?  Seems useful.

Nah, it's more fun debugging subtle bugs like this one.
:-)
