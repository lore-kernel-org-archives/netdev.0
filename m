From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] sir: switch to a workqueue
Date: Sat, 15 Apr 2006 18:37:12 +0200
Message-ID: <20060415163712.GA13342@lst.de>
References: <20060414182015.GA20662@lst.de> <Pine.LNX.4.44.0604151444521.19061-100000@notebook.home.mdiehl.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, Jean Tourrilhes <jt@hpl.hp.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:14300 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1030284AbWDOQhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2006 12:37:35 -0400
To: Martin Diehl <info@mdiehl.de>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0604151444521.19061-100000@notebook.home.mdiehl.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 15, 2006 at 04:24:15PM +0200, Martin Diehl wrote:
> 
> My only concern with this patch is this:

<..>

> Hm, queue_work might fail (like it was possible with irda_queue_request), 
> if work->pending is set. In that case, chances are we have a partially 
> configured irda device dangling around. The idea was to (re-)enable rx and 
> restore the xmit queue state on netdev so we can rely on the upper layers 
> to recover. I think without the fallback the netdev might become unuseable 
> until ifdown/ifup-cycle, if queue_work would ever fail.

queue_work doesn't fail if work->pending, it just noticed this
particular work_Struct is already beeing serviced and tells you that.
In the sir code that can't happen because the work_struct has ben
allocated and initialized a few lines above, so there's zero chance for
someone else to call queue_work on it concurrently.

