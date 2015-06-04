From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] rocker: move netevent neigh update to
 processes context
Date: Wed, 03 Jun 2015 23:38:29 -0700 (PDT)
Message-ID: <20150603.233829.1362177764562847830.davem@davemloft.net>
References: <1433303008-32656-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	simon.horman@netronome.com, makita.toshiaki@lab.ntt.co.jp
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbbFDGid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 02:38:33 -0400
In-Reply-To: <1433303008-32656-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Tue,  2 Jun 2015 20:43:28 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> v2:
> 
> Changes based on review:
> 
> - David Miller <davem@davemloft.net> raise problem with system_wq not
>   preserving queue order to execution order.  To fix, use driver-private
>   ordered workqueue to preserve ordering of queued work.
> 
> - Jiri Pirko <jiri@resnulli.us> small change on kfree of work queue item.
> 
> v1:
> 
> In review of Simon's patchset "rocker: transaction fixes". it was noted
> that rocker->neigh_tbl_next_index was unprotected in the call path below
> and could race with other contexts calling rocker_port_ipv4_neigh():

How it rocker->neigh_tbl_next_index not protected?

rocker->neigh_tbl_lock is _always_ held when it is accessed.

This patch, therefore, looks like completely unnecessary complexity
to me.  Furthermore, I would completely prefer if the operation stays
completely synchronous to the call path where the neigh operation
occurs rather than throwing it out to a workqueue.

Thanks.
