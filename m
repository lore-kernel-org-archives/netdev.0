From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] packet: respect devices with LLTX flag in
 direct xmit
Date: Fri, 28 Mar 2014 16:50:58 -0400 (EDT)
Message-ID: <20140328.165058.1610297081920676758.davem@davemloft.net>
References: <1395934710-29182-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbaC1UvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 16:51:00 -0400
In-Reply-To: <1395934710-29182-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 27 Mar 2014 16:38:30 +0100

> Quite often it can be useful to test with dummy or similar
> devices as a blackhole sink for skbs. Such devices are only
> equipped with a single txq, but marked as NETIF_F_LLTX as
> they do not require locking their internal queues on xmit
> (or implement locking themselves). Therefore, rather use
> HARD_TX_{UN,}LOCK API, so that NETIF_F_LLTX will be respected.
> 
> trafgen mmap/TX_RING example against dummy device with config
> foo: { fill(0xff, 64) } results in the following performance
> improvements for such scenarios on an ordinary Core i7/2.80GHz:
 ...
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>

Applied, nice work.

The only remaining issue is that Eric seems to suggest that a tx
dropped counter bump should be added.  Please submit that as a
follow-on if my reading of his feedback is accurate.
