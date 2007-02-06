From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] tg3 : avoid an expensive divide
Date: Tue, 06 Feb 2007 14:05:41 -0800
Message-ID: <1170799541.3535.25.camel@rh4>
References: <20070103163627.14635.88250.stgit@nienna.balabit>
 <45A48BEB.2070207@trash.net> <200702061536.18800@nienna>
 <20070206.114659.107250775.davem@davemloft.net>
 <45C8EAC4.9020803@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4086 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965500AbXBFVVr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 16:21:47 -0500
In-Reply-To: <45C8EAC4.9020803@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-02-06 at 21:53 +0100, Eric Dumazet wrote:

> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> plain text document attachment (tg3_avoid_divide.patch)
> --- linux-2.6.20/drivers/net/tg3.c.orig	2007-02-06 22:30:39.000000000 +0100
> +++ linux-2.6.20-ed/drivers/net/tg3.c	2007-02-06 22:32:42.000000000 +0100
> @@ -3384,7 +3384,7 @@
>  		}
>  next_pkt_nopost:
>  		sw_idx++;
> -		sw_idx %= TG3_RX_RCB_RING_SIZE(tp);
> +		sw_idx &= (TG3_RX_RCB_RING_SIZE(tp) - 1);
>  
>  		/* Refresh hw_idx to see if there is new work */
>  		if (sw_idx == hw_idx) {

There are other places doing similar divide (e.g. tg3_recycle_rx(),
tg3_alloc_rx_skb()).  I think we should change them all.

