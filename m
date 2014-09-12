From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IB/ipoib: order:1 failure in ipoib_cm_alloc_rx_skb
 causes softlockup
Date: Fri, 12 Sep 2014 15:20:22 -0400 (EDT)
Message-ID: <20140912.152022.1499599699035890349.davem@davemloft.net>
References: <1410538533-11029-1-git-send-email-venkat.x.venkatsubra@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: venkat.x.venkatsubra@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998AbaILTUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 15:20:25 -0400
In-Reply-To: <1410538533-11029-1-git-send-email-venkat.x.venkatsubra@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Date: Fri, 12 Sep 2014 09:15:33 -0700

> @@ -61,6 +61,11 @@ enum ipoib_flush_level {
>  	IPOIB_FLUSH_HEAVY
>  };
>  
> +#ifdef max
> +#undef max
> +#endif
> +#define max(x, y) (((int)(x) > (int)(y)) ? x : y)
> +
>  enum {
>  	IPOIB_ENCAP_LEN		  = 4,
>  

This is insanely inappropriate.

Use the linux/kernel.h provided max() definition, there is no reason
to redefine your own version, ever.
