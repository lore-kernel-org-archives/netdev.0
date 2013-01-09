From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch 3.8-rc2] drivers/net/ethernet/micrel/ks8851_mll
Date: Wed, 9 Jan 2013 20:59:12 +0000
Message-ID: <1357765152.2654.9.camel@bwh-desktop.uk.solarflarecom.com>
References: <FD9AD8C5375B924CABC56D982DB3A802079D2520@EXMB1.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Doong, Ping" <Ping.Doong@Micrel.Com>
To: "Choi, David" <David.Choi@Micrel.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:44629 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933271Ab3AIU7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 15:59:15 -0500
In-Reply-To: <FD9AD8C5375B924CABC56D982DB3A802079D2520@EXMB1.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Again this needs a proper subject, like 'ks8851_mll: Implement basic
statistics'.

It should be based on the 'net-next' tree.

On Wed, 2013-01-09 at 20:17 +0000, Choi, David wrote:
> From: David J. Choi <david.choi@micrel.com>
> 
> Summary of changes:
> .add codes to collect statistical information(for example rx/tx packets/bytes, error packets) 
>  about Ethernet packets.
> 
> Signed-off-by: David J. Choi <david.choi@micrel.com>
> ---
> 
> --- linux-3.8-rc2/drivers/net/ethernet/micrel/ks8851_mll.c.orig	2013-01-03 09:45:57.830447923 -0800
> +++ linux-3.8-rc2/drivers/net/ethernet/micrel/ks8851_mll.c	2013-01-03 10:05:57.675756568 -0800
> @@ -801,7 +801,14 @@ static void ks_rcv(struct ks_net *ks, st
>  			skb_put(skb, frame_hdr->len);
>  			skb->protocol = eth_type_trans(skb, netdev);
>  			netif_rx(skb);
> +			netdev->stats.rx_packets++;
> +			netdev->stats.rx_bytes += (frame_hdr->len - 4);

You're subtracting 4 for the CRC?  That really shouldn't be visible to
the kernel (unless the NETIF_F_RXFCS feature is enabled on the device).
So you should also substract 4 from the length passed to skb_put().
(That would be a separate patch, probably suitable for the 'net' tree.)

>  		} else {
> +			netdev->stats.rx_dropped++;
> +			if ((frame_hdr->len >= RX_BUF_SIZE) || (frame_hdr->len == 0))
> +			    netdev->stats.rx_length_errors++;
> +			if (frame_hdr->sts & RXFSHR_RXFV) 
> +			    netdev->stats.rx_frame_errors++;
[...]

These two increment statements are indented wrongly.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
