From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Address reference counting issues with
 sock_queue_err_skb
Date: Fri, 12 Sep 2014 17:51:52 -0400 (EDT)
Message-ID: <20140912.175152.1650460189977574534.davem@davemloft.net>
References: <20140910215837.23225.39149.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	johannes@sipsolutions.net, eric.dumazet@gmail.com,
	linville@tuxdriver.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753025AbaILVvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 17:51:54 -0400
In-Reply-To: <20140910215837.23225.39149.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 10 Sep 2014 18:04:42 -0400

> After looking over the code for skb_clone_sk after some comments made by
> Eric Dumazet I have come to the conclusion that skb_clone_sk is taking the
> correct approach in how to handle the sk_refcnt when creating a buffer that
> is eventually meant to be returned to the socket via the sock_queue_err_skb
> function.
> 
> However upon review of other callers I found what I believe to be a
> possible reference count issue in the path for handling "wifi ack" packets.
> To address this I have applied the same logic that is currently in place so
> that the sk_refcnt will be forced to stay at least 1, or we will not
> provide an skb to return in the sk_error_queue.

Series applied, thanks Alex.
