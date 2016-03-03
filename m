From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] arp: correct return value of arp_rcv
Date: Thu, 03 Mar 2016 16:30:01 -0500 (EST)
Message-ID: <20160303.163001.802969698569560829.davem@davemloft.net>
References: <1456817082-9320-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752995AbcCCVaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 16:30:03 -0500
In-Reply-To: <1456817082-9320-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Tue,  1 Mar 2016 07:24:42 +0000

> Currently, arp_rcv() always return zero on a packet delivery upcall.
> 
> To make its behavior more compliant with the way this API should be
> used, this patch changes this to let it return NET_RX_SUCCESS when the
> packet is proper handled, and NET_RX_DROP otherwise.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

This change is bogus.

> @@ -880,7 +880,7 @@ out:
>  	consume_skb(skb);
>  out_free_dst:
>  	dst_release(reply_dst);
> -	return 0;
> +	return NET_RX_SUCCESS;

Most of the paths to out: are dropping the request for one reason or
another.

If you want to do this right you need to split these two exit paths,
convert consume_skb() to kfree_skb() in the drop path, and then you
can return accurate NET_* codes.
