From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next 00/15] MTU/buffer reconfig changes
Date: Fri, 08 Apr 2016 15:34:32 -0400 (EDT)
Message-ID: <20160408.153432.1402033245186117258.davem@davemloft.net>
References: <1460054388-471-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36248 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758555AbcDHTeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 15:34:37 -0400
In-Reply-To: <1460054388-471-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Thu,  7 Apr 2016 19:39:33 +0100

> I re-discussed MPLS/MTU internally, dropped it from the patch 1,
> re-tested everything, found out I forgot about debugfs pointers,
> fixed that as well.
> 
> v5:
>  - don't reserve space in RX buffers for MPLS label stack
>    (patch 1);
>  - fix debugfs pointers to ring structures (patch 5).
> v4:
>  - cut down on unrelated patches;
>  - don't "close" the device on error path.
> 
> --- v4 cover letter
> 
> Previous series included some not entirely related patches,
> this one is cut down.  Main issue I'm trying to solve here
> is that .ndo_change_mtu() in nfpvf driver is doing full
> close/open to reallocate buffers - which if open fails
> can result in device being basically closed even though
> the interface is started.  As suggested by you I try to move
> towards a paradigm where the resources are allocated first
> and the MTU change is only done once I'm certain (almost)
> nothing can fail.  Almost because I need to communicate 
> with FW and that can always time out.
> 
> Patch 1 fixes small issue.  Next 10 patches reorganize things
> so that I can easily allocate new rings and sets of buffers
> while the device is running.  Patches 13 and 15 reshape the
> .ndo_change_mtu() and ethtool's ring-resize operation into
> desired form.

Looks good, series applied, thanks!
