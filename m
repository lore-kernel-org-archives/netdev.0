From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netxen: Add sanity checks for Rx buffers returning
 from hardware
Date: Thu, 19 Dec 2013 15:05:27 -0500 (EST)
Message-ID: <20131219.150527.1753716895684393783.davem@davemloft.net>
References: <1387257753-18676-1-git-send-email-david@gibson.dropbear.id.au>
	<1387257753-18676-3-git-send-email-david@gibson.dropbear.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com, netdev@vger.kernel.org,
	snagarka@redhat.com, tcamuso@redhat.com, vdasgupt@redhat.com
To: david@gibson.dropbear.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755634Ab3LSUFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 15:05:30 -0500
In-Reply-To: <1387257753-18676-3-git-send-email-david@gibson.dropbear.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Gibson <david@gibson.dropbear.id.au>
Date: Tue, 17 Dec 2013 16:22:33 +1100

> +static int netxen_check_rx_buf(int index, struct netxen_rx_buffer *rxbuf)
> +{
> +	int ret = 0;
> +
> +	if ((rxbuf->list.next != LIST_POISON1)
> +	    || (rxbuf->list.prev != LIST_POISON2)) {
> +		printk(KERN_ERR "netxen: Rx buffer is already on free list "
> +		       "(next=%p, prev=%p)\n", rxbuf->list.next,
> +		       rxbuf->list.prev);
> +		ret = -1;
> +	}

First, you should be using netdev_err() or similar.

Second, doing this unconditionally for every receive packet is
not really reasonable.
