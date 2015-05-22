From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rocker: move netevent neigh update to
 processes context
Date: Thu, 21 May 2015 23:29:45 -0400 (EDT)
Message-ID: <20150521.232945.93773536631316420.davem@davemloft.net>
References: <1432184707-27252-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	simon.horman@netronome.com, makita.toshiaki@lab.ntt.co.jp
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42345 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754853AbbEVD3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 23:29:48 -0400
In-Reply-To: <1432184707-27252-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Wed, 20 May 2015 22:05:07 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> In review of Simon's patchset "rocker: transaction fixes". it was noted
> that rocker->neigh_tbl_next_index was unprotected in the call path below
> and could race with other contexts calling rocker_port_ipv4_neigh():
> 
> 	arp_process()
> 	neigh_update()
> 	rocker_neigh_update()
> 	rocker_port_ipv4_neigh()
> 
> To fix, move the neigh_update() event processing to process contexts and
> hold rtnl_lock to call rocker_port_ipv4_neigh().  This will protect
> rocker->neigh_tbl_next_index accesses and is more consistent with the rest
> of the driver code where non-I/O processing is done under process context
> with rtnl_lock held.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Are you sure that the workqueue mechanism all by itself will ensure
that operations queued up will be processed in-order?

I do not know of any such explicit guarantee.

Therefore I think you will need a per-device workqueue with a list,
or something like that.

I could be wrong.
