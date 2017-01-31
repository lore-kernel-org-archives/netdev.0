From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/10] bnxt_en: Refactor rx SKB function.
Date: Tue, 31 Jan 2017 13:27:01 -0500 (EST)
Message-ID: <20170131.132701.722163772922806769.davem@davemloft.net>
References: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
        <1485827375-20421-2-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40878 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751195AbdAaS1G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:27:06 -0500
In-Reply-To: <1485827375-20421-2-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Mon, 30 Jan 2017 20:49:26 -0500

> @@ -776,7 +778,7 @@ static struct sk_buff *bnxt_rx_skb(struct bnxt *bp,
>  	}
>  
>  	skb_reserve(skb, BNXT_RX_OFFSET);
> -	skb_put(skb, len);
> +	skb_put(skb, len & 0xffff);
>  	return skb;
>  }
>  

Like Jakub I wonder about this.

The caller extracts the length field out of the descriptor using a
right shift of an unsigned value by 16 bits.  The mask seems
completely unnecessary.

If it is needed, perhaps due to some subsequent change, then please
document it and pair the change with the part the necessitates it.

Thank you.
