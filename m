From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vrf: Add ethernet header for pass through VRF
 device
Date: Tue, 25 Aug 2015 14:02:20 -0700 (PDT)
Message-ID: <20150825.140220.156958823239060297.davem@davemloft.net>
References: <1440355260-16528-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbbHYVCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 17:02:21 -0400
In-Reply-To: <1440355260-16528-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sun, 23 Aug 2015 12:41:00 -0600

> @@ -250,6 +253,17 @@ static netdev_tx_t vrf_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  static netdev_tx_t vrf_finish(struct sock *sk, struct sk_buff *skb)
>  {
> +	int err;
> +
> +	__skb_pull(skb, skb_network_offset(skb));
> +	err = dev_hard_header(skb, skb->dev, ntohs(skb->protocol),
> +			      NULL, NULL, skb->len);
> +
> +	if (err < 0) {
> +		vrf_tx_error(skb->dev, skb);
> +		return -EINVAL;
> +	}
> +
>  	return dev_queue_xmit(skb);

This is expensive and rediculous to do for every TX frame.

You'll need to find another way.
