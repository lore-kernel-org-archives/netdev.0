From: Amit Shah <amit.shah@redhat.com>
Subject: Re: [PATCH 2/2] virtio_net: Defer skb allocation in receive path
Date: Thu, 24 Dec 2009 19:07:49 +0530
Message-ID: <20091224133749.GB2855@amit-x200.redhat.com>
References: <1261122090.4148.24.camel@localhost.localdomain> <1261122289.4148.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63915 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751441AbZLXNiw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Dec 2009 08:38:52 -0500
Content-Disposition: inline
In-Reply-To: <1261122289.4148.27.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (Thu) Dec 17 2009 [23:44:49], Shirley Ma wrote:
> virtio_net receives packets from its pre-allocated vring buffers, then it 
> delivers these packets to upper layer protocols as skb buffs. So it's not
> necessary to pre-allocate skb for each mergable buffer, then frees extra 
> skbs when buffers are merged into a large packet. This patch has deferred 
> skb allocation in receiving packets for both big packets and mergeable buffers
> to reduce skb pre-allocations and skb frees. It frees unused buffers by calling 
> detach_unused_buf in vring, so recv skb queue is not needed.
> 
> Signed-off-by: Shirley Ma <xma@us.ibm.com>

...

> +static void free_unused_bufs(struct virtnet_info *vi)
> +{
> +	void *buf;
> +	while (vi->num) {
> +		buf = vi->rvq->vq_ops->detach_unused_buf(vi->rvq);
> +		if (!buf)
> +			continue;

Do you mean 'break' here?

> +		if (vi->mergeable_rx_bufs || vi->big_packets)
> +			give_pages(vi, buf);
> +		else
> +			dev_kfree_skb(buf);
> +		--vi->num;
> +	}
> +}
> +

		Amit
