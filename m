From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/8] net: ethernet: marvell: Assorted fixes
Date: Fri, 23 May 2014 15:36:16 -0400 (EDT)
Message-ID: <20140523.153616.2078296737930596480.davem@davemloft.net>
References: <1400800023-1562-1-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	sebastian.hesselbarth@gmail.com,
	gregory.clement@free-electrons.com, alior@marvell.com,
	tawfik@marvell.com, andrew@lunn.ch
To: ezequiel.garcia@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54982 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbaEWTgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 15:36:19 -0400
In-Reply-To: <1400800023-1562-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Date: Thu, 22 May 2014 20:06:55 -0300

> New round for this assorted fixes and clean-up series. There is more room for
> clean-ups, and I'll start preparing more patches once these are accepted.
> 
> This series consists of cleanups and minor improvements on mvneta, mv643xx_eth
> and mvmdio drivers. None of the patches imply any functionality change, except
> for the patch six "Change the number of default rx queues to one".
> 
> This patch reduces the driver's allocated resources and makes the multiqueue
> path in the poll function not get taken. The previous patchset contains more
> details:
> 
>   http://permalink.gmane.org/gmane.linux.network/315015
> 
> As usual, any feedback on this will be well received!

Series applied to net-next, but some comments:

1) Never use web sites to reference informative material, instead put it
   all explicitly into the commit message in your posting.

   Web sites and archives come and go, the commit message is forever and
   readily available to someone studying your changes.

2) Just get rid of that MVNETA_RX_POLL_WEIGHT and simply use the
   generic default NAPI_POLL_WEIGHT which has the same value.

   Any local NAPI weight selection must be done for a good reason and
   be fully documented with performance metrics et al.

3) I know you inherited this, but the MTU change failure behavior is
   not so great.  If the system is low on memory it could fail and losing
   an interface completely during an MTU change is extremely poor behavior.

   I would suggest holding onto the old allocated TXQ resources, and
   restoring them if the allocation of the new ones fail.

   That way the MTU change itself would fail, but the interface would
   remain up with the original MTU.

   Please make sure that you properly revert the MTU adjustment in
   this failure path.

Thanks.
