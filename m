From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] net: w5100: enable to support sleepable register
 access interface
Date: Thu, 31 Mar 2016 15:30:40 -0400 (EDT)
Message-ID: <20160331.153040.1786802199114216613.davem@davemloft.net>
References: <1459355920-14623-1-git-send-email-akinobu.mita@gmail.com>
	<1459355920-14623-3-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, msink@permonline.ru
To: akinobu.mita@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57854 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbcCaTam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 15:30:42 -0400
In-Reply-To: <1459355920-14623-3-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Thu, 31 Mar 2016 01:38:39 +0900

> +	struct sk_buff_head tx_queue;

The way the queueing works in this driver is that it is only possible
to have one SKB being transmitted at one time.

This is evident by how the driver immediately stops the TX queue when
it is given a new packet to transmit, and this is woken up by the TX
completion IRQ.

So don't use a queue here, just use a plain single pointer.

The SKB queue you're using here is going to also do locking which is
even more unnecessary overhead.

Thanks.
