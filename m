From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: fix ring init when there are more TX than RX
 channels
Date: Tue, 25 Nov 2014 14:33:52 -0500 (EST)
Message-ID: <20141125.143352.669361329120151757.davem@davemloft.net>
References: <1416932471-8744-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, prashant@broadcom.com, mchan@broadcom.com
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37480 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbaKYTdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 14:33:54 -0500
In-Reply-To: <1416932471-8744-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Tue, 25 Nov 2014 14:21:11 -0200

> @@ -8563,7 +8563,8 @@ static int tg3_init_rings(struct tg3 *tp)
>  		if (tnapi->rx_rcb)
>  			memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
>  
> -		if (tg3_rx_prodring_alloc(tp, &tnapi->prodring)) {
> +		if (tnapi->prodring.rx_std &&
> +		    tg3_rx_prodring_alloc(tp, &tnapi->prodring)) {
>  			tg3_free_rings(tp);
>  			return -ENOMEM;

Maybe a better test is "i < tp->rxq_cnt"?  This is what is used in
tg3_mem_rx_acquire() to determine if tg3_rx_prodring_init() happens.
