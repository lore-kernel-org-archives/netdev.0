From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
 2014-10-23
Date: Fri, 24 Oct 2014 16:43:27 -0400 (EDT)
Message-ID: <20141024.164327.535125094046571848.davem@davemloft.net>
References: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52977 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbaJXUnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 16:43:32 -0400
In-Reply-To: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 23 Oct 2014 21:09:57 -0700

> This series contains updates to i40e and i40evf.
> 
> Jesse modifies the i40e driver to only notify the firmware on link up/down
> and qualified module events.  Also simplified the job of managing link
> state by using the admin queue receive event for link events as a signal
> to tell the driver to update link state.
> 
> Jeff (me) cleans up the inconsistent use of tabs for indentation in the admin
> queue command header file.
> 
> Neerav converts the use of udelay() to usleep_range().
> 
> Anjali fixes a bug where receive would stop after some stress by adding
> a sleep and restart as well as moving the setting of flow control because
> it should be done at a PF level and not a VSI level.
> 
> Mitch adds code to handle link events when updating the PF switch, which
> allows link information to be properly provided to VFS in all cases.
> 
> Catherine adds driver support for 10GBaseT and bumps driver version.

I've pulled, but I absolutely don't like that change that moved the
variables out of the loop.

Putting variables in the inner-most scope of their use is always the
best choice because:

1) Auditing is easier, because you are constraining the scope in
   which you have to check if the variable is setup properly
   before it is used.

2) You are helping the compiler out, because you have done the
   majority of solving the graph coloring problem for it and the
   compiler therefore has less work to do.

Please don't make changes like this in the future, and instead do the
opposite, by moving more variable declarations into their innermost
possible scope.

Thanks.
