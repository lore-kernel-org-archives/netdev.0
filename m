From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V3] qdisc: validate frames going through the
 direct_xmit path
Date: Wed, 03 Sep 2014 20:43:11 -0700 (PDT)
Message-ID: <20140903.204311.1364673588186463964.davem@davemloft.net>
References: <20140903114841.19969.22671.stgit@dragon>
	<20140903155508.23813.75407.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932163AbaIDDmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 23:42:11 -0400
In-Reply-To: <20140903155508.23813.75407.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 03 Sep 2014 17:56:09 +0200

> In commit 50cbe9ab5f8d ("net: Validate xmit SKBs right when we
> pull them out of the qdisc") the validation code was moved out of
> dev_hard_start_xmit and into dequeue_skb.
> 
> However this overlooked the fact that we do not always enqueue
> the skb onto a qdisc. First situation is if qdisc have flag
> TCQ_F_CAN_BYPASS and qdisc is empty.  Second situation is if
> there is no qdisc on the device, which is a common case for
> software devices.
> 
> Originally spotted and inital patch by Alexander Duyck.
> As a result Alex was seeing issues trying to connect to a
> vhost_net interface after commit 50cbe9ab5f8d was applied.
> 
> Added a call to validate_xmit_skb() in __dev_xmit_skb(), in the
> code path for qdiscs with TCQ_F_CAN_BYPASS flag, and in
> __dev_queue_xmit() when no qdisc.
> 
> Also handle the error situation where dev_hard_start_xmit() could
> return a skb list, and does not return dev_xmit_complete(rc) and
> falls through to the kfree_skb(), in that situation it should
> call kfree_skb_list().
> 
> Fixes:  50cbe9ab5f8d ("net: Validate xmit SKBs right when we pull them out of the qdisc")
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied.
