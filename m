From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] drivers/net/ethernet/micrel/ks8851_mll:
 Implement basic statistics
Date: Mon, 28 Jan 2013 17:34:32 -0800
Message-ID: <1359423272.4196.8.camel@joe-AO722>
References: <FD9AD8C5375B924CABC56D982DB3A802079D33CE@EXMB1.micrel.com>
	 <1358968194.2107.37.camel@joe-AO722>
	 <FD9AD8C5375B924CABC56D982DB3A802079D340B@EXMB1.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Doong, Ping" <Ping.Doong@Micrel.Com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: "Choi, David" <David.Choi@Micrel.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:59199 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751580Ab3A2Bee (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 20:34:34 -0500
In-Reply-To: <FD9AD8C5375B924CABC56D982DB3A802079D340B@EXMB1.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 19:36 +0000, Choi, David wrote:
> From: David J. Choi <david.choi@micrel.com>
> --- net-next/drivers/net/ethernet/micrel/ks8851_mll.c.orig	2013-01-22 17:25:59.000000000 -0800
> +		if (unlikely(!skb)) {
> +			/* discard the packet from the device */
> +			ks_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr | RXQCR_RRXEF);
> +			netdev->stats.rx_dropped++;
> +		} else if (likely((frame_hdr->sts & RXFSHR_RXFV) &&
>  			(frame_hdr->len < RX_BUF_SIZE) && frame_hdr->len)) {

Just one small nit.

This would be better indented as:

		} else if (likely((frame_hdr->sts & RXFSHR_RXFV) &&
				  frame_hdr->len > 0 &&
				  frame_hdr->len < RX_BUF_SIZE)) {

I do wonder why and when frame_hdr->len would be 0
and why the test is < RX_BUF_SIZE and not <=
