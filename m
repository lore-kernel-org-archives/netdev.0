From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] bna: Update driver version to 3.0.23.0 (resubmit)
Date: Wed, 04 Apr 2012 18:21:05 -0400 (EDT)
Message-ID: <20120404.182105.1576892492865932011.davem@davemloft.net>
References: <1333554102-21973-1-git-send-email-huangj@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, AdapterLinuxOpenSrcExtTeam@Brocade.COM
To: huangj@Brocade.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50446 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753868Ab2DDWWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 18:22:09 -0400
In-Reply-To: <1333554102-21973-1-git-send-email-huangj@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jing Huang <huangj@Brocade.COM>
Date: Wed, 4 Apr 2012 08:41:42 -0700

> I am resubmit this patch set since it seems that the net-next merge window is
> over. 
> 
> This patch set contains fixes in adapter initialization and tx/rx cleanup path.
> It also include code cleanups by removing and renaming some functions.
> 
> The driver version has been updated to 3.0.23.0 to reflect the changes.

All applied.

But I would suggest modifying how the driver spins waiting for the
firmware to release semaphore bits in registers.

You have no timeouts or limits in these loops.

So if the firmware crashes or gets stuck, this will take out the
entire computer which is very undesirable.

Change these loops to have a limit and signal an error and fail the
top-level operation if the limit is hit.
