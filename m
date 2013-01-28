From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net/ethernet/micrel/ks8851_mll:
 Implement basic statistics
Date: Mon, 28 Jan 2013 18:39:41 -0500 (EST)
Message-ID: <20130128.183941.768670834017645797.davem@davemloft.net>
References: <FD9AD8C5375B924CABC56D982DB3A802079D33CE@EXMB1.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ping.Doong@Micrel.Com, joe@perches.com,
	bhutchings@solarflare.com
To: David.Choi@Micrel.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49369 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927Ab3A1Xjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 18:39:43 -0500
In-Reply-To: <FD9AD8C5375B924CABC56D982DB3A802079D33CE@EXMB1.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Choi, David" <David.Choi@Micrel.Com>
Date: Wed, 23 Jan 2013 18:46:37 +0000

> From: David J. Choi <david.choi@micrel.com>
>  
> Summary of changes:
>   add codes to collect basic statistical information about Ethernet packets.

This is awkward.  Just state in sentences what is happening in the
commit.

There is no need for formalities like "and here comes the summary
of the changes" that's implicit in what this is, a commit log message.

> -		if (likely(skb && (frame_hdr->sts & RXFSHR_RXFV) &&
> +		if (unlikely(!skb)) {
> +			/* discard the packet from the device */
> +			ks_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr | RXQCR_RRXEF);
> +			netdev->stats.rx_dropped++;
> +		}
> +
> +		else if (likely((frame_hdr->sts & RXFSHR_RXFV) &&
>  			(frame_hdr->len < RX_BUF_SIZE) && frame_hdr->len)) {

Because this last condition goes from a plain

	if ()

to

	else if()

the next line is not not indented properly, you must fix that up.

Also, do not split up the closing brace and the next part of the
conditional as you did here, that's wrong.  Do this:

	} else if (...

Do not do this:

	}
	else if (...

You've been submitting patches way to long to be making so many
mistakes like this, my review efforts feel entirely wasted.
