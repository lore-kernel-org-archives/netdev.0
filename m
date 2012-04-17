From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: gred: Fix oops in gred_dump() in WRED mode
Date: Mon, 16 Apr 2012 23:51:40 -0400 (EDT)
Message-ID: <20120416.235140.66658470499784164.davem@davemloft.net>
References: <1334529106-5035-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752586Ab2DQDvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 23:51:44 -0400
In-Reply-To: <1334529106-5035-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ward <david.ward@ll.mit.edu>
Date: Sun, 15 Apr 2012 18:31:45 -0400

> A parameter set exists for WRED mode, called wred_set, to hold the same
> values for qavg and qidlestart across all VQs. The WRED mode values had
> been previously held in the VQ for the default DP. After these values
> were moved to wred_set, the VQ for the default DP was no longer created
> automatically (so that it could be omitted on purpose, to have packets
> in the default DP enqueued directly to the device without using RED).
> 
> However, gred_dump() was overlooked during that change; in WRED mode it
> still reads qavg/qidlestart from the VQ for the default DP, which might
> not even exist. As a result, this command sequence will cause an oops:
> 
> tc qdisc add dev $DEV handle $HANDLE parent $PARENT gred setup \
>     DPs 3 default 2 grio
> tc qdisc change dev $DEV handle $HANDLE gred DP 0 prio 8 $RED_OPTIONS
> tc qdisc change dev $DEV handle $HANDLE gred DP 1 prio 8 $RED_OPTIONS
> 
> This fixes gred_dump() in WRED mode to use the values held in wred_set.
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

Applied and queued up for -stable, thanks David.
