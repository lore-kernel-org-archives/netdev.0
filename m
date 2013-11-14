From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2 2/2] macvtap: limit head length of skb allocated
Date: Thu, 14 Nov 2013 16:06:44 -0500 (EST)
Message-ID: <20131114.160644.936677620948788988.davem@davemloft.net>
References: <1384322440-29038-1-git-send-email-jasowang@redhat.com>
	<1384322440-29038-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, stefanha@redhat.com, gregory.v.rose@intel.com
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758020Ab3KNVGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:06:47 -0500
In-Reply-To: <1384322440-29038-2-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Wed, 13 Nov 2013 14:00:40 +0800

> We currently use hdr_len as a hint of head length which is advertised by
> guest. But when guest advertise a very big value, it can lead to an 64K+
> allocating of kmalloc() which has a very high possibility of failure when host
> memory is fragmented or under heavy stress. The huge hdr_len also reduce the
> effect of zerocopy or even disable if a gso skb is linearized in guest.
> 
> To solves those issues, this patch introduces an upper limit (PAGE_SIZE) of the
> head, which guarantees an order 0 allocation each time.
> 
> Cc: Stefan Hajnoczi <stefanha@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied and queued up for -stable.
