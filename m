From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/hyperv: fix the issue that large packets be
 dropped by bridge
Date: Wed, 01 Feb 2012 14:28:05 -0500 (EST)
Message-ID: <20120201.142805.256231314680157196.davem@davemloft.net>
References: <CAPgLHd-Z2B88ZxCKmKuRTcndJXt2y3N00MazBxD7aXKUVhywqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, kys@microsoft.com, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755639Ab2BAT2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 14:28:11 -0500
In-Reply-To: <CAPgLHd-Z2B88ZxCKmKuRTcndJXt2y3N00MazBxD7aXKUVhywqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 30 Jan 2012 16:12:45 +0800

> +	/*
> +	 * Make sure we got a valid packet message, now total_data_buflen
> +	 * should be the data packet size plus the trailer padding size
> +	 */
> +	if (pkt->total_data_buflen < rndis_pkt->data_len) {
> +		netdev_err(dev->net_dev->ndev, "incoming packet message "
> +			   "buffer overflow detected (got %u, min %u)"
> +			   "...dropping this message!\n",
> +			   pkt->total_data_buflen, rndis_pkt->data_len);
> +		return;
> +	}

This is inappropriate.  Any logging message that is potentially remotely
triggerable must at a minimum be rate limited.  But to be honest I'd
much prefer a statistic counter for this kind of event, rather then
a log message.

I'm not applying this patch.
