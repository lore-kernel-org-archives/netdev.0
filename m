From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnxt_en: Fix potential race condition in
 bnxt_tx_enable()
Date: Fri, 15 Jul 2016 23:20:48 -0700 (PDT)
Message-ID: <20160715.232048.1780795244111833927.davem@davemloft.net>
References: <1468626125-31732-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
	huangjw@broadcom.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60176 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbcGPGUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 02:20:49 -0400
In-Reply-To: <1468626125-31732-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 15 Jul 2016 16:42:01 -0700

> @@ -4599,7 +4599,9 @@ static void bnxt_tx_enable(struct bnxt *bp)
>  	for (i = 0; i < bp->tx_nr_rings; i++) {
>  		txr = &bp->tx_ring[i];
>  		txq = netdev_get_tx_queue(bp->dev, i);
> +		__netif_tx_lock(txq, smp_processor_id());
>  		txr->dev_state = 0;
> +		__netif_tx_unlock(txq);

You're going to have to explain how this could possibly cause a
problem, because I'm pretty sure it can't.

Either the reader sees 0, or non-zero, in this value.

And adding locking around this assignment does not change that at all.
