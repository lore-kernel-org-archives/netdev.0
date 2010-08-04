From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH net-next 09/14] tg3: Improve small packet performance
Date: Thu, 5 Aug 2010 08:27:41 +1000
Message-ID: <20100804222741.GA18708@kryten>
References: <1280784368-4226-9-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, andy@greyhouse.net,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46906 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756739Ab0HDWcV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 18:32:21 -0400
Content-Disposition: inline
In-Reply-To: <1280784368-4226-9-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

Just saw this go in:
  
>  static inline u32 tg3_tx_avail(struct tg3_napi *tnapi)
>  {
> -	smp_mb();
> +	/* Tell compiler to fetch tx indices from memory. */
> +	barrier();
>  	return tnapi->tx_pending -
>  	       ((tnapi->tx_prod - tnapi->tx_cons) & (TG3_TX_RING_SIZE - 1));
>  }

Which worries me. Are we sure we don't need any ordering (eg smp_rmb)?
A compiler barrier does nothing to ensure two loads are ordered.

Anton
