From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] sfc: Allow driver to cope with a lower
 number of VIs than it needs for RSS
Date: Tue, 25 Aug 2015 11:14:49 -0700 (PDT)
Message-ID: <20150825.111449.2276623889939482929.davem@davemloft.net>
References: <55D6F2D7.4070707@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755497AbbHYSO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 14:14:56 -0400
In-Reply-To: <55D6F2D7.4070707@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Fri, 21 Aug 2015 10:43:51 +0100

> @@ -115,7 +115,7 @@ static struct workqueue_struct *reset_workqueue;
>   *
>   * This is only used in MSI-X interrupt mode
>   */
> -static bool separate_tx_channels;
> +bool separate_tx_channels;
 ...
> @@ -35,6 +35,7 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
>  int efx_setup_tc(struct net_device *net_dev, u8 num_tc);
>  unsigned int efx_tx_max_skb_descs(struct efx_nic *efx);
>  extern unsigned int efx_piobuf_size;
> +extern bool separate_tx_channels;

Once you put this into the global namespace, you should prefix it
with "efx_*" or similar to avoid namespace pollution issues.
