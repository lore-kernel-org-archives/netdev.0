From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: skb_tx_hash() improvements
Date: Fri, 01 May 2009 09:17:47 -0700 (PDT)
Message-ID: <20090501.091747.240476627.davem@davemloft.net>
References: <49FAB2D5.60508@cosmosbay.com>
	<49FAB831.6020700@cosmosbay.com>
	<49FAC112.6090808@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@whydna.net, jelaas@gmail.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50502
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762379AbZEAQRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 12:17:53 -0400
In-Reply-To: <49FAC112.6090808@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 01 May 2009 11:29:54 +0200

> -	} else if (skb->sk && skb->sk->sk_hash) {
> +		/*
> +		 * Try to avoid an expensive divide, for symmetric setups :
> +		 *   number of tx queues of output device ==
> +		 *   number of rx queues of incoming device
> +		 */
> +		if (hash >= dev->real_num_tx_queues)
> +			hash %= dev->real_num_tx_queues;
> +		return hash;
> +	}

Subtraction in a while() loop is almost certainly a lot
faster.
