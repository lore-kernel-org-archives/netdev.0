From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netfront: avoid leaking resources when
 setup_netfront fails
Date: Sun, 19 May 2013 23:28:33 -0700 (PDT)
Message-ID: <20130519.232833.988876168197782913.davem@davemloft.net>
References: <1368783838-24187-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457Ab3ETG2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 02:28:34 -0400
In-Reply-To: <1368783838-24187-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Fri, 17 May 2013 10:43:58 +0100

>  
> + /* If we fail to setup netfront, it is safe to just revoke access to granted
> +  * pages because backend is not accessing it at this point.
> +  */
> + bind_fail:
> +	xenbus_free_evtchn(dev, info->evtchn);
> + alloc_evtchn_fail:
> +	gnttab_end_foreign_access_ref(info->rx_ring_ref, 0);
> + grant_rx_ring_fail:
> +	free_page((unsigned long)rxs);
> + alloc_rx_ring_fail:
> +	gnttab_end_foreign_access_ref(info->tx_ring_ref, 0);
> + grant_tx_ring_fail:
> +	free_page((unsigned long)txs);
>   fail:
>  	return err;
>  }

This is not even close to adhering to proper coding style.

The comment should be indented by one tab not one space:

	/* Like
	 * this.
	 */

And the code labels should appear at the first column, not
with a leading space.
