From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: thunderx: Fix transmit queue timeout
 issue
Date: Wed, 30 Nov 2016 14:11:21 -0500 (EST)
Message-ID: <20161130.141121.375154493677208609.davem@davemloft.net>
References: <1480419620-32500-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, sgoutham@cavium.com
To: sunil.kovvuri@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39832 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754198AbcK3TL0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 14:11:26 -0500
In-Reply-To: <1480419620-32500-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sunil.kovvuri@gmail.com
Date: Tue, 29 Nov 2016 17:10:20 +0530

> +		/* Check again, incase another cpu freed descriptors */
> +		if (atomic_read(&sq->free_cnt) > MIN_SQ_DESC_PER_PKT_XMIT) {
> +			netif_tx_start_queue(txq);

You have to use netif_tx_wake_queue() any time you restart a queue after bringing
the device up.
