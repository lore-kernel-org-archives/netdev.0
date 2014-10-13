From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable 3.2 3.4] ipv4: disable bh while doing route gc
Date: Mon, 13 Oct 2014 12:52:25 -0400 (EDT)
Message-ID: <20141013.125225.1129718741415025861.davem@davemloft.net>
References: <6c3d6eca5d6a15c01393b010f2116bd169477c5a.1413215324.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33189 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041AbaJMQwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 12:52:30 -0400
In-Reply-To: <6c3d6eca5d6a15c01393b010f2116bd169477c5a.1413215324.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Date: Mon, 13 Oct 2014 13:20:38 -0300

> Further tests revealed that after moving the garbage collector to a work
> queue and protecting it with a spinlock may leave the system prone to
> soft lockups if bottom half gets very busy.
> 
> It was reproced with a set of firewall rules that REJECTed packets. If
> the NIC bottom half handler ends up running on the same CPU that is
> running the garbage collector on a very large cache, the garbage
> collector will not be able to do its job due to the amount of work
> needed for handling the REJECTs and also won't reschedule.
> 
> The fix is to disable bottom half during the garbage collecting, as it
> already was in the first place (most calls to it came from softirqs).
> 
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Please add my:

Acked-by: David S. Miller <davem@davemloft.net>

and submit this directly to -stable, thanks.
