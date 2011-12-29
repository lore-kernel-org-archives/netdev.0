From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: set/cancel work on ndo_open/ndo_stop
Date: Thu, 29 Dec 2011 16:44:52 -0500 (EST)
Message-ID: <20111229.164452.1646856455053448176.davem@davemloft.net>
References: <87hb0kgiwn.fsf@rustcorp.com.au>
	<20111229203302.GA5051@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37050 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754379Ab1L2Vo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 16:44:57 -0500
In-Reply-To: <20111229203302.GA5051@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 29 Dec 2011 22:33:02 +0200

> On Thu, Dec 29, 2011 at 01:53:52PM +1030, Rusty Russell wrote:
>> Michael S. Tsirkin noticed that we could run the refill work after
>> ndo_close, which can re-enable napi - we don't disable it until
>> virtnet_remove.  This is clearly wrong, so move the workqueue control
>> to ndo_open and ndo_stop (aka. virtnet_open and virtnet_close).
>> 
>> One subtle point: virtnet_probe() could simply fail if it couldn't
>> allocate a receive buffer, but that's less polite in virtnet_open() so
>> we schedule a refill as we do in the normal receive path if we run out
>> of memory.
>> 
>> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Applied.
