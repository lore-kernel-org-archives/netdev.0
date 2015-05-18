From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-packet: fix null pointer exception in
 rollover mode
Date: Sun, 17 May 2015 22:42:01 -0400 (EDT)
Message-ID: <20150517.224201.2115540798928063394.davem@davemloft.net>
References: <1431906242-26430-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50926 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbbERCm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 22:42:56 -0400
In-Reply-To: <1431906242-26430-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Sun, 17 May 2015 19:44:02 -0400

> Rollover can be enabled as flag or mode. Allocate state in both cases.
> This solves a NULL pointer exception in fanout_demux_rollover on
> referencing po->rollover if using mode rollover.
> 
> Also make sure that in rollover mode each silo is tried (contrary
> to rollover flag, where the main socket is excluded after an initial
> try_self).
> 
> Tested:
>   Passes tools/testing/net/psock_fanout.c, which tests both modes and
>   flag. My previous tests were limited to bench_rollover, which only
>   stresses the flag. The test now completes safely. it still gives an
>   error for mode rollover, because it does not expect the new headroom
>   (ROOM_NORMAL) requirement. I will send a separate patch to the test.
> 
> Fixes: 0648ab70afe6 ("packet: rollover prepare: per-socket state")
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks Willem.
