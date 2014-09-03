From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] qdisc: validate frames going through the
 direct_xmit path
Date: Wed, 03 Sep 2014 06:43:25 -0700
Message-ID: <1409751805.26422.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140902225548.885.79277.stgit@ahduyck-bv4.jf.intel.com>
	 <20140903114841.19969.22671.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:60018 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932431AbaICNn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 09:43:29 -0400
Received: by mail-pd0-f180.google.com with SMTP id p10so11110136pdj.25
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 06:43:26 -0700 (PDT)
In-Reply-To: <20140903114841.19969.22671.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-03 at 13:48 +0200, Jesper Dangaard Brouer wrote:
> In commit 50cbe9ab5f8d ("net: Validate xmit SKBs right when we pull them
> out of the qdisc") the validation code was moved out of dev_hard_start_xmit
> and into dequeue_skb. However this overlooked the fact that we do not
> always enqueue the skb onto a qdisc, if qdisc have flag TCQ_F_CAN_BYPASS.
> 
> As a result Alex was seeing issues trying to connect to a vhost_net interface
> after this patch was applied.
> 
> Added a call to validate_xmit_skb in __dev_xmit_skb(), in the code path
> for qdiscs with TCQ_F_CAN_BYPASS flag.
> 
> Fixes:  50cbe9ab5f8d ("net: Validate xmit SKBs right when we pull them out of the qdisc")
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---

Jesper, you missed another spot, when there is no qdisc on the device.

__dev_queue_xmit() calls dev_hard_start_xmit() around line 2886

Could we try to not add a myriad of small patches ?

Some of us will need to backport all of them.

Thanks.
